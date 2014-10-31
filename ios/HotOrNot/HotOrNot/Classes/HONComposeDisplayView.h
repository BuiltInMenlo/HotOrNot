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
- (void)composeDisplayViewShowCamera:(HONComposeDisplayView *)composeDisplayView;
@optional
- (void)composeDisplayViewGoFullScreen:(HONComposeDisplayView *)composeDisplayView;
- (void)composeDisplayView:(HONComposeDisplayView *)composeDisplayView scrolledEmotionsToIndex:(int)index fromDirection:(int)dir;
@end

@interface HONComposeDisplayView : UIView <UIScrollViewDelegate>
- (void)addEmotion:(HONEmotionVO *)emotionVO;
- (void)removeLastEmotion;
- (void)flushEmotions;
- (void)updatePreview:(UIImage *)previewImage;
- (void)updatePreviewWithAnimatedImageView:(FLAnimatedImageView *)animatedImageView;
- (void)scrollToEmotion:(HONEmotionVO *)emotionVO atIndex:(int)index;
- (void)scrollToEmotionIndex:(int)index;

@property (nonatomic, assign) id <HONComposeDisplayViewDelegate> delegate;
@end



//			NSURL *url1 = [NSURL URLWithString:@"http://i.imgur.com/1lgZ0.gif"];
//			NSURL *url1 = [[NSBundle mainBundle] URLForResource:@"1lgZ0" withExtension:@"gif"];
//			NSURL *url1 = [NSURL URLWithString:@"http://25.media.tumblr.com/tumblr_ln48mew7YO1qbhtrto1_500.gif"];

