//
//  HONChallengerViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.23.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONUserVO.h"
#import "HONGenericRowViewCell.h"

@interface HONChallengerViewCell : HONGenericRowViewCell
+ (NSString *)cellReuseIdentifier;
- (id)initAsRandomUser:(BOOL)isAnonymous;

@property (nonatomic, strong) HONUserVO *userVO;
@end
