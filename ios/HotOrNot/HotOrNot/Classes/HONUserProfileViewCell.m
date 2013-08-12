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
#import "HONImageLoadingView.h"
#import "HONImagingDepictor.h"

#define kStatsColor [UIColor colorWithRed:0.227 green:0.380 blue:0.349 alpha:1.0]


@interface HONUserProfileViewCell()
@property (nonatomic, strong) UIImageView *avatarImageView;
@end

@implementation HONUserProfileViewCell
@synthesize delegate = _delegate;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		//[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profileBackground"]]];
	}
	
	return (self);
}

- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
	
	BOOL isUser = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID);
	[self addSubview:[[HONImageLoadingView alloc] initAtPos:CGPointMake(127.0, 31.0)]];
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(105.0, 10.0, 109.0, 109.0)];
	_avatarImageView.userInteractionEnabled = YES;
	[_avatarImageView setImageWithURL:[NSURL URLWithString:(isUser) ? [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"] : _userVO.imageURL] placeholderImage:nil];
	[self addSubview:_avatarImageView];
	
//	if (isUser) {
//		[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]]
//																  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//															  timeoutInterval:3] placeholderImage:nil success:nil failure:nil];
//	
//	} else {
//		[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_userVO.imageURL]
//																  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//															  timeoutInterval:3] placeholderImage:nil success:nil failure:nil];//^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
//	}
	
	
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
	profilePicButton.frame = CGRectMake(190.0, 42.0, 44.0, 44.0);
	[profilePicButton setBackgroundImage:[UIImage imageNamed:@"addPhoto_nonActive"] forState:UIControlStateNormal];
	[profilePicButton setBackgroundImage:[UIImage imageNamed:@"addPhoto_Active"] forState:UIControlStateHighlighted];
	profilePicButton.hidden = !isUser;
	[self addSubview:profilePicButton];
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	float yPos = 143.0;
	
	UILabel *votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, yPos, 80.0, 16.0)];
	votesLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:15];
	votesLabel.textColor = kStatsColor;
	votesLabel.backgroundColor = [UIColor clearColor];
	votesLabel.textAlignment = NSTextAlignmentCenter;
	votesLabel.text = [NSString stringWithFormat:(_userVO.votes == 1) ? NSLocalizedString(@"profile_vote", nil) : NSLocalizedString(@"profile_votes", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]]];
	[self addSubview:votesLabel];
	
	UILabel *dots1Label = [[UILabel alloc] initWithFrame:CGRectMake(96.0, yPos, 20.0, 20.0)];
	dots1Label.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:16];
	dots1Label.textColor = kStatsColor;
	dots1Label.backgroundColor = [UIColor clearColor];
	dots1Label.textAlignment = NSTextAlignmentCenter;
	dots1Label.text = @"•";
	[self addSubview:dots1Label];
	
	UILabel *snapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, yPos, 80.0, 16.0)];
	snapsLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:15];
	snapsLabel.textColor = kStatsColor;
	snapsLabel.backgroundColor = [UIColor clearColor];
	snapsLabel.textAlignment = NSTextAlignmentCenter;
	snapsLabel.text = [NSString stringWithFormat:(_userVO.pics == 1) ? NSLocalizedString(@"profile_snap", nil) : NSLocalizedString(@"profile_snaps", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]]];
	[self addSubview:snapsLabel];
	
	UILabel *dots2Label = [[UILabel alloc] initWithFrame:CGRectMake(204.0, yPos, 20.0, 20.0)];
	dots2Label.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:16];
	dots2Label.textColor = kStatsColor;
	dots2Label.backgroundColor = [UIColor clearColor];
	dots2Label.textAlignment = NSTextAlignmentCenter;
	dots2Label.text = @"•";
	[self addSubview:dots2Label];
	
	UILabel *ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(227.0, yPos, 80.0, 16.0)];
	ptsLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:15];
	ptsLabel.textColor = kStatsColor;
	ptsLabel.backgroundColor = [UIColor clearColor];
	ptsLabel.textAlignment = NSTextAlignmentCenter;
	ptsLabel.text = [NSString stringWithFormat:(_userVO.score == 1) ? NSLocalizedString(@"profile_point", nil) : NSLocalizedString(@"profile_points", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.score]]];
	[self addSubview:ptsLabel];
	
	UIImageView *divider1ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
	divider1ImageView.frame = CGRectOffset(divider1ImageView.frame, 5.0, 186.0);
	[self addSubview:divider1ImageView];
	
	NSString *ageRange = @"ANY";
	switch ((isUser) ? [[[HONAppDelegate infoForUser] objectForKey:@"age"] intValue] : _userVO.age) {
		case 1:
			ageRange = @"13-17";
			break;
			
		case 2:
			ageRange = @"18-25";
			break;
			
		case 3:
			ageRange = @"26-35";
			break;
			
		case 4:
			ageRange = @"36+";
			break;
	}
	
	UILabel *ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(11.0, 206.0, 180.0, 20.0)];
	ageLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:16];
	ageLabel.textColor = [HONAppDelegate honOrthodoxGreenColor];
	ageLabel.backgroundColor = [UIColor clearColor];
	ageLabel.text = [NSString stringWithFormat:@"Age range: %@", ageRange];
	[self addSubview:ageLabel];
	
	UIButton *snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
	snapButton.frame = CGRectMake(188.0, 194.0, 59.0, 44.0);
	[snapButton setBackgroundImage:[UIImage imageNamed:@"sendVolleyButton_nonActive"] forState:UIControlStateNormal];
	[snapButton setBackgroundImage:[UIImage imageNamed:@"sendVolleyButton_Active"] forState:UIControlStateHighlighted];
	[snapButton addTarget:self action:@selector(_goUserChallenge) forControlEvents:UIControlEventTouchUpInside];
	snapButton.hidden = isUser;
	[self addSubview:snapButton];
	
	UIButton *friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	friendsButton.frame = CGRectMake(188.0, 194.0, 59.0, 44.0);
	[friendsButton setBackgroundImage:[UIImage imageNamed:@"findFriendsButton_nonActive"] forState:UIControlStateNormal];
	[friendsButton setBackgroundImage:[UIImage imageNamed:@"findFriendsButton_Active"] forState:UIControlStateHighlighted];
	[friendsButton addTarget:self action:@selector(_goFindFriends) forControlEvents:UIControlEventTouchUpInside];
	friendsButton.hidden = !isUser;
	[self addSubview:friendsButton];
	
	UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	moreButton.frame = CGRectMake(254.0, 194.0, 59.0, 44.0);
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive"] forState:UIControlStateNormal];
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active"] forState:UIControlStateHighlighted];
	[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:moreButton];
	
	UIImageView *divider2ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
	divider2ImageView.frame = CGRectOffset(divider2ImageView.frame, 5.0, 246.0);
	[self addSubview:divider2ImageView];
	
	/*
	UIButton *snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
	snapButton.frame = CGRectMake(21.0, 179.0, 279.0, 44.0);
	[snapButton setBackgroundImage:[UIImage imageNamed:@"sendVolleyMessageButton_nonActive"] forState:UIControlStateNormal];
	[snapButton setBackgroundImage:[UIImage imageNamed:@"sendVolleyMessageButton_Active"] forState:UIControlStateHighlighted];
	[snapButton addTarget:self action:@selector(_goUserChallenge) forControlEvents:UIControlEventTouchUpInside];
	snapButton.hidden = isUser;
	[self addSubview:snapButton];
	
	UIButton *statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
	statusButton.frame = CGRectMake(21.0, 179.0, 129.0, 44.0);
	[statusButton setBackgroundImage:[UIImage imageNamed:@"statusButton_nonActive"] forState:UIControlStateNormal];
	[statusButton setBackgroundImage:[UIImage imageNamed:@"statusButton_Active"] forState:UIControlStateHighlighted];
	[statusButton addTarget:self action:@selector(_goNewSnap) forControlEvents:UIControlEventTouchUpInside];
	statusButton.hidden = !isUser;
	[self addSubview:statusButton];
	
	UIButton *findFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	findFriendsButton.frame = CGRectMake(168.0, 179.0, 129.0, 44.0);
	[findFriendsButton setBackgroundImage:[UIImage imageNamed:@"friendsButton_nonActive"] forState:UIControlStateNormal];
	[findFriendsButton setBackgroundImage:[UIImage imageNamed:@"friendsButton_Active"] forState:UIControlStateHighlighted];
	[findFriendsButton addTarget:self action:@selector(_goFindFriends) forControlEvents:UIControlEventTouchUpInside];
	findFriendsButton.hidden = !isUser;
	[self addSubview:findFriendsButton];
	
//	UIButton *addFriendButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	addFriendButton.frame = CGRectMake(168.0, 179.0, 129.0, 44.0);
//	[addFriendButton setBackgroundImage:[UIImage imageNamed:@"addFriendButton_nonActive"] forState:UIControlStateNormal];
//	[addFriendButton setBackgroundImage:[UIImage imageNamed:@"addFriendButton_Active"] forState:UIControlStateHighlighted];
//	[addFriendButton addTarget:self action:@selector(_goAddFriend) forControlEvents:UIControlEventTouchUpInside];
//	addFriendButton.hidden = isUser;
//	[self addSubview:addFriendButton];
	 */
}

- (void)updateCell {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
//	_snapsLabel.text = [NSString stringWithFormat:(_userVO.pics == 1) ? NSLocalizedString(@"profile_snap", nil) : NSLocalizedString(@"profile_snaps", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]]];
//	_votesLabel.text = [NSString stringWithFormat:(_userVO.votes == 1) ? NSLocalizedString(@"profile_vote", nil) : NSLocalizedString(@"profile_votes", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]]];
//	_ptsLabel.text = [NSString stringWithFormat:(_userVO.score == 1) ? NSLocalizedString(@"profile_point", nil) : NSLocalizedString(@"profile_points", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.score]]];
}


#pragma mark - Navigation
- (void)_goProfilePic {
	[self.delegate userProfileViewCellTakeNewAvatar:self];
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

- (void)_goMore {
	[self.delegate userProfileViewCellMore:self asProfile:([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID)];
}


@end
