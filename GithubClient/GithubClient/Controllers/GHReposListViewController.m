//
//  GHReposListViewController.m
//  GithubClient
//
//  Created by Kasianenko Boris on 28.01.17.
//  Copyright © 2017 Kasianenko Boris. All rights reserved.
//

#import "GHReposListViewController.h"
#import "GHRepo.h"
#import "GHNetworkManager.h"
#import "GHRepoCell.h"

@interface GHReposListViewController ()

@property (strong, nonatomic) NSArray<GHRepo *> *repos;

@end

@implementation GHReposListViewController

#pragma mark - VC lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"GHRepoCell" bundle:nil] forCellReuseIdentifier:@"RepoCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 55;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Repositories";
    [self fetchRepos];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.repos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GHRepoCell *cell = (GHRepoCell *)[tableView dequeueReusableCellWithIdentifier:@"RepoCell" forIndexPath:indexPath];
    GHRepo *repo = self.repos[indexPath.row];
    cell.repo = repo;
    return cell;
}

#pragma mark - Fetching data

- (void)fetchRepos
{
    [[GHNetworkManager sharedManager] fetchUserReposSuccess:^(NSArray<GHRepo *> *repos, NSInteger totalCount) {
        self.repos = repos;
        [self.tableView reloadData];
    }
                                                    failure:^(NSError *error) {
                                                        NSLog(@"%@", error);
                                                    }];
}

@end
