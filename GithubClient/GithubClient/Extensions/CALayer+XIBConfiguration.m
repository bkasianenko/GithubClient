//
//  CALayer+XIBConfiguration.m
//  GithubClient
//
//  Created by Kasianenko Boris on 04.02.17.
//  Copyright © 2017 Kasianenko Boris. All rights reserved.
//

#import "CALayer+XIBConfiguration.h"

@implementation CALayer (XIBConfiguration)

- (void)setBorderUIColor:(UIColor *)borderUIColor
{
    self.borderColor = borderUIColor.CGColor;
}

- (UIColor*)borderUIColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}

@end
