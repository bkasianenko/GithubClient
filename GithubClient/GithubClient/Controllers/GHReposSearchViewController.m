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

@interface GHReposSearchViewController () <UISearchResultsUpdating>

@property (strong, nonatomic) UISearchController* searchController;
@property (strong, nonatomic) NSArray<GHRepo*>* searchResults;

@end

@implementation GHReposSearchViewController

#pragma mark - VC lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RepoCell" forIndexPath:indexPath];
    if ([self searchBarActive])
    {
        GHRepo* repo = self.searchResults[indexPath.row];
        cell.textLabel.text = repo.name;
        cell.detailTextLabel.text = repo.desc;
    }
    return cell;
}

#pragma mark - UISearchResultsUpdating delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [self searchReposByQuery:searchController.searchBar.text];
}

#pragma mark - Getters/Setters

- (UISearchController*)searchController
{
    if (_searchController == nil)
    {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        _searchController.dimsBackgroundDuringPresentation = false;
        self.definesPresentationContext = YES;
        self.tableView.tableHeaderView = _searchController.searchBar;
    }
    return _searchController;
}

#pragma mark - Private

- (void)searchReposByQuery:(NSString*)searchQuery
{
    [[GHNetworkManager sharedManager] searchReposByQuery:searchQuery
                                                 success:^(NSArray<GHRepo *> *repos) {
                                                     self.searchResults = repos;
                                                     [self.tableView reloadData];
                                                 }
                                                 failure:^(NSError *error) {
                                                     NSLog(@"%@", error);
                                                 }];
}

- (BOOL)searchBarActive
{
    return self.searchController.active && self.searchController.searchBar.text.length > 0;
}

@end
