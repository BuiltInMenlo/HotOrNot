//
//  HONVoterViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONBaseRowViewCell.h"
#import "HONVoterVO.h"

@interface HONVoterViewCell : HONBaseRowViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, strong) HONVoterVO *voterVO;
@end
