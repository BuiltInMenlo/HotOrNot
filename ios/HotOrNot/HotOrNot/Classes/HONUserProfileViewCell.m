//
//  HONUserProfileViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 2/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "Mixpanel.h"
#import "UIImageView+AFNetworking.h"

#import "HONUserProfileViewCell.h"
#import "HONAppDelegate.h"

@interface HONUserProfileViewCell() <UIAlertViewDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *snapsLabel;
@property (nonatomic, strong) UILabel *votesLabel;
@property (nonatomic, strong) UILabel *ptsLabel;
@end

@implementation HONUserProfileViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		//self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profileBackground"]];
	}
	
	return (self);
}

- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
	
	BOOL isUser = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID);
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, 12.0, 93.0, 93.0)];
	_avatarImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	//[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_userVO.imageURL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60.0] placeholderImage:nil success:nil failure:nil];
	[_avatarImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
	[self addSubview:_avatarImageView];
	
	UIButton *snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
	snapButton.frame = CGRectMake(68.0, 72.0, 34.0, 34.0);
	[snapButton setBackgroundImage:[UIImage imageNamed:@"takeProfilePictureButton_nonActive"] forState:UIControlStateNormal];
	[snapButton setBackgroundImage:[UIImage imageNamed:@"takeProfilePictureButton_Active"] forState:UIControlStateHighlighted];
	[snapButton addTarget:self action:@selector(_goProfilePic) forControlEvents:UIControlEventTouchUpInside];
	snapButton.hidden = !isUser;
	[self addSubview:snapButton];
		
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	_snapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 28.0, 107.0, 20.0)];
	_snapsLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:14];
	_snapsLabel.textColor = [HONAppDelegate honGreyTxtColor];
	_snapsLabel.backgroundColor = [UIColor clearColor];
	_snapsLabel.text = [NSString stringWithFormat:(_userVO.pics == 1) ? NSLocalizedString(@"profile_snap", nil) : NSLocalizedString(@"profile_snaps", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]]];
	[self addSubview:_snapsLabel];
	
	_votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 52.0, 107.0, 20.0)];
	_votesLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:14];
	_votesLabel.textColor = [HONAppDelegate honGreyTxtColor];
	_votesLabel.backgroundColor = [UIColor clearColor];
	_votesLabel.text = [NSString stringWithFormat:(_userVO.votes == 1) ? NSLocalizedString(@"profile_vote", nil) : NSLocalizedString(@"profile_votes", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]]];
	[self addSubview:_votesLabel];
	
	_ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 76.0, 107.0, 20.0)];
	_ptsLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:14];
	_ptsLabel.textColor = [HONAppDelegate honGreyTxtColor];
	_ptsLabel.backgroundColor = [UIColor clearColor];
	_ptsLabel.text = [NSString stringWithFormat:(_userVO.score == 1) ? NSLocalizedString(@"profile_point", nil) : NSLocalizedString(@"profile_points", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.score]]];
	[self addSubview:_ptsLabel];
	
	UIButton *timelineButton = [UIButton buttonWithType:UIButtonTypeCustom];
	timelineButton.frame = CGRectMake(120.0, 28.0, 107.0, 80.0);
	[timelineButton addTarget:self action:@selector(_goTimeline) forControlEvents:UIControlEventTouchUpInside];
	//timelineButton.hidden = !isUser;
	[self addSubview:timelineButton];
	
	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.frame = CGRectMake(244.0, 32.0, 44.0, 44.0);
	[shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_nonActive"] forState:UIControlStateNormal];
	[shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_Active"] forState:UIControlStateHighlighted];
	[shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:shareButton];
}


- (void)updateCell {
	NSString *avatarURL = ([_userVO.imageURL rangeOfString:@"?"].location == NSNotFound) ? [NSString stringWithFormat:@"%@?r=%d", _userVO.imageURL, arc4random()] : [NSString stringWithFormat:@"%@&r=%d", _userVO.imageURL, arc4random()];
	NSLog(@"--------- UPDATE CELL[%@] ----------", avatarURL);
	
	[_avatarImageView setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:nil];
//	__weak typeof(self) weakSelf = self;
//	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:avatarURL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60.0] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//		weakSelf.avatarImageView.image = image;
//	} failure:nil];
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	_snapsLabel.text = [NSString stringWithFormat:(_userVO.pics == 1) ? NSLocalizedString(@"profile_snap", nil) : NSLocalizedString(@"profile_snaps", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]]];
	_votesLabel.text = [NSString stringWithFormat:(_userVO.votes == 1) ? NSLocalizedString(@"profile_vote", nil) : NSLocalizedString(@"profile_votes", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]]];
	_ptsLabel.text = [NSString stringWithFormat:(_userVO.score == 1) ? NSLocalizedString(@"profile_point", nil) : NSLocalizedString(@"profile_points", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.score]]];
}


#pragma mark - Navigation
- (void)_goProfilePic {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TAKE_NEW_AVATAR" object:nil];
}

- (void)_goTimeline {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_USER_SEARCH_TIMELINE" object:_userVO.username];
}

- (void)_goShare {
	if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																					delegate:self
																		cancelButtonTitle:@"Cancel"
																 destructiveButtonTitle:nil
																		otherButtonTitles:@"Share on Instagram", @"Share via SMS", @"Share via Email", nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
		[actionSheet setTag:0];
		[actionSheet showInView:[HONAppDelegate appTabBarController].view];
		
	} else {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																					delegate:self
																		cancelButtonTitle:@"Cancel"
																 destructiveButtonTitle:@"Report Abuse"
																		otherButtonTitles:@"Share on Instagram", @"Share via SMS", @"Share via Email", [NSString stringWithFormat:@"Poke @%@", _userVO.username], [NSString stringWithFormat:@"snap @%@", _userVO.username], nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
		[actionSheet setTag:1];
		[actionSheet showInView:[HONAppDelegate appTabBarController].view];
	}
}


#pragma mark - ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		switch (buttonIndex) {
			case 0: {
				// SHARE instagram
				
				NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
				if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
					[[UIApplication sharedApplication] openURL:instagramURL];
				
				break;}
				
				// share SMS
			case 1:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_SMS" object:nil];
				break;
				
				// share Email
			case 2:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_EMAIL" object:nil];
				break;
		}
	
	} else if (actionSheet.tag == 1) {
		switch (buttonIndex) {
			case 0: {
				[[Mixpanel sharedInstance] track:@"Timeline - Flag"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"user2", nil]];
				
				AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
				NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSString stringWithFormat:@"%d", 10], @"action",
												[NSString stringWithFormat:@"%d", _userVO.userID], @"userID",
												nil];
				
				[httpClient postPath:kUsersAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					NSError *error = nil;
					if (error != nil) {
						NSLog(@"HONVoteItemViewCell AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
						
					} else {
						//NSDictionary *flagResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
						//NSLog(@"HONVoteItemViewCell AFNetworking: %@", flagResult);
					}
					
				} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					NSLog(@"VoteItemViewCell AFNetworking %@", [error localizedDescription]);
				}];
				
				break;}
				
			case 1: {
				// SHARE instagram
				
				NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
				if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
					[[UIApplication sharedApplication] openURL:instagramURL];
				
				break;}
				
				// share SMS
			case 2:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_SMS" object:nil];
				break;
				
				// share Email
			case 3:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_EMAIL" object:nil];
				break;
				
				// poke
			case 4: {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"POKE_USER" object:_userVO];
				break;}
				
				// snap
			case 5: {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_USER_CHALLENGE" object:_userVO];
				break;}
		}
	}
}


@end
