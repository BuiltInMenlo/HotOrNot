//
//  HONVoteItemViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HONChallengeVO.h"

@interface HONVoteItemViewCell : UITableViewCell

+ (NSString *)cellReuseIdentifier;
- (id)initAsTopCell:(int)points withSubject:(NSString *)subject;
- (id)initAsWaitingCell;
- (id)initAsStartedCell;
@property (nonatomic, strong) HONChallengeVO *challengeVO;

@end
