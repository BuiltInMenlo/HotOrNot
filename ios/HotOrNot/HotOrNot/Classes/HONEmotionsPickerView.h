//
//  HONEmotionsPickerView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONEmotionVO.h"

#define COLS_PER_ROW	4
#define ROWS_PER_PAGE	3

@class HONEmotionsPickerView;
@protocol HONEmotionsPickerViewDelegate <NSObject>
- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView globalButton:(BOOL)isSelected;
- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView selectedEmotion:(HONEmotionVO *)emotionVO;
- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView deselectedEmotion:(HONEmotionVO *)emotionVO;
- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView didChangeToPage:(int)page withDirection:(int)direction;
@end

@interface HONEmotionsPickerView : UIView <UIScrollViewDelegate>
- (void)scrollToPage:(int)page;
- (void)reload;
@property (nonatomic, assign) id <HONEmotionsPickerViewDelegate> delegate;
@end
