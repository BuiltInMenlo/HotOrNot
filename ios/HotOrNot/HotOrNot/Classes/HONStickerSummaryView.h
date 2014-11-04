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
- (void)stickerSummaryView:(HONStickerSummaryView *)stickerSummaryView didSelectThumb:(HONEmotionVO *)emotionVO atIndex:(int)index;
- (void)stickerSummaryView:(HONStickerSummaryView *)stickerSummaryView deleteLastSticker:(HONEmotionVO *)emotionVO;
@end

@interface HONStickerSummaryView : UIView <UIGestureRecognizerDelegate, UIScrollViewDelegate>
- (id)initAtPosition:(CGPoint)position withHeight:(CGFloat)height;
- (void)appendSticker:(HONEmotionVO *)emotionVO;
- (void)appendStickerAndSelect:(HONEmotionVO *)emotionVO;
- (void)removeStickerAtIndex:(int)index;
- (void)removeLastSticker;
- (void)scrollToStickerAtIndex:(int)index;
- (void)selectStickerAtIndex:(int)index;

@property (nonatomic, assign) id <HONStickerSummaryViewDelegate> delegate;
@end
