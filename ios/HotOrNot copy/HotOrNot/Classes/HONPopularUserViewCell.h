//
//  HONPopularUserViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONAlternatingRowsViewCell.h"
#import "HONPopularUserVO.h"

@interface HONPopularUserViewCell : HONAlternatingRowsViewCell
+ (NSString *)cellReuseIdentifier;
@property (nonatomic, strong) HONPopularUserVO *userVO;
@end
