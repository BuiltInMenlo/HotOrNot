//
//  HONProfileViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.26.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HONUserVO.h"

@interface HONPastChallengerViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (id)initAsRandomUser:(BOOL)isAnonymous;
@property (nonatomic, retain) HONUserVO *userVO;
@end
