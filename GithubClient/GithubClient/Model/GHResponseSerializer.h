//
//  GHResponseSerializer.h
//  GithubClient
//
//  Created by Kasianenko Boris on 28.01.17.
//  Copyright © 2017 Kasianenko Boris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHReposResponse.h"

@interface GHResponseSerializer : NSObject

+ (GHReposResponse*)reposFromUserResponseObject:(id)response;
+ (GHReposResponse*)reposFromSearchResponseObject:(id)response;

@end
