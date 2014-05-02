//
//  HONAlertItemViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 12/02/2013 @ 20:11 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONBaseRowViewCell.h"
#import "HONActivityItemVO.h"

@class HONActivityItemViewCell;
@protocol HONActivityItemViewCellDelegate <NSObject>
- (void)activityItemViewCell:(HONActivityItemViewCell *)cell selectedActivityItem:(HONActivityItemVO *)activityItemVO;
@end

@interface HONActivityItemViewCell : HONBaseRowViewCell

@property (nonatomic, assign) id <HONActivityItemViewCellDelegate> delegate;
@property (nonatomic, retain) HONActivityItemVO *activityItemVO;
@end
