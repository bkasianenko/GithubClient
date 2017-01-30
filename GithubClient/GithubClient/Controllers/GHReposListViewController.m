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

@interface GHReposListViewController ()

@property (strong, nonatomic) NSMutableArray<GHRepo *> *repos;
@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) NSInteger maxPages;

@property (strong, nonatomic) UIView* headerNoResultsView;
@property (strong, nonatomic) UIView* headerEmptyView;
@property (strong, nonatomic) UIView* footerLoadingView;
@property (strong, nonatomic) UIView* footerEmptyView;

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
    if (self.repos.count == 0)
    {
        return 40;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.repos.count == 0)
    {
        return self.headerNoResultsView;
    }
    else
    {
        return self.headerEmptyView;
    }
}

#pragma mark - Private

- (void)fetchRepos
{
    [[GHNetworkManager sharedManager] fetchUserReposSuccess:^(NSArray<GHRepo *> *repos, NSInteger totalCount) {
        self.page += 1;
        self.maxPages = [self numberOfPagesWithPageSize:REPOS_PAGE_SIZE totalCount:totalCount];
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
    if (self.page <= self.maxPages)
    {
        return self.footerLoadingView;
    }
    else
    {
        return self.footerEmptyView;
    }
}

- (NSInteger)numberOfPagesWithPageSize:(NSInteger)pageSize totalCount:(NSInteger)totalCount
{
    NSInteger pages = totalCount / pageSize;
    NSInteger lastPageCount = totalCount % pageSize;
    if (lastPageCount > 0)
    {
        pages += 1;
    }
    return pages;
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

- (UIView *)headerNoResultsView
{
    if (_headerNoResultsView == nil)
    {
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30)];
        headerLabel.text = @"No repositories was found";
        headerLabel.textColor = [UIColor colorWithRed:0.28 green:0.28 blue:0.28 alpha:1.0];
        headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        _headerNoResultsView = headerLabel;
    }
    return _headerNoResultsView;
}

- (UIView *)headerEmptyView
{
    if (_headerEmptyView == nil)
    {
        _headerEmptyView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _headerEmptyView;
}

- (UIView *)footerLoadingView
{
    if (_footerLoadingView == nil)
    {
        _footerLoadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 40)];
        _footerLoadingView.backgroundColor = [UIColor clearColor];
        UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.frame = CGRectMake((_footerLoadingView.bounds.size.width - 20) / 2, (_footerLoadingView.bounds.size.height - 20) / 2, 20, 20);
        activityIndicator.color = [UIColor colorWithRed:0.1 green:0.74 blue:0.61 alpha:1.0];
        [activityIndicator startAnimating];
        [_footerLoadingView addSubview:activityIndicator];
    }
    return _footerLoadingView;
}

- (UIView *)footerEmptyView
{
    if (_footerEmptyView == nil)
    {
        _footerEmptyView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _footerEmptyView;
}

@end
