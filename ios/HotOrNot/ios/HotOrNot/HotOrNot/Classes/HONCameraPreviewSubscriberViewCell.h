//
//  HONCameraPreviewSubscriberViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/24/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONUserVO.h"

@protocol HONCameraPreviewSubscriberViewCellDelegate;
@interface HONCameraPreviewSubscriberViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, retain) HONUserVO *userVO;
@property (nonatomic, assign) id <HONCameraPreviewSubscriberViewCellDelegate> delegate;

@end

@protocol HONCameraPreviewSubscriberViewCellDelegate
- (void)subscriberViewCell:(HONCameraPreviewSubscriberViewCell *)cameraPreviewSubscriberViewCell removeOpponent:(HONUserVO *)userVO;
@end