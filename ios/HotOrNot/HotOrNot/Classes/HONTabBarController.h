//
//  HONTabBarController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.04.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

typedef enum {
	HONTabBarButtonTypeHome = 0,
	HONTabBarButtonTypeClubs,
	HONTabBarButtonTypeVerify
} HONTabBarButtonType;


const CGSize kTabSize;

@interface HONTabBarController : UITabBarController
@end