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
@property (nonatomic, strong) UIImageView *hasSeenImageView;
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
			_loadMoreButton.frame = CGRectMake(53.0, 0.0, 214.0, 64.0);
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
	
	[self hideChevron];
	BOOL isCreator = [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _challengeVO.creatorID;
	
	_hasSeenImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6.0, 23.0, 18.0, 18.0)];
	_hasSeenImageView.image = [UIImage imageNamed:@"newSnapIcon"];
	_hasSeenImageView.hidden = _challengeVO.hasViewed;
	[self addSubview:_hasSeenImageView];
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(28.0, 12.0, 38.0, 38.0)];
	avatarImageView.backgroundColor = [UIColor colorWithWhite:0.33 alpha:1.0];
	[avatarImageView setImageWithURL:[NSURL URLWithString:(isCreator) ? _challengeVO.challengerAvatar : _challengeVO.creatorAvatar] placeholderImage:nil];
	[self addSubview:avatarImageView];
	
	UILabel *challengeLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 16.0, 180.0, 20.0)];
	challengeLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:16];
	challengeLabel.textColor = [HONAppDelegate honBlueTxtColor];
	challengeLabel.backgroundColor = [UIColor clearColor];
	challengeLabel.text = ([_challengeVO.status isEqualToString:@"Created"]) ? @"You snapped…" : [NSString stringWithFormat:@"@%@", (isCreator) ? _challengeVO.challengerName : _challengeVO.creatorName];
	[self addSubview:challengeLabel];
	
	UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(69.0, 34.0, 18.0, 18.0)];
	arrowImageView.image = [UIImage imageNamed:(isCreator) ? @"outboundArrow" : @"inboundArrow"];
	//[self addSubview:arrowImageView];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 35.0, 200.0, 18.0)];
	subjectLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:15];
	subjectLabel.textColor = [HONAppDelegate honGrey455Color];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _challengeVO.subjectName;
	[self addSubview:subjectLabel];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(177.0, 23.0, 60.0, 16.0)];
	timeLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:11];
	timeLabel.textColor = [HONAppDelegate honGrey635Color];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = [HONAppDelegate timeSinceDate:_challengeVO.updatedDate];
	[self addSubview:timeLabel];
	
	UIView *challengeImgHolderView = [[UIView alloc] initWithFrame:CGRectMake(257.0, 0.0, 63.0, 63.0)];
	challengeImgHolderView.clipsToBounds = YES;
	[self addSubview:challengeImgHolderView];
	
	UIImageView *challengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -10, 63.0, 84.0)];
	challengeImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	[challengeImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_t.jpg", (isCreator && (![_challengeVO.status isEqualToString:@"Created"] && ![_challengeVO.status isEqualToString:@"Waiting"])) ? _challengeVO.challengerImgPrefix : _challengeVO.creatorImgPrefix]] placeholderImage:nil];
	[challengeImgHolderView addSubview:challengeImageView];
	
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

- (void)toggleLoadMore:(BOOL)isEnabled {
	if (isEnabled) {
		[_loadMoreButton addTarget:self action:@selector(_goLoadMore) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_loadMoreButton];
	
	} else {
		[_loadMoreButton removeTarget:self action:@selector(_goLoadMore) forControlEvents:UIControlEventTouchUpInside];
		[_loadMoreButton removeFromSuperview];
		
		UIButton *findFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		findFriendsButton.frame = CGRectMake(24.0, 9.0, 224.0, 44.0);
		[findFriendsButton setBackgroundImage:[UIImage imageNamed:@"findFriendsWhoVolley"] forState:UIControlStateNormal];
		[findFriendsButton setBackgroundImage:[UIImage imageNamed:@"findFriendsWhoVolley"] forState:UIControlStateHighlighted];
		[findFriendsButton addTarget:self action:@selector(_goFindFriends) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:findFriendsButton];
		
		UIImageView *chevronImageView = [[UIImageView alloc] initWithFrame:CGRectMake(285.0, 20.0, 24.0, 24.0)];
		chevronImageView.image = [UIImage imageNamed:@"chevron"];
		[self addSubview:chevronImageView];
		
//		UIView *whiteOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kDefaultCellHeight)];
//		whiteOverlayView.backgroundColor = [UIColor whiteColor];
//		[self addSubview:whiteOverlayView];
	}
}

- (void)disableLoadMore {
	[_loadMoreButton removeTarget:self action:@selector(_goLoadMore) forControlEvents:UIControlEventTouchUpInside];
	[_loadMoreButton removeFromSuperview];
	
//	UIView *whiteOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kDefaultCellHeight)];
//	whiteOverlayView.backgroundColor = [UIColor whiteColor];
//	[self addSubview:whiteOverlayView];
	
	UIButton *findFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	findFriendsButton.frame = CGRectMake(24.0, 9.0, 224.0, 44.0);
	[findFriendsButton setBackgroundImage:[UIImage imageNamed:@"findFriendsWhoVolley"] forState:UIControlStateNormal];
	[findFriendsButton setBackgroundImage:[UIImage imageNamed:@"findFriendsWhoVolley"] forState:UIControlStateHighlighted];
	[findFriendsButton addTarget:self action:@selector(_goFindFriends) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:findFriendsButton];
	
	UIImageView *chevronImageView = [[UIImageView alloc] initWithFrame:CGRectMake(285.0, 20.0, 24.0, 24.0)];
	chevronImageView.image = [UIImage imageNamed:@"chevron"];
	[self addSubview:chevronImageView];
}

- (void)updateHasSeen {
	_hasSeenImageView.hidden = YES;
}

#pragma mark - Navigation
- (void)_goLoadMore {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NEXT_CHALLENGE_BLOCK" object:nil];
}

- (void)_goFindFriends {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_FIND_FRIENDS" object:nil];
}


@end
