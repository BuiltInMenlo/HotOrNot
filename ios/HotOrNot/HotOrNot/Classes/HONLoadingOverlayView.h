//
//  HONLoadingOverlayView.h
//  HotOrNot
//
//  Created by BIM  on 1/30/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

@class HONLoadingOverlayView;
@protocol HONLoadingOverlayViewDelegate <NSObject>
- (void)loadingOverlayViewDidIntro:(HONLoadingOverlayView *)loadingOverlayView;
- (void)loadingOverlayViewDidOutro:(HONLoadingOverlayView *)loadingOverlayView;
@end

@interface HONLoadingOverlayView : UIView
- (id)init;
- (id)initWithView:(UIView *)view;
- (id)initWithView:(UIView *)view isAnimated:(BOOL)isAnimated;
- (void)outro;

@property (nonatomic, assign) id <HONLoadingOverlayViewDelegate> delegate;
@end
