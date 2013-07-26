//
//  HONUserProfileViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 2/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"

#import "HONUserProfileViewCell.h"
#import "HONAppDelegate.h"
#import "HONImageLoadingView.h"
#import "HONImagingDepictor.h"

#define kStatsColor [UIColor colorWithRed:0.227 green:0.380 blue:0.349 alpha:1.0]


@interface HONUserProfileViewCell()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *snapsLabel;
@property (nonatomic, strong) UILabel *votesLabel;
@property (nonatomic, strong) UILabel *ptsLabel;
@end

@implementation HONUserProfileViewCell
@synthesize delegate = _delegate;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profileBackground"]];
		[self addSubview:bgImageView];
	}
	
	return (self);
}

- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
	
	[self addSubview:[[HONImageLoadingView alloc] initAtPos:CGPointMake(127.0, 31.0)]];
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(113.0, 17.0, 93.0, 93.0)];
	_avatarImageView.userInteractionEnabled = YES;
	[self addSubview:_avatarImageView];
	
	BOOL isUser = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID);
	if (isUser) {
		[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]]
																  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
															  timeoutInterval:3] placeholderImage:nil success:nil failure:nil];
	
	} else {
		[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_userVO.imageURL]
																  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
															  timeoutInterval:3] placeholderImage:nil success:nil failure:nil];//^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
	}
	
	
	BOOL isFriend = NO;
	if (!isUser) {
		for (HONUserVO *vo in [HONAppDelegate friendsList]) {
			if (vo.userID == _userVO.userID) {
				isFriend = YES;
				break;
			}
		}
	}
	
	UIButton *profilePicButton = [UIButton buttonWithType:UIButtonTypeCustom];
	profilePicButton.frame = _avatarImageView.frame;
	[profilePicButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
	[profilePicButton addTarget:self action:@selector(_goProfilePic) forControlEvents:UIControlEventTouchUpInside];
	profilePicButton.hidden = !isUser;
	[self addSubview:profilePicButton];
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	float yPos = 124.0;
	
	//_votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, yPos, 80.0, 16.0)];
	_votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(35.0, yPos, 80.0, 16.0)];
	_votesLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
	_votesLabel.textColor = kStatsColor;
	_votesLabel.backgroundColor = [UIColor clearColor];
	_votesLabel.textAlignment = NSTextAlignmentCenter;
	_votesLabel.text = [NSString stringWithFormat:(_userVO.votes == 1) ? NSLocalizedString(@"profile_vote", nil) : NSLocalizedString(@"profile_votes", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]]];
	[self addSubview:_votesLabel];
	
	UILabel *dots1Label = [[UILabel alloc] initWithFrame:CGRectMake(105.0, yPos - 2.0, 20.0, 20.0)];
	dots1Label.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:14];
	dots1Label.textColor = kStatsColor;
	dots1Label.backgroundColor = [UIColor clearColor];
	dots1Label.textAlignment = NSTextAlignmentCenter;
	dots1Label.text = @"•";
	[self addSubview:dots1Label];
	
	_snapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, yPos, 80.0, 16.0)];
	_snapsLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
	_snapsLabel.textColor = kStatsColor;
	_snapsLabel.backgroundColor = [UIColor clearColor];
	_snapsLabel.textAlignment = NSTextAlignmentCenter;
	_snapsLabel.text = [NSString stringWithFormat:(_userVO.pics == 1) ? NSLocalizedString(@"profile_snap", nil) : NSLocalizedString(@"profile_snaps", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]]];
	[self addSubview:_snapsLabel];
	
	UILabel *dots2Label = [[UILabel alloc] initWithFrame:CGRectMake(195.0, yPos - 2.0, 20.0, 20.0)];
	dots2Label.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:14];
	dots2Label.textColor = kStatsColor;
	dots2Label.backgroundColor = [UIColor clearColor];
	dots2Label.textAlignment = NSTextAlignmentCenter;
	dots2Label.text = @"•";
	[self addSubview:dots2Label];
	
	_ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(211.0, yPos, 80.0, 16.0)];
	_ptsLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
	_ptsLabel.textColor = kStatsColor;
	_ptsLabel.backgroundColor = [UIColor clearColor];
	_ptsLabel.textAlignment = NSTextAlignmentCenter;
	_ptsLabel.text = [NSString stringWithFormat:(_userVO.score == 1) ? NSLocalizedString(@"profile_point", nil) : NSLocalizedString(@"profile_points", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.score]]];
	[self addSubview:_ptsLabel];
	
	UIButton *statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
	statusButton.frame = CGRectMake(21.0, 152.0, 129.0, 44.0);
	[statusButton setBackgroundImage:[UIImage imageNamed:@"statusButton_nonActive"] forState:UIControlStateNormal];
	[statusButton setBackgroundImage:[UIImage imageNamed:@"statusButton_Active"] forState:UIControlStateHighlighted];
	[statusButton addTarget:self action:@selector(_goNewSnap) forControlEvents:UIControlEventTouchUpInside];
	statusButton.hidden = !isUser;
	[self addSubview:statusButton];
	
	UIButton *findFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	findFriendsButton.frame = CGRectMake(168.0, 152.0, 129.0, 44.0);
	[findFriendsButton setBackgroundImage:[UIImage imageNamed:@"friendsButton_nonActive"] forState:UIControlStateNormal];
	[findFriendsButton setBackgroundImage:[UIImage imageNamed:@"friendsButton_Active"] forState:UIControlStateHighlighted];
	[findFriendsButton addTarget:self action:@selector(_goFindFriends) forControlEvents:UIControlEventTouchUpInside];
	findFriendsButton.hidden = !isUser;
	[self addSubview:findFriendsButton];
	
	UIButton *snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
	snapButton.frame = CGRectMake(21.0, 152.0, 129.0, 44.0);
	[snapButton setBackgroundImage:[UIImage imageNamed:@"photoMessageButton_nonActive"] forState:UIControlStateNormal];
	[snapButton setBackgroundImage:[UIImage imageNamed:@"photoMessageButton_Active"] forState:UIControlStateHighlighted];
	[snapButton addTarget:self action:@selector(_goUserChallenge) forControlEvents:UIControlEventTouchUpInside];
	snapButton.hidden = isUser;
	[self addSubview:snapButton];
	
	UIButton *addFriendButton = [UIButton buttonWithType:UIButtonTypeCustom];
	addFriendButton.frame = CGRectMake(168.0, 152.0, 129.0, 44.0);
	[addFriendButton setBackgroundImage:[UIImage imageNamed:@"addFriendButton_nonActive"] forState:UIControlStateNormal];
	[addFriendButton setBackgroundImage:[UIImage imageNamed:@"addFriendButton_Active"] forState:UIControlStateHighlighted];
	[addFriendButton addTarget:self action:@selector(_goAddFriend) forControlEvents:UIControlEventTouchUpInside];
	addFriendButton.hidden = isUser;
	[self addSubview:addFriendButton];
}

- (void)updateCell {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	_snapsLabel.text = [NSString stringWithFormat:(_userVO.pics == 1) ? NSLocalizedString(@"profile_snap", nil) : NSLocalizedString(@"profile_snaps", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]]];
	_votesLabel.text = [NSString stringWithFormat:(_userVO.votes == 1) ? NSLocalizedString(@"profile_vote", nil) : NSLocalizedString(@"profile_votes", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]]];
	_ptsLabel.text = [NSString stringWithFormat:(_userVO.score == 1) ? NSLocalizedString(@"profile_point", nil) : NSLocalizedString(@"profile_points", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.score]]];
}


#pragma mark - Navigation
- (void)_goProfilePic {
	[self.delegate userProfileViewCellTakeNewAvatar:self];
}

- (void)_goNewSnap {
	[self.delegate userProfileViewCellNewSnap:self];
}

- (void)_goSettings {
	[self.delegate userProfileViewCellShowSettings:self];
}

- (void)_goFindFriends {
	[self.delegate userProfileViewCellFindFriends:self];
}

- (void)_goTimeline {
	[self.delegate userProfileViewCell:self showUserTimeline:_userVO];
}

- (void)_goAddFriend {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REMOVE_VERIFY" object:nil];
	
	[self.delegate userProfileViewCell:self addFriend:_userVO];
}

- (void)_goUserChallenge {
	[self.delegate userProfileViewCell:self snapAtUser:_userVO];
}


@end
