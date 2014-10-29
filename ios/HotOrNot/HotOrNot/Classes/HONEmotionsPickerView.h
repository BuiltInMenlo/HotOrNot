//
//  HONEmotionsPickerView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONEmotionVO.h"

#define COLS_PER_ROW	4
#define ROWS_PER_PAGE	2

@class HONEmotionsPickerView;
@protocol HONEmotionsPickerViewDelegate <NSObject>
- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView selectedEmotion:(HONEmotionVO *)emotionVO;
//- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView deselectedEmotion:(HONEmotionVO *)emotionVO;
@optional
- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView didChangeToPage:(int)page withDirection:(int)direction;
@end

@interface HONEmotionsPickerView : UIView <UIScrollViewDelegate>
- (id)initWithFrame:(CGRect)frame asGroupIndex:(int)stickerGroupIndex;
- (void)preloadImages;
- (void)disablePagesStartingAt:(int)page;
- (void)scrollToPage:(int)page;

@property (nonatomic, assign) int stickerGroupIndex;
@property (nonatomic, assign) id <HONEmotionsPickerViewDelegate> delegate;
@end
