//
//  GHRepo.m
//  GithubClient
//
//  Created by Kasianenko Boris on 28.01.17.
//  Copyright © 2017 Kasianenko Boris. All rights reserved.
//

#import "GHRepo.h"

@implementation GHRepo

- (NSString*)desc
{
    if ([_desc isEqual:[NSNull null]])
    {
        return @"No description";
    }
    if (_desc.length == 0)
    {
        return @"No description";
    }
    return _desc;
}

@end
