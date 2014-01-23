//
//  HONMessageItemViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 01/18/2014 @ 20:19 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONMessageVO.h"

@protocol HONMessageItemViewCellDelegate;
@interface HONMessageItemViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)showTapOverlay;
- (void)updateAsSeen;

@property (nonatomic, strong) HONMessageVO *messageVO;
@property (nonatomic, assign) id <HONMessageItemViewCellDelegate> delegate;
@end

@protocol HONMessageItemViewCellDelegate <NSObject>
- (void)messageItemViewCell:(HONMessageItemViewCell *)cell showProfileForUserID:(int)userID forMessage:(HONMessageVO *)messageVO;
- (void)messageItemViewCell:(HONMessageItemViewCell *)cell showMessage:(HONMessageVO *)messageVO;
@end