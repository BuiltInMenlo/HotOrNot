//
//  HONStickerPickerItemView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/21/2014 @ 20:44 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "PicoSticker.h"

#import "HONEmotionVO.h"

@class HONStickerButtonView;
@protocol HONStickerButtonViewDelegate <NSObject>
@optional
- (void)stickerButtonView:(HONStickerButtonView *)stickerButtonView selectedEmotion:(HONEmotionVO *)emotionVO;
@end

@interface HONStickerButtonView : UIView
- (id)initAtPosition:(CGPoint)position withEmotion:(HONEmotionVO *)emotionVO withDelay:(CGFloat)delay;

@property (nonatomic, assign) id<HONStickerButtonViewDelegate> delegate;
@end