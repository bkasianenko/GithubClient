//
//  GHRepo.h
//  GithubClient
//
//  Created by Kasianenko Boris on 28.01.17.
//  Copyright © 2017 Kasianenko Boris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHRepo : NSObject

@property (strong, nonatomic) NSString *repoId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *desc;

@end
