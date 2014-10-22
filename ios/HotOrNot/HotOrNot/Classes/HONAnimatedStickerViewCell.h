//
//  HONAnimatedStickerViewCell.h
//  HotOrNot
//
//  Created by BIM  on 10/22/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"
#import "HONEmotionVO.h"

@class HONAnimatedStickerViewCell;
@protocol HONAnimatedStickerViewCellDelegate <NSObject>
- (void)animatedStickerCell:(HONAnimatedStickerViewCell *)cell selectedEmotion:(HONEmotionVO *)emotionVO;
@end

@interface HONAnimatedStickerViewCell : HONTableViewCell
@property (nonatomic, retain) HONEmotionVO *emotionVO;
@property (nonatomic, assign) id <HONAnimatedStickerViewCellDelegate> delegate;
@end
