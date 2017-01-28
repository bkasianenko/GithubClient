//
//  GHResponseSerializer.m
//  GithubClient
//
//  Created by Kasianenko Boris on 28.01.17.
//  Copyright © 2017 Kasianenko Boris. All rights reserved.
//

#import "GHResponseSerializer.h"

@implementation GHResponseSerializer

+ (NSArray<GHRepo*>*)reposFromResponseObject:(id)response
{
    NSMutableArray<GHRepo*>* repos = [NSMutableArray new];
    for (NSDictionary* repoDict in response)
    {
        GHRepo* repo = [GHRepo new];
        repo.repoId = repoDict[@"id"];
        repo.name = repoDict[@"name"];
        repo.desc = repoDict[@"description"];
        [repos addObject:repo];
    }
    return repos;
}

@end
