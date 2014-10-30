//
//  HONStickerSummaryView.h
//  HotOrNot
//
//  Created by BIM  on 10/29/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONEmotionVO.h"

@class HONStickerSummaryView;
@protocol HONStickerSummaryViewDelegate <NSObject>
@optional
- (void)stickerSummaryView:(HONStickerSummaryView *)stickerSummaryView didSelectThumb:(HONEmotionVO *)emotionVO;
- (void)stickerSummaryView:(HONStickerSummaryView *)stickerSummaryView didSelectThumbAtIndex:(int)index;
@end

@interface HONStickerSummaryView : UIView <UIScrollViewDelegate>
- (id)initAtPosition:(CGPoint)position;
- (void)appendSticker:(HONEmotionVO *)emotionVO;
- (void)removeStickerAtIndex:(int)index;
- (void)removeLastSticker;
- (void)scrollToStickerAtIndex:(int)index;

@property (nonatomic, assign) int scrollThreshold;
@property (nonatomic, assign) id <HONStickerSummaryViewDelegate> delegate;
@end
