//
//  HONMessageReplyViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 01/19/2014 @ 16:07.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONOpponentVO.h"


@protocol HONMessageReplyViewCellDelegate;
@interface HONMessageReplyViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, strong) HONOpponentVO *messageReplyVO;
@property (nonatomic, assign) id <HONMessageReplyViewCellDelegate> delegate;
@end


@protocol HONMessageItemViewCellDelegate <NSObject>
@end