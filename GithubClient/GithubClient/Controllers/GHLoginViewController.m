//
//  ViewController.m
//  GithubClient
//
//  Created by Kasianenko Boris on 28.01.17.
//  Copyright © 2017 Kasianenko Boris. All rights reserved.
//

#import "GHLoginViewController.h"
#import "GHNetworkManager.h"

@interface GHLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField* loginTextField;
@property (weak, nonatomic) IBOutlet UITextField* passwordTextField;

@end

@implementation GHLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)loginAction:(id)sender
{
    [[GHNetworkManager sharedManager] authUserWithLogin:self.loginTextField.text
                                               password:self.passwordTextField.text
                                                success:^{
                                                    [self performSegueWithIdentifier:@"ReposListSegue" sender:self];
                                                }
                                                failure:^(NSError *error) {
                                                    NSLog(@"%@", error);
                                                }];
}

@end
