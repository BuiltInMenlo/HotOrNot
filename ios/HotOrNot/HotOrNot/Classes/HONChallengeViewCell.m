//
//  HONChallengeViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

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
			_loadMoreButton.frame = CGRectMake(108.0, 15.0, 103.0, 34.0);
			[_loadMoreButton setBackgroundImage:[UIImage imageNamed:@"loadMoreButton_nonActive"] forState:UIControlStateNormal];
			[_loadMoreButton setBackgroundImage:[UIImage imageNamed:@"loadMoreButton_Active"] forState:UIControlStateHighlighted];
			[_loadMoreButton addTarget:self action:@selector(_goLoadMore) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:_loadMoreButton];
			
//			UIButton *inviteSMSButton = [UIButton buttonWithType:UIButtonTypeCustom];
//			inviteSMSButton.frame = CGRectMake(68.0, 28.0, 184.0, 34.0);
//			[inviteSMSButton setBackgroundImage:[UIImage imageNamed:@"inviteFriendsViaSMS_nonActive"] forState:UIControlStateNormal];
//			[inviteSMSButton setBackgroundImage:[UIImage imageNamed:@"inviteFriendsViaSMS_nonActive"] forState:UIControlStateHighlighted];
//			[inviteSMSButton addTarget:self action:@selector(_goInviteSMS) forControlEvents:UIControlEventTouchUpInside];
//			[self addSubview:inviteSMSButton];
//			
//			UIButton *inviteEmailButton = [UIButton buttonWithType:UIButtonTypeCustom];
//			inviteEmailButton.frame = CGRectMake(68.0, 78.0, 184.0, 34.0);
//			[inviteEmailButton setBackgroundImage:[UIImage imageNamed:@"inviteFriendsViaEmail_nonActive"] forState:UIControlStateNormal];
//			[inviteEmailButton setBackgroundImage:[UIImage imageNamed:@"inviteFriendsViaEmail_Active"] forState:UIControlStateHighlighted];
//			[inviteEmailButton addTarget:self action:@selector(_goInviteEmail) forControlEvents:UIControlEventTouchUpInside];
//			[self addSubview:inviteEmailButton];
			
			[self hideChevron];
		}
	}
	
	return (self);
}


- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[self hideChevron];
	BOOL isCreator = [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _challengeVO.creatorID;
	
	UIImageView *hasSeenImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6.0, 23.0, 18.0, 18.0)];
	hasSeenImageView.image = [UIImage imageNamed:@"newSnapIcon"];
	hasSeenImageView.hidden = _challengeVO.hasViewed;
	[self addSubview:hasSeenImageView];
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(29.0, 13.0, 38.0, 38.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:(isCreator) ? _challengeVO.challengerAvatar : _challengeVO.creatorAvatar] placeholderImage:nil];
	[self addSubview:avatarImageView];
	
	UILabel *challengeLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 12.0, 180.0, 20.0)];
	challengeLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:16];
	challengeLabel.textColor = [HONAppDelegate honBlueTxtColor];
	challengeLabel.backgroundColor = [UIColor clearColor];
	challengeLabel.text = ([_challengeVO.status isEqualToString:@"Created"]) ? @"You snapped…" : [NSString stringWithFormat:@"@%@", (isCreator) ? _challengeVO.challengerName : _challengeVO.creatorName];
	[self addSubview:challengeLabel];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(86.0, 33.0, 200.0, 16.0)];
	subjectLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:13];
	subjectLabel.textColor = [HONAppDelegate honGreyTxtColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _challengeVO.subjectName;
	[self addSubview:subjectLabel];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(239.0, 9.0, 60.0, 16.0)];
	timeLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:11];
	timeLabel.textColor = [HONAppDelegate honGreyTxtColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = [HONAppDelegate timeSinceDate:_challengeVO.updatedDate];
	[self addSubview:timeLabel];
	
	UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(69.0, 28.0, 18.0, 18.0)];
	arrowImageView.image = [UIImage imageNamed:(isCreator) ? @"outboundArrow" : @"inboundArrow"];
	[self addSubview:arrowImageView];
	
	if ([_challengeVO.status isEqualToString:@"Created"]) {
		[avatarImageView setImageWithURL:[NSURL URLWithString:@"https://hotornot-avatars.s3.amazonaws.com/waitingAvatar.png"] placeholderImage:nil];
		//challengeLabel.text = NSLocalizedString(@"activity_waiting", nil);
		
	} else if ([_challengeVO.status isEqualToString:@"Waiting"]) {
		//challengeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"activity_outbound", nil), _challengeVO.challengerName];
		
	} else if ([_challengeVO.status isEqualToString:@"Accept"]) {
		//challengeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"activity_inbound", nil), _challengeVO.creatorName];
		
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

- (void)_goInviteSMS {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SMS_COMPOSER" object:nil];
}

- (void)_goInviteEmail {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_EMAIL_COMPOSER" object:nil];
}

@end
