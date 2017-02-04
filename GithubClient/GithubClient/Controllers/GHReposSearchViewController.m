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
#define ROW_HEIGHT 55
#define HEADER_HEIGHT 40

@interface GHReposSearchViewController () <UISearchResultsUpdating>

@property (weak, nonatomic) IBOutlet UIView *footerLoadingView;
@property (weak, nonatomic) IBOutlet UIView *headerNoResultsView;

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSMutableArray<GHRepo *> *searchResults;
@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) NSInteger maxPages;
@property (strong, nonatomic) NSString *searchQuery;

@end

@implementation GHReposSearchViewController

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
    self.tableView.tableFooterView = [self tableFooterView];
}

#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self searchBarActive] ? self.searchResults.count : 0;
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
    return self.searchResults.count == 0 ? HEADER_HEIGHT : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.searchResults.count == 0 ? self.headerNoResultsView : [UIView new];
}

#pragma mark - UISearchResultsUpdating delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    self.searchQuery = searchController.searchBar.text;
}

#pragma mark - Private

- (void)searchReposByQuery:(NSString *)searchQuery
{
    [[GHNetworkManager sharedManager] searchReposByQuery:searchQuery
                                                pageSize:REPOS_PAGE_SIZE
                                                    page:self.page
                                                 success:^(NSArray<GHRepo *> *repos, NSInteger pagesCount) {
                                                     [self.searchResults addObjectsFromArray:repos];
                                                     self.maxPages = pagesCount;
                                                     [self.tableView reloadData];
                                                     self.tableView.tableFooterView = [self tableFooterView];
                                                 }
                                                 failure:^(NSError *error) {
                                                     self.maxPages = 0;
                                                     [self.tableView reloadData];
                                                     self.tableView.tableFooterView = [self tableFooterView];
                                                 }];
}

- (BOOL)searchBarActive
{
    return self.searchController.active && self.searchController.searchBar.text.length > 0;
}

- (UIView *)tableFooterView
{
    return self.page <= self.maxPages ? self.footerLoadingView : [UIView new];
}

#pragma mark - Getters/Setters

- (UISearchController *)searchController
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

@end
