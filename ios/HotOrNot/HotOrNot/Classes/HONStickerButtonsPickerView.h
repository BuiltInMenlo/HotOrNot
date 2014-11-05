//
//  HONStickerButtonsPickerView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONEmotionVO.h"

#define COLS_PER_ROW	4
#define ROWS_PER_PAGE	2

@class HONStickerButtonsPickerView;
@protocol HONStickerButtonsPickerViewDelegate <NSObject>
- (void)stickerButtonsPickerView:(HONStickerButtonsPickerView *)stickerButtonsPickerView selectedEmotion:(HONEmotionVO *)emotionVO;
- (void)stickerButtonsPickerViewDidStartDownload:(HONStickerButtonsPickerView *)stickerButtonsPickerView;
@optional
- (void)stickerButtonsPickerView:(HONStickerButtonsPickerView *)stickerButtonsPickerView didFinishDownloadingForContentGroupID:(NSString *)contentGroupID;
- (void)stickerButtonsPickerView:(HONStickerButtonsPickerView *)stickerButtonsPickerView deselectedEmotion:(HONEmotionVO *)emotionVO;
- (void)stickerButtonsPickerView:(HONStickerButtonsPickerView *)stickerButtonsPickerView didChangeToPage:(int)page withDirection:(int)direction;
@end

@interface HONStickerButtonsPickerView : UIView <UIScrollViewDelegate>
- (id)initWithFrame:(CGRect)frame asGroupIndex:(int)stickerGroupIndex;
- (void)appendPurchasedStickersWithContentGroupID:(NSString *)contentGroupID;
- (void)cacheAllStickerContent;
- (void)cacheStickerContentInRange:(NSRange)range;
- (void)disablePagesStartingAt:(int)page;
- (void)scrollToPage:(int)page;
- (void)scrollToFirstPage;
- (void)scrollToLastPage;

@property (nonatomic, assign) int stickerGroupIndex;
@property (nonatomic, assign) id <HONStickerButtonsPickerViewDelegate> delegate;
@end
