//
//  HONSearchSubjectViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 3/17/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONGenericRowViewCell.h"
#import "HONSubjectVO.h"

@interface HONSearchSubjectViewCell : HONGenericRowViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, strong) HONSubjectVO *subjectVO;
@end
