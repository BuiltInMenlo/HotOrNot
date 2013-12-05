//
//  HONAlertItemViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 12/02/2013 @ 20:11 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIImageView+AFNetworking.h"

#import "HONAlertItemVO.h"

@protocol HONAlertItemViewCellDelegate;
@interface HONAlertItemViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, assign) id <HONAlertItemViewCellDelegate> delegate;
@property (nonatomic, retain) HONAlertItemVO *alertItemVO;
@end


@protocol HONAlertItemViewCellDelegate
- (void)alertItemViewCell:(HONAlertItemViewCell *)cell alertItem:(HONAlertItemVO *)alertItemVO;
@end