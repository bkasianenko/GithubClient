//
//  GHNetworkManager.h
//  GithubClient
//
//  Created by Kasianenko Boris on 28.01.17.
//  Copyright © 2017 Kasianenko Boris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHRepo.h"

@interface GHNetworkManager : NSObject

+ (instancetype)sharedManager;

- (void)authUserWithLogin:(NSString *)login
                 password:(NSString *)password
                  success:(void(^)(void))successBlock
                  failure:(void(^)(NSError* error))failureBlock;

- (void)fetchUserReposSuccess:(void(^)(NSArray<GHRepo*>* repos))successBlock
                      failure:(void(^)(NSError* error))failureBlock;

@end
