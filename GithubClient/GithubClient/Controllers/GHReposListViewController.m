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

#define REPOS_PAGE_SIZE 20
#define FOOTER_HEIGHT 40
#define ROW_HEIGHT 55

@interface GHReposListViewController ()

@property (weak, nonatomic) IBOutlet UIView* footerLoadingView;
@property (weak, nonatomic) IBOutlet UIView* headerNoResultsView;

@property (strong, nonatomic) NSMutableArray<GHRepo *> *repos;
@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) NSInteger maxPages;

@property (strong, nonatomic) UIView* headerEmptyView;

@end

@implementation GHReposListViewController

#pragma mark - VC lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"GHRepoCell" bundle:nil] forCellReuseIdentifier:@"RepoCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = ROW_HEIGHT;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.repos = nil;
    self.tableView.tableFooterView = [self tableFooterView];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.row == self.repos.count - 1 && self.page <= self.maxPages && indexPath.section == 0)
    {
        [self fetchRepos];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.repos.count == 0 ? FOOTER_HEIGHT : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.repos.count == 0 ? self.headerNoResultsView : nil;
}

#pragma mark - Private

- (void)fetchRepos
{
    [[GHNetworkManager sharedManager] fetchUserReposWithPageSize:REPOS_PAGE_SIZE
                                                            page:self.page
                                                         success:^(NSArray<GHRepo *> *repos, NSInteger pagesCount) {
                                                             self.page += 1;
                                                             self.maxPages = pagesCount;
                                                             [self.repos addObjectsFromArray:repos];
                                                             [self.tableView reloadData];
                                                             self.tableView.tableFooterView = [self tableFooterView];
                                                         }
                                                         failure:^(NSError *error) {
                                                             self.maxPages = 0;
                                                             [self.tableView reloadData];
                                                             self.tableView.tableFooterView = [self tableFooterView];
                                                         }];
}

- (UIView *)tableFooterView
{
    return self.page <= self.maxPages ? self.footerLoadingView : [UIView new];
}

#pragma mark - Getters/Setters

- (NSMutableArray<GHRepo *> *)repos
{
    if (_repos == nil)
    {
        _repos = [NSMutableArray new];
    }
    return _repos;
}

- (NSInteger)page
{
    if (_page == 0)
    {
        _page = 1;
    }
    return _page;
}

@end
