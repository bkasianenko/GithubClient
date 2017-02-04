//
//  ViewController.m
//  GithubClient
//
//  Created by Kasianenko Boris on 28.01.17.
//  Copyright © 2017 Kasianenko Boris. All rights reserved.
//

#import "GHLoginViewController.h"
#import "GHNetworkManager.h"

#define ANIM_DURATION 0.2

@interface GHLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView* textFieldsView;
@property (weak, nonatomic) IBOutlet UITextField* loginTextField;
@property (weak, nonatomic) IBOutlet UIView* loginTextFieldLeftView;
@property (weak, nonatomic) IBOutlet UITextField* passwordTextField;
@property (weak, nonatomic) IBOutlet UIView* passwordTextFieldLeftView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton* loginButton;
@property (weak, nonatomic) IBOutlet UILabel* errorLabel;

@property (assign, nonatomic) BOOL requestInProgress;

@end

@implementation GHLoginViewController

#pragma mark - VC lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.loginTextField.leftView = self.loginTextFieldLeftView;
    self.passwordTextField.leftView = self.passwordTextFieldLeftView;
}

#pragma mark - Actions

- (IBAction)loginAction:(id)sender
{
    [self.loginTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
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

- (void)presentError:(NSError*)error
{
    self.errorLabel.text = error.localizedDescription;
    [self setErrorViewHidden:NO];
}

- (void)hideErrorView
{
    [self setErrorViewHidden:YES];
}

- (void)setErrorViewHidden:(BOOL)hidden
{
    [UIView animateWithDuration:ANIM_DURATION
                     animations:^{
                         self.errorLabel.alpha = hidden ? 0 : 1;
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
