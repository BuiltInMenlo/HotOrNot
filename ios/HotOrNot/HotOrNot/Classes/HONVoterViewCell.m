//
//  HONVoterViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+AFNetworking.h"

#import "HONVoterViewCell.h"
#import "HONAppDelegate.h"

@interface HONVoterViewCell()
@end

@implementation HONVoterViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		[self hideChevron];
	}
	
	return (self);
}

- (void)setVoterVO:(HONVoterVO *)voterVO {
	_voterVO = voterVO;
	
	//NSLog(@"IMG:[%@]", _voterVO.imageURL);
	UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14.0, 12.0, 38.0, 38.0)];
	userImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	[userImageView setImageWithURL:[NSURL URLWithString:_voterVO.imageURL] placeholderImage:nil];
	[self addSubview:userImageView];
	
	UILabel *voteLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 23.0, 220.0, 16.0)];
	voteLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:11];
	voteLabel.textColor = [HONAppDelegate honGreyTxtColor];
	voteLabel.backgroundColor = [UIColor clearColor];
	voteLabel.text = [NSString stringWithFormat:NSLocalizedString(@"voters_caption", nil), _voterVO.username, _voterVO.challengerName];
	[self addSubview:voteLabel];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(246.0, 23.0, 60.0, 16.0)];
	timeLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:11];
	timeLabel.textColor = [HONAppDelegate honGreyTxtColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = [HONAppDelegate timeSinceDate:_voterVO.addedDate];
	[self addSubview:timeLabel];
}

@end
