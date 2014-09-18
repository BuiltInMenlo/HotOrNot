//
//  HONHeaderView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.14.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

@interface HONHeaderView : UIView
- (id)initWithTitle:(NSString *)title;
- (id)initUsingAltFontWithTitle:(NSString *)title;
- (id)initWithTitleImage:(UIImage *)image;

- (void)addButton:(UIView *)buttonView;
- (void)leftAlignTitle;
- (void)addTitleImage:(UIImage *)image;
- (void)removeBackground;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@end
