//
//  HONEmotionsPickerDisplayView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 00:03 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

#import "HONEmotionVO.h"

extern const CGSize kMaxLabelSize;

@class HONComposeDisplayView;
@protocol HONComposeDisplayViewDelegate <NSObject>
@optional
- (void)composeDisplayViewShowCamera:(HONComposeDisplayView *)composeDisplayView;
- (void)composeDisplayViewGoFullScreen:(HONComposeDisplayView *)composeDisplayView;
- (void)composeDisplayView:(HONComposeDisplayView *)composeDisplayView scrolledEmotionsToIndex:(int)index fromDirection:(int)dir;
@end

@interface HONComposeDisplayView : UIView <UIScrollViewDelegate>
- (void)addEmotion:(HONEmotionVO *)emotionVO;
- (void)removeLastEmotion;
- (void)flushEmotions;
- (void)updatePreview:(UIImage *)previewImage;
- (void)updatePreviewWithAnimatedImageView:(FLAnimatedImageView *)animatedImageView;

@property (nonatomic, assign) id <HONComposeDisplayViewDelegate> delegate;
@end
