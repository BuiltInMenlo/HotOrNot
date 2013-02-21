//
//  HONCommentViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 02.20.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONAlternatingRowsViewCell.h"
#import "HONCommentVO.h"

@interface HONCommentViewCell : HONAlternatingRowsViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, strong) HONCommentVO *commentVO;
@end
