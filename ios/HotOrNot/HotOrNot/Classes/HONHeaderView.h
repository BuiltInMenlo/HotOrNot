//
//  HONHeaderView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.14.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONProfileHeaderButtonView.h"
#import "HONCreateSnapButtonView.h"

@interface HONHeaderView : UIView
- (id)initWithTitle:(NSString *)title;
- (id)initWithTitle:(NSString *)title hasBackground:(BOOL)withBG;

- (void)leftAlignTitle;
- (void)addButton:(UIView *)buttonView;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@end
