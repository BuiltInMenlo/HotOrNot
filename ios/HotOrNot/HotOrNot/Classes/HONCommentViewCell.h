//
//  HONCommentViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 02.20.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONBaseRowViewCell.h"
#import "HONCommentVO.h"

@interface HONCommentViewCell : HONBaseRowViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, strong) HONCommentVO *commentVO;
@end
