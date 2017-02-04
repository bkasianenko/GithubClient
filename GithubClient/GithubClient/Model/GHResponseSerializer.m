//
//  GHResponseSerializer.m
//  GithubClient
//
//  Created by Kasianenko Boris on 28.01.17.
//  Copyright © 2017 Kasianenko Boris. All rights reserved.
//

#import "GHResponseSerializer.h"
#import "GHRepo.h"

@implementation GHResponseSerializer

+ (GHReposResponse *)reposFromUserResponseObject:(id)response
{
    GHReposResponse *reposResponse = [GHReposResponse new];
    reposResponse.repos = [self reposFromArray:response];
    return reposResponse;
}

+ (GHReposResponse *)reposFromSearchResponseObject:(id)response
{
    NSDictionary *responseDict = (NSDictionary *)response;
    NSArray *responseRepos = responseDict[@"items"];
    GHReposResponse *reposResponse = [GHReposResponse new];
    reposResponse.repos = [self reposFromArray:responseRepos];
    reposResponse.totalCount = [responseDict[@"total_count"] integerValue];
    return reposResponse;
}

+ (NSArray<GHRepo *> *)reposFromArray:(NSArray *)responseArray
{
    NSMutableArray<GHRepo *> *repos = [NSMutableArray new];
    for (NSDictionary *repoDict in responseArray)
    {
        GHRepo *repo = [GHRepo new];
        repo.repoId = repoDict[@"id"];
        repo.name = repoDict[@"name"];
        repo.desc = repoDict[@"description"];
        [repos addObject:repo];
    }
    return repos;
}

@end
