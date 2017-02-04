//
//  GHNetworkManager.m
//  GithubClient
//
//  Created by Kasianenko Boris on 28.01.17.
//  Copyright © 2017 Kasianenko Boris. All rights reserved.
//

#import "GHNetworkManager.h"
#import "GHResponseSerializer.h"
#import <AFNetworking/AFNetworking.h>
#import "GHReposResponse.h"

#define BASE_URL @"https://api.github.com"
#define ERROR_EMPTY_LOGIN 1
#define ERROR_EMPTY_PASSWORD 2

@interface GHNetworkManager()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
@property (strong, nonatomic) NSString *authHeader;

@end

@implementation GHNetworkManager

#pragma mark - Public

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
    NSError *credentialsValidateError = [self validateCredentials:login password:password];
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

- (void)fetchUserReposWithPageSize:(NSInteger)pageSize
                              page:(NSInteger)page
                           success:(void(^)(NSArray<GHRepo *> *repos, NSInteger pagesCount))successBlock
                           failure:(void(^)(NSError* error))failureBlock
{
    NSDictionary* params = @{@"page": @(page), @"per_page": @(pageSize)};
    [self.sessionManager GET:@"/user/repos"
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         if (successBlock != nil)
                         {
                             GHReposResponse* response = [GHResponseSerializer reposFromUserResponseObject:responseObject];
                             NSInteger pagesCount = [self numberOfPagesWithPageSize:pageSize totalCount:response.totalCount];
                             successBlock(response.repos, pagesCount);
                         }
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         if (failureBlock != nil)
                         {
                             failureBlock(error);
                         }
                     }];
}

- (void)searchReposByQuery:(NSString *)searchQuery
                  pageSize:(NSInteger)pageSize
                      page:(NSInteger)page
                   success:(void(^)(NSArray<GHRepo*>* repos, NSInteger pagesCount))successBlock
                   failure:(void(^)(NSError* error))failureBlock
{
    NSError *queryValidateError = [self validateSearchQuery:searchQuery];
    if (queryValidateError != nil)
    {
        if (failureBlock != nil)
        {
            failureBlock(queryValidateError);
        }
        return;
    }
    
    NSDictionary* params = @{@"q": searchQuery, @"page": @(page), @"per_page": @(pageSize)};
    [self.sessionManager GET:@"/search/repositories"
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         if (successBlock != nil)
                         {
                             GHReposResponse* response = [GHResponseSerializer reposFromSearchResponseObject:responseObject];
                             NSInteger pagesCount = [self numberOfPagesWithPageSize:pageSize totalCount:response.totalCount];
                             successBlock(response.repos, pagesCount);
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
        NSURL *baseUrl = [NSURL URLWithString:BASE_URL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSMutableDictionary *headers = [NSMutableDictionary new];
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

- (NSString *)authHeaderForLogin:(NSString *)login password:(NSString *)password
{
    NSString *credentials = [NSString stringWithFormat:@"%@:%@", login, password];
    NSData *credentialsData = [credentials dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Credentials = [credentialsData base64EncodedStringWithOptions:0];
    return [NSString stringWithFormat:@"Basic %@", base64Credentials];
}

- (NSInteger)numberOfPagesWithPageSize:(NSInteger)pageSize totalCount:(NSInteger)totalCount
{
    NSInteger pages = totalCount / pageSize;
    NSInteger lastPageCount = totalCount % pageSize;
    if (lastPageCount > 0)
    {
        pages += 1;
    }
    return pages;
}

- (NSError *)validateCredentials:(NSString *)login password:(NSString *)password
{
    if (login.length == 0)
    {
        return [NSError errorWithDomain:@"" code:ERROR_EMPTY_LOGIN userInfo:@{NSLocalizedDescriptionKey: @"Login is empty"}];
    }
    if (password.length == 0)
    {
        return [NSError errorWithDomain:@"" code:ERROR_EMPTY_PASSWORD userInfo:@{NSLocalizedDescriptionKey: @"Password is empty"}];
    }
    return nil;
}

- (NSError *)validateSearchQuery:(NSString *)searchQuery
{
    if (searchQuery.length == 0)
    {
        return [NSError errorWithDomain:@"" code:ERROR_EMPTY_LOGIN userInfo:@{NSLocalizedDescriptionKey: @"Search query is emptyß®"}];
    }
    return nil;
}

@end
