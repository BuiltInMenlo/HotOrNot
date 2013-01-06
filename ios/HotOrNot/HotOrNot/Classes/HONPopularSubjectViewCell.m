//
//  HONPopularSubjectViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONPopularSubjectViewCell.h"
#import "HONAppDelegate.h"

@interface HONPopularSubjectViewCell()
@end

@implementation HONPopularSubjectViewCell

@synthesize subjectVO = _subjectVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (void)setSubjectVO:(HONPopularSubjectVO *)subjectVO {
	_subjectVO = subjectVO;
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 19.0, 200.0, 16.0)];
	subjectLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
	subjectLabel.textColor = [HONAppDelegate honBlueTxtColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _subjectVO.subjectName;
	[self addSubview:subjectLabel];
	
	UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 36.0, 200.0, 16.0)];
	scoreLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:12];
	scoreLabel.textColor = [HONAppDelegate honBlueTxtColor];
	scoreLabel.backgroundColor = [UIColor clearColor];
	scoreLabel.text = (_subjectVO.score == 1) ? @"1 challenge" : [NSString stringWithFormat:@"%d challenges", _subjectVO.score];
	[self addSubview:scoreLabel];
}

- (void)_goChallenge {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"POPULAR_SUBJECT_CHALLENGE" object:_subjectVO];
}

@end
