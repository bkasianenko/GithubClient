//
//  GHRepoCell.h
//  GithubClient
//
//  Created by Kasianenko Boris on 29.01.17.
//  Copyright © 2017 Kasianenko Boris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHRepo.h"

@interface GHRepoCell : UITableViewCell

@property (strong, nonatomic) GHRepo* repo;

@end
