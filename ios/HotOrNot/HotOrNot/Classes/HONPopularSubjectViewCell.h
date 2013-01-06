//
//  HONPopularSubjectViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONAlternatingRowsViewCell.h"
#import "HONPopularSubjectVO.h"

@interface HONPopularSubjectViewCell : HONAlternatingRowsViewCell
+ (NSString *)cellReuseIdentifier;
@property (nonatomic, strong) HONPopularSubjectVO *subjectVO;
@end
