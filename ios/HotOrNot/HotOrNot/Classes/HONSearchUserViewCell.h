//
//  HONSearchUserViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 3/17/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONGenericRowViewCell.h"
#import "HONUserVO.h"

@interface HONSearchUserViewCell : HONGenericRowViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, strong) HONUserVO *userVO;
@end
