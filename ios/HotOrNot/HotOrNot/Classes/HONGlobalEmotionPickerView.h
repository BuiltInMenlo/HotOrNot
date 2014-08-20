//
//  HONGlobalEmotionPickerView.h
//  HotOrNot
//
//  Created by Eric on 8/18/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONEmotionVO.h"

#define COLS_PER_ROW	1
#define ROWS_PER_PAGE	1

@class HONGlobalEmotionPickerView;
@protocol HONGlobalEmotionPickerViewDelegate <NSObject>
- (void)globalEmotionsPickerView:(HONGlobalEmotionPickerView *)emotionsPickerView globalButton:(BOOL)isSelected;
- (void)emotionsPickerView:(HONGlobalEmotionPickerView *)emotionsPickerView selectedEmotion:(HONEmotionVO *)emotionVO;
- (void)emotionsPickerView:(HONGlobalEmotionPickerView *)emotionsPickerView deselectedEmotion:(HONEmotionVO *)emotionVO;
- (void)emotionsPickerViewShowActionSheet:(HONGlobalEmotionPickerView *)emotionsPickerView;
- (void)emotionsPickerView:(HONGlobalEmotionPickerView *)emotionsPickerView didChangeToPage:(int)page withDirection:(int)direction;
@end

@interface HONGlobalEmotionPickerView : UIView <UIScrollViewDelegate>
- (void)scrollToPage:(int)page;
@property (nonatomic, assign) id <HONGlobalEmotionPickerViewDelegate> delegate;
@end
