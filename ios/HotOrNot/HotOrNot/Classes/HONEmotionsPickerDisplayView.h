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
- (void)emotionsPickerDisplayView:(HONEmotionsPickerDisplayView *)pickerDisplayView showCameraFromLargeButton:(BOOL)isLarge;
@end

@interface HONEmotionsPickerDisplayView : UIView
- (id)initWithFrame:(CGRect)frame withPreviewImage:(UIImage *)image;
- (void)addEmotion:(HONEmotionVO *)emotionVO;
- (void)removeEmotion:(HONEmotionVO *)emotionVO;
- (void)updatePreview:(UIImage *)previewImage;
@property (nonatomic, assign) id <HONEmotionsPickerDisplayViewDelegate> delegate;
@end
