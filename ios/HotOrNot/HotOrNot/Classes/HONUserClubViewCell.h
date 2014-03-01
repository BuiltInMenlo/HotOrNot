//
//  HONUserClubViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/01/2014 @ 13:15 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONUserClubVO.h"


@protocol HONUserClubViewCellDelegate;
@interface HONUserClubViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, strong) HONUserClubVO *userClubVO;
@property (nonatomic, assign) id <HONUserClubViewCellDelegate> delegate;
@end


@protocol HONUserClubViewCellDelegate <NSObject>
- (void)userClubViewCell:(HONUserClubViewCell *)cell settingsForClub:(HONUserClubVO *)userClubVO;
@end
