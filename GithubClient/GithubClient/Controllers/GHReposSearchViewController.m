//
//  GHReposSearchViewController.m
//  GithubClient
//
//  Created by Kasianenko Boris on 28.01.17.
//  Copyright © 2017 Kasianenko Boris. All rights reserved.
//

#import "GHReposSearchViewController.h"
#import "GHRepo.h"
#import "GHNetworkManager.h"
#import "GHRepoCell.h"

#define REPOS_PAGE_SIZE 20

@interface GHReposSearchViewController () <UISearchResultsUpdating>

@property (strong, nonatomic) UISearchController* searchController;
@property (strong, nonatomic) NSMutableArray<GHRepo*>* searchResults;
@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) NSInteger maxPages;
@property (strong, nonatomic) NSString* searchQuery;

@property (strong, nonatomic) UIView* headerNoResultsView;
@property (strong, nonatomic) UIView* headerEmptyView;
@property (strong, nonatomic) UIView* footerLoadingView;
@property (strong, nonatomic) UIView* footerEmptyView;

@end

@implementation GHReposSearchViewController

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
    self.navigationItem.title = @"Repositories search";
    self.tableView.tableFooterView = [self tableFooterView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self searchBarActive])
    {
        return self.searchResults.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GHRepoCell *cell = (GHRepoCell *)[tableView dequeueReusableCellWithIdentifier:@"RepoCell" forIndexPath:indexPath];
    if ([self searchBarActive])
    {
        cell.repo = self.searchResults[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.row == self.searchResults.count - 1 && self.page <= self.maxPages && indexPath.section == 0)
    {
        self.page += 1;
        [self searchReposByQuery:self.searchController.searchBar.text];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.searchResults.count == 0)
    {
        return 40;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.searchResults.count == 0)
    {
        return self.headerNoResultsView;
    }
    else
    {
        return self.headerEmptyView;
    }
}

#pragma mark - UISearchResultsUpdating delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    self.searchQuery = searchController.searchBar.text;
}

#pragma mark - Private

- (void)searchReposByQuery:(NSString*)searchQuery
{
    [[GHNetworkManager sharedManager] searchReposByQuery:searchQuery
                                                pageSize:REPOS_PAGE_SIZE
                                                    page:self.page
                                                 success:^(NSArray<GHRepo *> *repos, NSInteger totalCount) {
                                                     [self.searchResults addObjectsFromArray:repos];
                                                     self.maxPages = [self numberOfPagesWithPageSize:REPOS_PAGE_SIZE totalCount:totalCount];
                                                     [self.tableView reloadData];
                                                     self.tableView.tableFooterView = [self tableFooterView];
                                                 }
                                                 failure:^(NSError *error) {
                                                     self.maxPages = 0;
                                                     [self.tableView reloadData];
                                                     self.tableView.tableFooterView = [self tableFooterView];
                                                     NSLog(@"%@", error);
                                                 }];
}

- (BOOL)searchBarActive
{
    return self.searchController.active && self.searchController.searchBar.text.length > 0;
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

- (UISearchController*)searchController
{
    if (_searchController == nil)
    {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        _searchController.dimsBackgroundDuringPresentation = false;
        _searchController.searchBar.tintColor = [UIColor colorWithRed:0.1 green:0.74 blue:0.61 alpha:1.0];
        self.definesPresentationContext = YES;
        self.tableView.tableHeaderView = _searchController.searchBar;
    }
    return _searchController;
}

- (NSMutableArray<GHRepo *> *)searchResults
{
    if (_searchResults == nil)
    {
        _searchResults = [NSMutableArray new];
    }
    return _searchResults;
}

- (void)setSearchQuery:(NSString *)searchQuery
{
    if (![_searchQuery isEqualToString:searchQuery])
    {
        _searchQuery = searchQuery;
        self.searchResults = [NSMutableArray new];
        [self searchReposByQuery:_searchQuery];
    }
}

- (NSInteger)page
{
    if (_page == 0)
    {
        _page = 1;
    }
    return _page;
}

- (UIView*)headerNoResultsView
{
    if (_headerNoResultsView == nil)
    {
        UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30)];
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

- (UIView*)footerLoadingView
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

- (UIView*)footerEmptyView
{
    if (_footerEmptyView == nil)
    {
        _footerEmptyView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _footerEmptyView;
}

@end
