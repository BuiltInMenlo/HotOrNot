//
//  HONUserProfileViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 2/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONUserVO.h"

@interface HONUserProfileViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, retain) HONUserVO *userVO;
@end
