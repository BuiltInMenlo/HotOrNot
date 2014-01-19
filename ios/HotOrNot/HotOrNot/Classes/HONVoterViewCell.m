//
//  HONVoterViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import "UIImageView+AFNetworking.h"

#import "HONVoterViewCell.h"
#import "HONColorAuthority.h"

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
	UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, 13.0, 38.0, 38.0)];
	[userImageView setImageWithURL:[NSURL URLWithString:_voterVO.imageURL] placeholderImage:nil];
	[self addSubview:userImageView];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(245.0, 24.0, 60.0, 16.0)];
	timeLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
	timeLabel.textColor = [UIColor colorWithRed:0.549 green:0.565 blue:0.565 alpha:1.0];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = [HONAppDelegate timeSinceDate:_voterVO.addedDate];
	[self addSubview:timeLabel];
	
	UILabel *voterLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 23.0, 220.0, 16.0)];
	voterLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:15];
	voterLabel.textColor = [[HONColorAuthority sharedInstance] honPercentGreyscaleColor:0.455];
	voterLabel.backgroundColor = [UIColor clearColor];
	voterLabel.text = [NSString stringWithFormat:NSLocalizedString(@"voters_caption", nil), _voterVO.username];
	[self addSubview:voterLabel];
}

@end
