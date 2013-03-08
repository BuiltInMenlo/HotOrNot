//
//  HONDiscoveryViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.07.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"

@interface HONDiscoveryViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;
- (void)didSelectLeftChallenge;
- (void)didSelectRightChallenge;
@property (nonatomic, retain) HONChallengeVO *lChallengeVO;
@property (nonatomic, retain) HONChallengeVO *rChallengeVO;

@end
