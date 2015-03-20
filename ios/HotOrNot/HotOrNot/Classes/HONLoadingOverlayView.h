//
//  HONLoadingOverlayView.h
//  HotOrNot
//
//  Created by BIM  on 1/30/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

@class HONLoadingOverlayView;
@protocol HONLoadingOverlayViewDelegate <NSObject>
@optional
- (void)loadingOverlayViewDidIntro:(HONLoadingOverlayView *)loadingOverlayView;
- (void)loadingOverlayViewDidOutro:(HONLoadingOverlayView *)loadingOverlayView;
@end

@interface HONLoadingOverlayView : UIView
- (id)init;
- (id)initWithCaption:(NSString *)caption;
- (id)initAsAnimated:(BOOL)isAnimated;
- (id)initAsAnimated:(BOOL)isAnimated withCaption:(NSString *)caption;
- (id)initWithinView:(UIView *)view;
- (id)initWithinView:(UIView *)view withCaption:(NSString *)caption;
- (id)initWithinView:(UIView *)view isAnimated:(BOOL)isAnimated;
- (id)initWithinView:(UIView *)view isAnimated:(BOOL)isAnimated withCaption:(NSString *)caption;
- (void)outro;

@property (nonatomic, assign) id <HONLoadingOverlayViewDelegate> delegate;
@end
