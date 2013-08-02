//
//  HONUserProfileRequestViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 7/28/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONUserVO.h"

@protocol HONUserProfileRequestViewCellDelegate;
@interface HONUserProfileRequestViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, retain) NSString *avatarURL;
@property (nonatomic, retain) HONUserVO *userVO;

@property (nonatomic, assign) id <HONUserProfileRequestViewCellDelegate> delegate;
@end

@protocol HONUserProfileRequestViewCellDelegate
- (void)profileRequestViewCellDoneAnimating:(HONUserProfileRequestViewCell *)profileRequestViewCell;
- (void)profileRequestViewCell:(HONUserProfileRequestViewCell *)profileRequestViewCell reportAbuse:(HONUserVO *)vo;
- (void)profileRequestViewCell:(HONUserProfileRequestViewCell *)profileRequestViewCell sendRequest:(HONUserVO *)vo;
@end
