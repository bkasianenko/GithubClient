//
//  GHResponseSerializer.h
//  GithubClient
//
//  Created by Kasianenko Boris on 28.01.17.
//  Copyright © 2017 Kasianenko Boris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHRepo.h"

@interface GHResponseSerializer : NSObject

+ (NSArray<GHRepo*>*)reposFromUserResponseObject:(id)response;
+ (NSArray<GHRepo*>*)reposFromSearchResponseObject:(id)response;

@end
