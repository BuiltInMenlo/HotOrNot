//
//  HONChallengeViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONAlternatingRowsViewCell.h"
#import "HONChallengeVO.h"

@interface HONChallengeViewCell : HONAlternatingRowsViewCell
+ (NSString *)cellReuseIdentifier;
- (id)initAsGreyChallengeCell:(BOOL)grey;
- (id)initAsGreyBottomCell:(BOOL)grey isEnabled:(BOOL)enabled;

@property (nonatomic, strong) HONChallengeVO *challengeVO;
@end
