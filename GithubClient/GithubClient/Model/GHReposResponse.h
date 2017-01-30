//
//  GHReposResponse.h
//  GithubClient
//
//  Created by Kasianenko Boris on 29.01.17.
//  Copyright © 2017 Kasianenko Boris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHRepo.h"

@interface GHReposResponse : NSObject

@property (strong, nonatomic) NSArray<GHRepo *> *repos;
@property (assign, nonatomic) NSInteger totalCount;

@end
