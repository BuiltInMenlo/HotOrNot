//
//  HONVoterViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONVoterVO.h"

@interface HONVoterViewCell : UITableViewCell

+ (NSString *)cellReuseIdentifier;

- (id)initAsTopCell;
- (id)initAsBottomCell;
- (id)initAsMidCell;

@property (nonatomic, strong) HONVoterVO *voterVO;

@end
