//
//  HONHeaderView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.14.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

@interface HONHeaderView : UIView
- (id)initWithBranding;
- (id)initWithTitle:(NSString *)title;
//- (id)initWithTitle:(NSString *)title hasBackground:(BOOL)withBG;

- (void)addButton:(UIView *)buttonView;
- (void)leftAlignTitle;
- (void)setFont:(UIFont *)font;
//- (void)toggleLightStyle:(BOOL)isLightStyle;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@end
