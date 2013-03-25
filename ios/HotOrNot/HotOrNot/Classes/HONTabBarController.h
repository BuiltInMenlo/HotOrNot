//
//  HONTabBarController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.04.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HONTabBarController : UITabBarController {
}

- (void)hideTabBar;
- (void)addCustomElements;
- (void)selectTab:(int)tabID;

- (void)hideNewTabBar;
- (void)showNewTabBar;

#define kLipHeight 16.0
#define kTabHeight 59.0

@end
