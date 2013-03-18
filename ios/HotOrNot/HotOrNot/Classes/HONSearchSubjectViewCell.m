//
//  HONSearchSubjectViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 3/17/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONSearchSubjectViewCell.h"
#import "HONAppDelegate.h"

@implementation HONSearchSubjectViewCell

@synthesize subjectVO = _subjectVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (void)setSubjectVO:(HONSubjectVO *)subjectVO {
	_subjectVO = subjectVO;
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(27.0, 18.0, 200.0, 16.0)];
	subjectLabel.font = [[HONAppDelegate freightSansBlack] fontWithSize:14];
	subjectLabel.textColor = [UIColor blackColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _subjectVO.subjectName;
	[self addSubview:subjectLabel];
	
	UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(27.0, 35.0, 200.0, 16.0)];
	scoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
	scoreLabel.textColor = [HONAppDelegate honGreyTxtColor];
	scoreLabel.backgroundColor = [UIColor clearColor];
	scoreLabel.text = (_subjectVO.score == 1) ? @"1 challenge" : [NSString stringWithFormat:@"%d challenges", _subjectVO.score];
	[self addSubview:scoreLabel];
}

@end
