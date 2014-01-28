//
//  HONMessageRecipientViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 01/22/2014 @ 14:49.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONTrivialUserVO.h"

@protocol HONMessageRecipientViewCellDelegate;
@interface HONMessageRecipientViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)toggleSelected;

@property (nonatomic, strong) HONTrivialUserVO *userVO;
@property (nonatomic, assign) id <HONMessageRecipientViewCellDelegate> delegate;
@end


@protocol HONMessageRecipientViewCellDelegate <NSObject>
- (void)messageRecipientViewCell:(HONMessageRecipientViewCell *)recipientViewCell toggleSelected:(BOOL)isSelected forRecipient:(HONTrivialUserVO *)userVO;
@end