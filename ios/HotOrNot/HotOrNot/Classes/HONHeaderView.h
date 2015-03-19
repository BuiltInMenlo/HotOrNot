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
- (id)initWithBranding;
- (id)initWithTitleImage:(UIImage *)image;

- (void)addButton:(UIView *)buttonView;
- (void)addActivityButtonWithTarget:(id)target action:(SEL)action;
- (void)addBackButtonWithTarget:(id)target action:(SEL)action;
- (void)addCloseButtonWithTarget:(id)target action:(SEL)action;
- (void)addComposeButtonWithTarget:(id)target action:(SEL)action;
- (void)addDoneButtonWithTarget:(id)target action:(SEL)action;
- (void)addDownloadButtonWithTarget:(id)target action:(SEL)action;
- (void)addFlagButtonWithTarget:(id)target action:(SEL)action;
- (void)addMoreButtonWithTarget:(id)target action:(SEL)action;
- (void)addNextButtonWithTarget:(id)target action:(SEL)action;
- (void)addPrivacyButtonWithTarget:(id)target action:(SEL)action;
- (void)addTitleButtonWithTarget:(id)target action:(SEL)action;
- (void)transitionTitle:(NSString *)title;
- (void)leftAlignTitle;
- (void)tappedTitle;
- (void)addTitleImage:(UIImage *)image;
- (void)updateActivityScore:(int)score;
- (void)removeBackground;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@end
