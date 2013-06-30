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
#import "HONImagingDepictor.h"

#define kStatsColor [UIColor colorWithRed:0.227 green:0.380 blue:0.349 alpha:1.0]


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
		UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profileBackground"]];
		[self addSubview:bgImageView];
	}
	
	return (self);
}

- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
	
	BOOL isUser = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID);
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(113.0, 17.0, 93.0, 93.0)];
	
	if (isUser)
		_avatarImageView.image = [HONAppDelegate avatarImage];
	
	else
		[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_userVO.imageURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3] placeholderImage:nil success:nil failure:nil];//^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
	
	_avatarImageView.userInteractionEnabled = YES;
	[self addSubview:_avatarImageView];
	
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
	
	_votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, yPos, 80.0, 16.0)];
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
	
	UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	settingsButton.frame = CGRectMake(19.0, 152.0, 279.0, 44.0);
	[settingsButton setBackgroundImage:[UIImage imageNamed:@"privacySettings_nonActive"] forState:UIControlStateNormal];
	[settingsButton setBackgroundImage:[UIImage imageNamed:@"privacySettings_Active"] forState:UIControlStateHighlighted];
	[settingsButton addTarget:self action:@selector(_goSettings) forControlEvents:UIControlEventTouchUpInside];
	settingsButton.hidden = !isUser;
	[self addSubview:settingsButton];
	
	if (!isUser) {
		UIButton *snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
		snapButton.frame = CGRectMake(18.0, 152.0, 284.0, 49.0);
		[snapButton setBackgroundImage:[UIImage imageNamed:@"photoMessage_nonActive"] forState:UIControlStateNormal];
		[snapButton setBackgroundImage:[UIImage imageNamed:@"photoMessage_Active"] forState:UIControlStateHighlighted];
		[snapButton addTarget:self action:@selector(_goNewUserChallenge) forControlEvents:UIControlEventTouchUpInside];
		snapButton.hidden = !isFriend;
		[self addSubview:snapButton];
		
		UIButton *friendButton = [UIButton buttonWithType:UIButtonTypeCustom];
		friendButton.frame = CGRectMake(18.0, 152.0, 284.0, 49.0);
		[friendButton setBackgroundImage:[UIImage imageNamed:@"addFriend_nonActive"] forState:UIControlStateNormal];
		[friendButton setBackgroundImage:[UIImage imageNamed:@"addFriend_Active"] forState:UIControlStateHighlighted];
		[friendButton addTarget:self action:@selector(_goSettings) forControlEvents:UIControlEventTouchUpInside];
		friendButton.hidden = isFriend;
		[self addSubview:friendButton];
	}
	
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
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TAKE_NEW_AVATAR" object:nil];
}

- (void)_goSettings {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SETTINGS" object:nil];
}

- (void)_goTimeline {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_USER_SEARCH_TIMELINE" object:_userVO.username];
}

- (void)_goNewChallenge {
	[[Mixpanel sharedInstance] track:@"Timeline Profile - Create Snap Button"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"challenger", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_CHALLENGE" object:nil];
}

- (void)_goNewUserChallenge {
	[[Mixpanel sharedInstance] track:@"Timeline Profile - New Snap At User"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"challenger", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_USER_CHALLENGE" object:_userVO];
}

- (void)_goShare {
	if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																					delegate:self
																		cancelButtonTitle:@"Cancel"
																 destructiveButtonTitle:nil
																		otherButtonTitles:@"View my timeline", @"Share on Instagram", @"Share via SMS", @"Share via Email", nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
		[actionSheet setTag:0];
		[actionSheet showInView:[HONAppDelegate appTabBarController].view];
		
	} else {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																					delegate:self
																		cancelButtonTitle:@"Cancel"
																 destructiveButtonTitle:@"Report Abuse"
																		otherButtonTitles:nil];//otherButtonTitles:@"Share on Instagram", [NSString stringWithFormat:@"snap @%@", _userVO.username], [NSString stringWithFormat:@"Poke @%@", _userVO.username], nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
		[actionSheet setTag:1];
		[actionSheet showInView:[HONAppDelegate appTabBarController].view];
	}
}

- (void)_goFlagUser {
	[[Mixpanel sharedInstance] track:@"Timeline Profile - Report"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"challenger", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																				delegate:self
																	cancelButtonTitle:@"Cancel"
															 destructiveButtonTitle:@"Report Abuse"
																	otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet setTag:1];
	[actionSheet showInView:[HONAppDelegate appTabBarController].view];
}


#pragma mark - ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		switch (buttonIndex) {
				
			case 0:
				[self _goTimeline];
				break;
				
			// SHARE instagram
			case 1: {
				UIImage *image = [HONImagingDepictor prepImageForInstagram:[UIImage imageNamed:@"instagram_template-0000"] avatarImage:[HONAppDelegate avatarImage] username:[[HONAppDelegate infoForUser] objectForKey:@"name"]];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SEND_TO_INSTAGRAM" object:[NSDictionary dictionaryWithObjectsAndKeys:
																																	 [HONAppDelegate instagramShareComment], @"caption",
																																	 image, @"image", nil]];
				break;}
				
			// share SMS
			case 2:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_SMS" object:nil];
				break;
				
			// share Email
			case 3:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_EMAIL" object:nil];
				break;
		}
	
	} else if (actionSheet.tag == 1) {
		NSLog(@"buttonIndex:[%d]", buttonIndex);
		
		switch (buttonIndex) {
			case 0: {
				[[Mixpanel sharedInstance] track:@"Timeline Profile - Flag"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"challenger", nil]];
				
				NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSString stringWithFormat:@"%d", 10], @"action",
												[NSString stringWithFormat:@"%d", _userVO.userID], @"userID",
												nil];
				
				VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
				AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
				[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					NSError *error = nil;
					if (error != nil) {
						VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
						
					} else {
						//NSDictionary *flagResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
						//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], flagResult);
					}
					
				} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
				}];
				
				break;}
				
				// share instagram
			case 1:
				break;
		}
	}
}


@end
