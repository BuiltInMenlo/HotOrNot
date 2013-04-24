//
//  HONChallengerViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.23.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONUserVO.h"

@interface HONChallengerViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;
- (id)initAsRandomUser:(BOOL)isAnonymous;
- (void)didSelect;
@property (nonatomic, strong) HONUserVO *userVO;
@end
