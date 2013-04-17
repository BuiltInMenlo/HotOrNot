//
//  HONChallengeViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+AFNetworking.h"

#import "HONChallengeViewCell.h"
#import "HONAppDelegate.h"

@interface HONChallengeViewCell()
@property (nonatomic, strong) UIButton *loadMoreButton;
@end

@implementation HONChallengeViewCell
@synthesize challengeVO = _challengeVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initAsBottomCell:(BOOL)isBottom {
	if ((self = [super init])) {
		if (isBottom) {
			_loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
			_loadMoreButton.frame = CGRectMake(107.0, 16.0, 106.0, 34.0);
			[_loadMoreButton setBackgroundImage:[UIImage imageNamed:@"loadMoreButton_nonActive"] forState:UIControlStateNormal];
			[_loadMoreButton setBackgroundImage:[UIImage imageNamed:@"loadMoreButton_Active"] forState:UIControlStateHighlighted];
			[_loadMoreButton addTarget:self action:@selector(_goLoadMore) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:_loadMoreButton];
			
			[self hideChevron];
		}
	}
	
	return (self);
}


- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	BOOL isCreator = [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _challengeVO.creatorID;
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(29.0, 13.0, 38.0, 38.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:(isCreator) ? _challengeVO.challengerAvatar : _challengeVO.creatorAvatar] placeholderImage:nil];
	avatarImageView.layer.cornerRadius = (int)[HONAppDelegate isRetina5] * 2.0;
	avatarImageView.clipsToBounds = YES;
	[self addSubview:avatarImageView];
	
	UILabel *challengeLabel = [[UILabel alloc] initWithFrame:CGRectMake(83.0, 16.0, 180.0, 16.0)];
	challengeLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:11];
	challengeLabel.textColor = [HONAppDelegate honGreyTxtColor];
	challengeLabel.backgroundColor = [UIColor clearColor];
	challengeLabel.text = ([_challengeVO.status isEqualToString:@"Created"]) ? @"You snapped…" : [NSString stringWithFormat:@"@%@", (isCreator) ? _challengeVO.challengerName : _challengeVO.creatorName];
	[self addSubview:challengeLabel];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(76.0, 36.0, 200.0, 16.0)];
	subjectLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
	subjectLabel.textColor = [HONAppDelegate honBlueTxtColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _challengeVO.subjectName;
	[self addSubview:subjectLabel];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(228.0, 6.0, 60.0, 16.0)];
	timeLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:11];
	timeLabel.textColor = [HONAppDelegate honGreyTxtColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = [HONAppDelegate timeSinceDate:_challengeVO.addedDate];
	[self addSubview:timeLabel];
	
	UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(76.0, 17.0, 5.0, 9.0)];
	arrowImageView.image = [UIImage imageNamed:(isCreator) ? @"outboundArrow" : @"inboundArrow"];
	[self addSubview:arrowImageView];
	
	if ([_challengeVO.status isEqualToString:@"Created"]) {
		[avatarImageView setImageWithURL:[NSURL URLWithString:@"https://hotornot-avatars.s3.amazonaws.com/waitingAvatar.png"] placeholderImage:nil];
		//challengeLabel.text = NSLocalizedString(@"activity_waiting", nil);
		
	} else if ([_challengeVO.status isEqualToString:@"Waiting"]) {
		//challengeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"activity_outbound", nil), _challengeVO.challengerName];
		
	} else if ([_challengeVO.status isEqualToString:@"Accept"]) {
		//challengeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"activity_inbound", nil), _challengeVO.creatorName];
		
		UIImageView *hasSeenImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3.0, 20.0, 24.0, 24.0)];
		hasSeenImageView.image = [UIImage imageNamed:@"newSnapIcon"];
		hasSeenImageView.hidden = _challengeVO.hasViewed;
		[self addSubview:hasSeenImageView];
		
	} else if ([_challengeVO.status isEqualToString:@"Flagged"]) {
		//challengeLabel.text = (_challengeVO.challengerID == 0) ? NSLocalizedString(@"activity_waiting_f", nil) : (isCreator) ? [NSString stringWithFormat:NSLocalizedString(@"activity_outbound_f", nil), _challengeVO.challengerName] : [NSString stringWithFormat:NSLocalizedString(@"activity_inbound_f", nil), _challengeVO.creatorName];
		
		if (_challengeVO.challengerID == 0)
			[avatarImageView setImageWithURL:[NSURL URLWithString:@"https://hotornot-avatars.s3.amazonaws.com/waitingAvatar.png"] placeholderImage:nil];
		
	} else if ([_challengeVO.status isEqualToString:@"Started"] || [_challengeVO.status isEqualToString:@"Completed"]) {
		//challengeLabel.text = (isCreator) ? [NSString stringWithFormat:NSLocalizedString(@"activity_outbound", nil), _challengeVO.challengerName] : [NSString stringWithFormat:NSLocalizedString(@"activity_inbound", nil), _challengeVO.creatorName];
	}
}


//- (void)willTransitionToState:(UITableViewCellStateMask)state {
//	[super willTransitionToState:state];
//
//	NSLog(@"willTransitionToState");
//	
//	if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask) {
//		for (UIView *subview in self.subviews) {
//			if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
//				UIImageView *deleteBtn = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
//				[deleteBtn setImage:[UIImage imageNamed:@"genericGrayButton_nonActive"]];
//				[[subview.subviews objectAtIndex:0] addSubview:deleteBtn];
//			}
//		}
//	}
//}

- (void)disableLoadMore {
	[_loadMoreButton removeTarget:self action:@selector(_goLoadMore) forControlEvents:UIControlEventTouchUpInside];
	[_loadMoreButton removeFromSuperview];
}

#pragma mark - Navigation
- (void)_goLoadMore {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NEXT_CHALLENGE_BLOCK" object:nil];
}

@end
