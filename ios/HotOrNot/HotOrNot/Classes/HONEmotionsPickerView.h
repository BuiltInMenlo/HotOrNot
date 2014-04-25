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
#define ITEM_SPACING	74.0f

@class HONEmotionsPickerView;
@protocol HONEmotionsPickerViewDelegate <NSObject>
- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView selectedEmotion:(HONEmotionVO *)emotionVO;
- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView deselectedEmotion:(HONEmotionVO *)emotionVO;
@end

@interface HONEmotionsPickerView : UIView <UIScrollViewDelegate>
@property (nonatomic, assign) id <HONEmotionsPickerViewDelegate> delegate;
@end