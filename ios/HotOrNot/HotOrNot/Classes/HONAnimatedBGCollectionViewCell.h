//
//  HONAnimatedCollectionBGViewCell.h
//  HotOrNot
//
//  Created by BIM  on 10/22/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONCollectionViewCell.h"
#import "HONEmotionVO.h"

@class HONAnimatedBGCollectionViewCell;
@protocol HONAnimatedBGCollectionViewCellDelegate <HONCollectionViewCellDelegate>
- (void)animatedBGCollectionViewCell:(HONAnimatedBGCollectionViewCell *)viewCell didSelectEmotion:(HONEmotionVO *)emotionVO;
@end

@interface HONAnimatedBGCollectionViewCell : HONCollectionViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, retain) HONEmotionVO *emotionVO;
@property (nonatomic, assign) id <HONAnimatedBGCollectionViewCellDelegate> delegate;
@end
