//
//  GHRepoCell.m
//  GithubClient
//
//  Created by Kasianenko Boris on 29.01.17.
//  Copyright © 2017 Kasianenko Boris. All rights reserved.
//

#import "GHRepoCell.h"

@interface GHRepoCell()

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UILabel* detailsLabel;

@end

@implementation GHRepoCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setupUI
{
    self.titleLabel.text = _repo.name;
    self.detailsLabel.text = _repo.desc;
}

- (void)setRepo:(GHRepo *)repo
{
    if (![_repo isEqual:repo])
    {
        _repo = repo;
        [self setupUI];
    }
}

@end
