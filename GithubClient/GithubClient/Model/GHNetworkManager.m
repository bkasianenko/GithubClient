//
//  GHNetworkManager.m
//  GithubClient
//
//  Created by Kasianenko Boris on 28.01.17.
//  Copyright © 2017 Kasianenko Boris. All rights reserved.
//

#import "GHNetworkManager.h"
#import <AFNetworking/AFNetworking.h>

#define BASE_URL @"https://api.github.com"
#define ERROR_EMPTY_LOGIN 1
#define ERROR_EMPTY_PASSWORD 2

@interface GHNetworkManager()

@property (strong, nonatomic) AFHTTPSessionManager* sessionManager;
@property (strong, nonatomic) NSString* authHeader;

@end

@implementation GHNetworkManager

#pragma mark - Public interface

+ (instancetype)sharedManager
{
    static GHNetworkManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GHNetworkManager alloc] init];
    });
    return sharedInstance;
}

- (void)authUserWithLogin:(NSString *)login
                 password:(NSString *)password
                  success:(void(^)(void))successBlock
                  failure:(void(^)(NSError* error))failureBlock
{
    NSError* credentialsValidateError = [self validateCredentials:login password:password];
    if (credentialsValidateError != nil)
    {
        if (failureBlock != nil)
        {
            failureBlock(credentialsValidateError);
        }
        return;
    }
    
    self.authHeader = [self authHeaderForLogin:login password:password];
    self.sessionManager = nil;
    [self.sessionManager GET:@"/user"
                  parameters:nil
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         if (successBlock != nil)
                         {
                             successBlock();
                         }
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         if (failureBlock != nil)
                         {
                             failureBlock(error);
                         }
                     }];
}

#pragma mark - Getters/Setters

- (AFHTTPSessionManager *)sessionManager
{
    if (_sessionManager == nil)
    {
        NSURL* baseUrl = [NSURL URLWithString:BASE_URL];
        NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSMutableDictionary* headers = [NSMutableDictionary new];
        if (self.authHeader != nil)
        {
            [headers setObject:self.authHeader forKey:@"Authorization"];
        }
        configuration.HTTPAdditionalHeaders = headers;
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl sessionConfiguration:configuration];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    }
    return _sessionManager;
}

#pragma mark - Private

- (NSString*)authHeaderForLogin:(NSString*)login password:(NSString*)password
{
    NSString* credentials = [NSString stringWithFormat:@"%@:%@", login, password];
    NSData* credentialsData = [credentials dataUsingEncoding:NSUTF8StringEncoding];
    NSString* base64Credentials = [credentialsData base64EncodedStringWithOptions:0];
    return [NSString stringWithFormat:@"Basic %@", base64Credentials];
}

- (NSError*)validateCredentials:(NSString*)login password:(NSString*)password
{
    if (login.length == 0)
    {
        return [NSError errorWithDomain:@"" code:ERROR_EMPTY_LOGIN userInfo:@{NSLocalizedDescriptionKey: @"Поле логина на заполнено"}];
    }
    if (password.length == 0)
    {
        return [NSError errorWithDomain:@"" code:ERROR_EMPTY_PASSWORD userInfo:@{NSLocalizedDescriptionKey: @"Поле пароля не заполнено"}];
    }
    return nil;
}

@end
