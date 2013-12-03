//
//  HONSearchSubjectViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 3/17/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONGenericRowViewCell.h"
#import "HONSearchSubjectVO.h"

@interface HONSearchSubjectViewCell : HONGenericRowViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, strong) HONSearchSubjectVO *subjectVO;
@end
