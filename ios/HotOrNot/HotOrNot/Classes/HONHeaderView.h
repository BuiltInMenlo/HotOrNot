//
//  HONHeaderView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.14.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

@interface HONHeaderView : UIView
- (id)initWithTitle:(NSString *)title;
- (id)initWithTitle:(NSString *)title asLightStyle:(BOOL)isLightStyle;
//- (id)initWithTitleUsingCartoGothic:(NSString *)title;
//- (id)initWithTitleUsingCartoGothic:(NSString *)title asLightStyle:(BOOL)isLightStyle;
- (id)initWithTitleImage:(UIImage *)image;

- (void)addButton:(UIView *)buttonView;
- (void)addBackButtonWithTarget:(id)target usingAction:(SEL)action;
- (void)addCloseButtonWithTarget:(id)target usingAction:(SEL)action;
- (void)addComposeButtonWithTarget:(id)target usingAction:(SEL)action;
- (void)addDoneButtonWithTarget:(id)target usingAction:(SEL)action;
- (void)addNextButtonWithTarget:(id)target usingAction:(SEL)action;
- (void)transitionTitle:(NSString *)title;
- (void)leftAlignTitle;
- (void)toggleLightStyle:(BOOL)isLightStyle;
- (void)addTitleImage:(UIImage *)image;
- (void)removeBackground;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@end
