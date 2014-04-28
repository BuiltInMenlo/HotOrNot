//
//  HONMessageItemViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 01/18/2014 @ 20:19 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONMessageVO.h"
#import "HONOpponentVO.h"

@class HONMessageItemViewCell;
@protocol HONMessageItemViewCellDelegate <NSObject>
- (void)messageItemViewCell:(HONMessageItemViewCell *)cell showProfileForParticipant:(HONOpponentVO *)opponentVO forMessage:(HONMessageVO *)messageVO;
@end

@interface HONMessageItemViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)showTapOverlay;
- (void)updateAsSeen;

@property (nonatomic, strong) HONMessageVO *messageVO;
@property (nonatomic, assign) id <HONMessageItemViewCellDelegate> delegate;
@end
