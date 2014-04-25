//
//  HONAlertItemViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 12/02/2013 @ 20:11 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONBaseRowViewCell.h"
#import "HONAlertItemVO.h"

@class HONAlertItemViewCell;
@protocol HONAlertItemViewCellDelegate <NSObject>
- (void)alertItemViewCell:(HONAlertItemViewCell *)cell alertItem:(HONAlertItemVO *)alertItemVO;
@end

@interface HONAlertItemViewCell : HONBaseRowViewCell

@property (nonatomic, assign) id <HONAlertItemViewCellDelegate> delegate;
@property (nonatomic, retain) HONAlertItemVO *alertItemVO;
@end
