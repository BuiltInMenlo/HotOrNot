//
//  HONChallengeViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONGenericRowViewCell.h"
#import "HONChallengeVO.h"

@interface HONChallengeViewCell : HONGenericRowViewCell
+ (NSString *)cellReuseIdentifier;

- (void)disableLoadMore;
- (void)toggleLoadMore:(BOOL)isEnabled;
- (id)initAsBottomCell:(BOOL)isBottom;
- (void)updateHasSeen;

@property (nonatomic, strong) HONChallengeVO *challengeVO;
@end
