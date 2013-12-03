//
//  UINavigationBar+NavigationBar.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/4/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UINavigationBar+NavigationBar.h"

@implementation UINavigationBar (NavigationBar)

- (void)setBarForViewController {
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header"]];
	[self addSubview:bgImageView];
	[self sendSubviewToBack:bgImageView];
}
@end
