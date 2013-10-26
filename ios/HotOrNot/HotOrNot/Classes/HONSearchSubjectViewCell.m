//
//  HONSearchSubjectViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 3/17/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONSearchSubjectViewCell.h"


@implementation HONSearchSubjectViewCell

@synthesize subjectVO = _subjectVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (void)setSubjectVO:(HONSearchSubjectVO *)subjectVO {
	_subjectVO = subjectVO;
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(27.0, 18.0, 200.0, 16.0)];
	subjectLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:14];
	subjectLabel.textColor = [UIColor blackColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _subjectVO.subjectName;
	[self addSubview:subjectLabel];
	
	UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(27.0, 35.0, 200.0, 16.0)];
	scoreLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:12];
	scoreLabel.textColor = [HONAppDelegate honGrey635Color];
	scoreLabel.backgroundColor = [UIColor clearColor];
	scoreLabel.text = (_subjectVO.score == 1) ? NSLocalizedString(@"search_snap", nil) : [NSString stringWithFormat:NSLocalizedString(@"search_snaps", nil), _subjectVO.score];
	[self addSubview:scoreLabel];
}

@end
