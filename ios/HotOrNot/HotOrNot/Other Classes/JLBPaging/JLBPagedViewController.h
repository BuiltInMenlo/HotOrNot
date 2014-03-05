//
//  JLBPagedViewController.h
//  NavigationTest
//
//  Created by Jesse Boley on 2/27/14.
//  Copyright (c) 2014 Jesse Boley. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JLBPagedView.h"

@interface JLBPagedViewController : UIViewController <JLBPagedViewControllerDataSource>
@property(nonatomic, strong, readonly) JLBPagedView *pagedScrollView;
@end
