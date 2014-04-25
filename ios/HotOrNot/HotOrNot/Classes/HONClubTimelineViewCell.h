//
//  HONClubTimelineViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/25/2014 @ 11:00 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONUserClubVO.h"

@interface HONClubTimelineViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, retain) HONUserClubVO *userClubVO;
@end
