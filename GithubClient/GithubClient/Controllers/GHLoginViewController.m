//
//  ViewController.m
//  GithubClient
//
//  Created by Kasianenko Boris on 28.01.17.
//  Copyright © 2017 Kasianenko Boris. All rights reserved.
//

#import "GHLoginViewController.h"
#import "GHNetworkManager.h"

@interface GHLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView* textFieldsView;
@property (weak, nonatomic) IBOutlet UITextField* loginTextField;
@property (weak, nonatomic) IBOutlet UITextField* passwordTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton* loginButton;
@property (weak, nonatomic) IBOutlet UILabel* errorLabel;

@property (assign, nonatomic) BOOL requestInProgress;

@end

@implementation GHLoginViewController

#pragma mark - VC lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupUI];
}

#pragma mark - Actions

- (IBAction)loginAction:(id)sender
{
    [self login];
}

#pragma mark - UITextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self hideErrorView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.loginTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField && !self.requestInProgress)
    {
        [self login];
    }
    return YES;
}

#pragma mark - Private

- (void)login
{
    self.requestInProgress = YES;
    [[GHNetworkManager sharedManager] authUserWithLogin:self.loginTextField.text
                                               password:self.passwordTextField.text
                                                success:^{
                                                    [self performSegueWithIdentifier:@"ReposListSegue" sender:self];
                                                    self.requestInProgress = NO;
                                                }
                                                failure:^(NSError *error) {
                                                    [self presentError:error];
                                                    self.requestInProgress = NO;
                                                }];
}

- (void)setupUI
{
    self.textFieldsView.backgroundColor = [UIColor clearColor];
    self.textFieldsView.layer.borderWidth = 1;
    self.textFieldsView.layer.cornerRadius = 5;
    self.textFieldsView.layer.borderColor = [UIColor colorWithRed:0.88 green:0.89 blue:0.91 alpha:1.0].CGColor;
    
    self.loginTextField.leftViewMode = UITextFieldViewModeAlways;
    self.loginTextField.leftView = [self leftViewWithImage:[UIImage imageNamed:@"login_username"]];
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordTextField.leftView = [self leftViewWithImage:[UIImage imageNamed:@"login_password"]];
    
    self.loginButton.layer.cornerRadius = 5;
    
    self.errorLabel.alpha = 0;
}

- (UIView*)leftViewWithImage:(UIImage*)image
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 30)];
    UIImageView* iconView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 8, 14, 14)];
    iconView.image = image;
    iconView.tintColor = [UIColor colorWithRed:0.46 green:0.51 blue:0.61 alpha:1.0];
    [view addSubview:iconView];
    return view;
}

- (void)presentError:(NSError*)error
{
    self.errorLabel.text = error.localizedDescription;
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.errorLabel.alpha = 1;
                     }];
}

- (void)hideErrorView
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.errorLabel.alpha = 0;
                     }];
}

#pragma mark - Getters/Setters

- (void)setRequestInProgress:(BOOL)requestInProgress
{
    _requestInProgress = requestInProgress;
    if (_requestInProgress)
    {
        [self.activityIndicator startAnimating];
        [self.loginButton setEnabled:NO];
    }
    else
    {
        [self.activityIndicator stopAnimating];
        [self.loginButton setEnabled:YES];
    }
}

@end
