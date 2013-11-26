//
//  HONSuggestedFollowViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 11/25/2013 @ 13:37 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"

#import "HONSuggestedFollowViewCell.h"
#import "HONUserVO.h"


@interface HONSuggestedFollowViewCell ()
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) HONUserVO *userVO;
@property (nonatomic, strong) NSMutableArray *challenges;
@end

@implementation HONSuggestedFollowViewCell
@synthesize delegate = _delegate;
@synthesize popularUserVO = _popularUserVO;


+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"suggestedCellBackground"]];
		
		_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_checkButton.frame = CGRectMake(209.0, 76.0, 94.0, 44.0);
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"suggestedFollowOnButton_nonActive"] forState:UIControlStateNormal];
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"suggestedFollowOnButton_Active"] forState:UIControlStateHighlighted];
		[_checkButton addTarget:self action:@selector(_goUnfollow) forControlEvents:UIControlEventTouchUpInside];
		_checkButton.hidden = YES;
		[self.contentView addSubview:_checkButton];
		
		_followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_followButton.frame = _checkButton.frame;
		[_followButton setBackgroundImage:[UIImage imageNamed:@"suggestedFollowOffButton_nonActive"] forState:UIControlStateNormal];
		[_followButton setBackgroundImage:[UIImage imageNamed:@"suggestedFollowOffButton_Active"] forState:UIControlStateHighlighted];
		[_followButton addTarget:self action:@selector(_goFollow) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_followButton];
	}
	
	return (self);
}

- (void)setPopularUserVO:(HONPopularUserVO *)popularUserVO {
	_popularUserVO = popularUserVO;
		
	UIView *blueView = [[UIView alloc] initWithFrame:CGRectMake(6.0, 5.0, 33.0, 33.0)];
	blueView.backgroundColor = [HONAppDelegate honBlueTextColor];
	[self.contentView addSubview:blueView];
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 6.0, 31.0, 31.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:[_popularUserVO.imageURL stringByAppendingString:kSnapThumbSuffix]] placeholderImage:nil];
	[self.contentView addSubview:avatarImageView];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(48.0, 11.0, 170.0, 20.0)];
	nameLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16];
	nameLabel.textColor = [HONAppDelegate honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _popularUserVO.username;
	[self.contentView addSubview:nameLabel];
	
	[self _retrieveUser];
}

- (void)toggleSelected:(BOOL)isSelected {
	_followButton.hidden = isSelected;
	_checkButton.hidden = !isSelected;
}


#pragma mark - Data Calls
- (void)_retrieveUser {
	NSDictionary *params = @{@"action"	: [NSString stringWithFormat:@"%d", 5],
							 @"userID"	: [NSString stringWithFormat:@"%d", _popularUserVO.userID]};
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"], params);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			if ([userResult objectForKey:@"id"] != nil) {
				_userVO = [HONUserVO userWithDictionary:userResult];
				
//				NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//				[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
//				
//				UILabel *selfiesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, kStatsPosY, 107.0, 18.0)];
//				selfiesLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:13];
//				selfiesLabel.textColor = [HONAppDelegate honGreyTextColor];
//				selfiesLabel.backgroundColor = [UIColor clearColor];
//				selfiesLabel.textAlignment = NSTextAlignmentCenter;
//				selfiesLabel.text = [NSString stringWithFormat:@"%@ Selfie%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.totalVolleys]], (_userVO.totalVolleys == 1) ? @"" : @"s"];
//				[self.contentView addSubview:selfiesLabel];
//				
//				UILabel *followersLabel = [[UILabel alloc] initWithFrame:CGRectMake(106.0, kStatsPosY, 107.0, 18.0)];
//				followersLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:13];
//				followersLabel.textColor = [HONAppDelegate honGreyTextColor];
//				followersLabel.backgroundColor = [UIColor clearColor];
//				followersLabel.textAlignment = NSTextAlignmentCenter;
//				followersLabel.text = [NSString stringWithFormat:@"%@ Follower%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[_userVO.friends count]]], ([_userVO.friends count] == 1) ? @"" : @"s"];
//				[self.contentView addSubview:followersLabel];

				[self _retreiveSubscribees];
				
			} else {
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if ([error.description isEqualToString:kNetErrorNoConnection]) {
		}
	}];
}

- (void)_retreiveSubscribees {
	NSDictionary *params = @{@"userID"	: [NSString stringWithFormat:@"%d", _popularUserVO.userID]};
	
	VolleyJSONLog(@"%@ —/> (%@/%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIGetSubscribees, params);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	
	[httpClient postPath:kAPIGetSubscribees parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			[self _makeStatsWithFollowingTotal:[result count]];
			[self _retrieveChallenges];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}

- (void)_retrieveChallenges {
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"action"		: [NSString stringWithFormat:@"%d", 9],
							 @"isPrivate"	: @"N",
							 @"username"	: _userVO.username,
							 @"p"			: [NSString stringWithFormat:@"%d", 1]};
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *challengesResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//VolleyJSONLog(@"AFNetworking [-] %@: USER CHALLENGES:[%d]", [[self class] description], [challengesResult count]);
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], challengesResult);
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], [challengesResult objectAtIndex:0]);
			_challenges = [NSMutableArray array];
			
			int cnt = 0;
			for (NSDictionary *serverList in challengesResult) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
				
				if (cnt == 2)
					break;
				
				[_challenges addObject:vo];
				cnt++;
			}
			
			cnt = 0;
			for (HONChallengeVO *vo in _challenges) {
				NSString *imgPrefix = @"";
				if (vo.creatorVO.userID == _popularUserVO.userID)
					imgPrefix = vo.creatorVO.imagePrefix;
				
				else {
					for (HONOpponentVO *opponentVO in vo.challengers) {
						if (opponentVO.userID == _popularUserVO.userID)
							imgPrefix = opponentVO.imagePrefix;
					}
				}
				
				UIView *challengeImageView = [self _challengeImageForPrefix:imgPrefix];
				challengeImageView.frame = CGRectOffset(challengeImageView.frame, 15.0 + (cnt * (kSnapThumbSize.width + 15.0)), 58.0);
				[self.contentView addSubview:challengeImageView];
				
				cnt++;
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
	}];
}


#pragma mark - Navigation
- (void)_goFollow {
	_followButton.hidden = YES;
	_checkButton.hidden = NO;
	
	[self.delegate followViewCell:self user:_popularUserVO toggleSelected:YES];
}

- (void)_goUnfollow {
	_followButton.hidden = NO;
	_checkButton.hidden = YES;
	
	[self.delegate followViewCell:self user:_popularUserVO toggleSelected:NO];
}


#pragma mark - UI Presentation
- (void)_makeStatsWithFollowingTotal:(int)following {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	UILabel *selfiesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, kStatsPosY, 107.0, 18.0)];
	selfiesLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:13];
	selfiesLabel.textColor = [HONAppDelegate honGreyTextColor];
	selfiesLabel.backgroundColor = [UIColor clearColor];
	selfiesLabel.textAlignment = NSTextAlignmentCenter;
	selfiesLabel.text = [NSString stringWithFormat:@"%@ Selfie%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.totalVolleys]], (_userVO.totalVolleys == 1) ? @"" : @"s"];
	[self.contentView addSubview:selfiesLabel];
	
	UILabel *followersLabel = [[UILabel alloc] initWithFrame:CGRectMake(106.0, kStatsPosY, 107.0, 18.0)];
	followersLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:13];
	followersLabel.textColor = [HONAppDelegate honGreyTextColor];
	followersLabel.backgroundColor = [UIColor clearColor];
	followersLabel.textAlignment = NSTextAlignmentCenter;
	followersLabel.text = [NSString stringWithFormat:@"%@ Follower%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[_userVO.friends count]]], ([_userVO.friends count] == 1) ? @"" : @"s"];
	[self.contentView addSubview:followersLabel];
	
	UILabel *followingLabel = [[UILabel alloc] initWithFrame:CGRectMake(213.0, kStatsPosY, 107.0, 18.0)];
	followingLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:13];
	followingLabel.textColor = [HONAppDelegate honGreyTextColor];
	followingLabel.backgroundColor = [UIColor clearColor];
	followingLabel.textAlignment = NSTextAlignmentCenter;
	followingLabel.text = [NSString stringWithFormat:@"%@ Following", [numberFormatter stringFromNumber:[NSNumber numberWithInt:following]]];
	[self.contentView addSubview:followingLabel];

}

- (UIView *)_challengeImageForPrefix:(NSString *)imagePrefix {
	
	UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapThumbSize.width + 2.0, kSnapThumbSize.height + 2.0)];
	bgView.backgroundColor = [HONAppDelegate honBlueTextColor];
	
	UIImageView *challengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(1.0, 1.0, kSnapThumbSize.width, kSnapThumbSize.height)];
	[challengeImageView setImageWithURL:[NSURL URLWithString:[imagePrefix stringByAppendingString:kSnapThumbSuffix]] placeholderImage:nil];
	[bgView addSubview:challengeImageView];
	
	return (bgView);
}


@end
