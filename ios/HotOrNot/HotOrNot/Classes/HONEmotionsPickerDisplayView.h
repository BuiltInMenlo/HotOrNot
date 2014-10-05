//
//  HONEmotionsPickerDisplayView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 00:03 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONEmotionVO.h"

extern const CGSize kMaxLabelSize;

@class HONEmotionsPickerDisplayView;
@protocol HONEmotionsPickerDisplayViewDelegate <NSObject>
@optional
- (void)emotionsPickerDisplayViewShowCamera:(HONEmotionsPickerDisplayView *)pickerDisplayView;
- (void)emotionsPickerDisplayViewGoFullScreen:(HONEmotionsPickerDisplayView *)pickerDisplayView;
- (void)emotionsPickerDisplayView:(HONEmotionsPickerDisplayView *)pickerDisplayView scrolledEmotionsToIndex:(int)index fromDirection:(int)dir;
@end

@interface HONEmotionsPickerDisplayView : UIView <UIScrollViewDelegate>
- (id)initWithFrame:(CGRect)frame withPreviewImage:(UIImage *)image;
- (void)addEmotion:(HONEmotionVO *)emotionVO;
- (void)removeEmotion:(HONEmotionVO *)emotionVO;
- (void)flushEmotions;
- (void)updatePreview:(UIImage *)previewImage;

@property (nonatomic, assign) id <HONEmotionsPickerDisplayViewDelegate> delegate;
@end
