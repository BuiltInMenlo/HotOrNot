//
//  HONGlobalEmotionPickerView.h
//  HotOrNot
//
//  Created by Eric on 8/18/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONEmotionVO.h"

@class HONGlobalEmotionPickerView;
@protocol HONGlobalEmotionPickerViewDelegate <NSObject>
- (void)globalEmotionsPickerView:(HONGlobalEmotionPickerView *)emotionsPickerView globalButton:(BOOL)isSelected;
- (void)emotionsPickerView:(HONGlobalEmotionPickerView *)emotionsPickerView selectedEmotion:(HONEmotionVO *)emotionVO;
- (void)emotionsPickerView:(HONGlobalEmotionPickerView *)emotionsPickerView deselectedEmotion:(HONEmotionVO *)emotionVO;
- (void)emotionsPickerView:(HONGlobalEmotionPickerView *)emotionsPickerView didChangeToPage:(int)page withDirection:(int)direction;
@end

@interface HONGlobalEmotionPickerView : UIView <UIAlertViewDelegate, UIScrollViewDelegate>
- (void)scrollToPage:(int)page;
@property (nonatomic, assign) id <HONGlobalEmotionPickerViewDelegate> delegate;
@end
