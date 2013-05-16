//
//  HONUserProfileViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 2/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"

#import "HONUserProfileViewCell.h"
#import "HONAppDelegate.h"
#import "HONImagingDepictor.h"

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
	}
	
	return (self);
}

- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
	
	BOOL isUser = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID);
	
	NSString *avatarURL = ([_userVO.imageURL rangeOfString:@"?"].location == NSNotFound) ? [NSString stringWithFormat:@"%@?r=%d", _userVO.imageURL, arc4random()] : [NSString stringWithFormat:@"%@&r=%d", _userVO.imageURL, arc4random()];
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, 12.0, 93.0, 93.0)];
	_avatarImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	[_avatarImageView setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:nil];
	//_avatarImageView.image = [HONAppDelegate avatarImage];
	_avatarImageView.userInteractionEnabled = YES;
	[self addSubview:_avatarImageView];
	
	UIButton *snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
	snapButton.frame = CGRectMake(57.0, 60.0, 34.0, 34.0);
	[snapButton setBackgroundImage:[UIImage imageNamed:@"takeProfilePictureButton_nonActive"] forState:UIControlStateNormal];
	[snapButton setBackgroundImage:[UIImage imageNamed:@"takeProfilePictureButton_Active"] forState:UIControlStateHighlighted];
	[snapButton addTarget:self action:@selector(_goProfilePic) forControlEvents:UIControlEventTouchUpInside];
	snapButton.hidden = !isUser;
	[_avatarImageView addSubview:snapButton];
		
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	_snapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 28.0, 107.0, 20.0)];
	_snapsLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:14];
	_snapsLabel.textColor = [HONAppDelegate honGrey635Color];
	_snapsLabel.backgroundColor = [UIColor clearColor];
	_snapsLabel.text = [NSString stringWithFormat:(_userVO.pics == 1) ? NSLocalizedString(@"profile_snap", nil) : NSLocalizedString(@"profile_snaps", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]]];
	[self addSubview:_snapsLabel];
	
	_votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 52.0, 107.0, 20.0)];
	_votesLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:14];
	_votesLabel.textColor = [HONAppDelegate honGrey635Color];
	_votesLabel.backgroundColor = [UIColor clearColor];
	_votesLabel.text = [NSString stringWithFormat:(_userVO.votes == 1) ? NSLocalizedString(@"profile_vote", nil) : NSLocalizedString(@"profile_votes", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]]];
	[self addSubview:_votesLabel];
	
	_ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 76.0, 107.0, 20.0)];
	_ptsLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:14];
	_ptsLabel.textColor = [HONAppDelegate honGrey635Color];
	_ptsLabel.backgroundColor = [UIColor clearColor];
	_ptsLabel.text = [NSString stringWithFormat:(_userVO.score == 1) ? NSLocalizedString(@"profile_point", nil) : NSLocalizedString(@"profile_points", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.score]]];
	[self addSubview:_ptsLabel];
	
	UIButton *timelineButton = [UIButton buttonWithType:UIButtonTypeCustom];
	timelineButton.frame = CGRectMake(120.0, 28.0, 107.0, 80.0);
	[timelineButton addTarget:self action:@selector(_goTimeline) forControlEvents:UIControlEventTouchUpInside];
	//timelineButton.hidden = !isUser;
	[self addSubview:timelineButton];
	
	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.frame = CGRectMake(224.0, 37.0, 64.0, 44.0);
	[shareButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateNormal];
	[shareButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateHighlighted];
	[shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:shareButton];
	
//	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(180.0, 50.0, 150.0, 50.0)];
//	view.backgroundColor = [UIColor blackColor];
//	[self addSubview:view];
//	
//	[view.layer addSublayer:[HONImageComposer drawTextToLayer:[NSString stringWithFormat:@"@%@", _userVO.username] inFrame:CGRectMake(0.0, 0.0, view.frame.size.width, view.frame.size.height) withFont:[[HONAppDelegate cartoGothicBold] fontWithSize:20.0] textColor:[UIColor whiteColor]]];
}


- (void)updateCell {
	NSString *avatarURL = ([_userVO.imageURL rangeOfString:@"?"].location == NSNotFound) ? [NSString stringWithFormat:@"%@?r=%d", _userVO.imageURL, arc4random()] : [NSString stringWithFormat:@"%@&r=%d", _userVO.imageURL, arc4random()];
	
	[_avatarImageView removeFromSuperview];
	[_avatarImageView setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:nil];
	_avatarImageView.userInteractionEnabled = YES;
	[self addSubview:_avatarImageView];
	
	[HONImagingDepictor writeImageFromWeb:avatarURL withDimensions:kAvatarDefaultSize withUserDefaultsKey:@"avatar_image"];
	
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
																		otherButtonTitles:@"View my timeline", @"Share on Instagram", @"Share via SMS", @"Share via Email", nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
		[actionSheet setTag:0];
		[actionSheet showInView:[HONAppDelegate appTabBarController].view];
		
	} else {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																					delegate:self
																		cancelButtonTitle:@"Cancel"
																 destructiveButtonTitle:@"Report Abuse"
																		otherButtonTitles:@"Share on Instagram", [NSString stringWithFormat:@"snap @%@", _userVO.username], [NSString stringWithFormat:@"Poke @%@", _userVO.username], nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
		[actionSheet setTag:1];
		[actionSheet showInView:[HONAppDelegate appTabBarController].view];
	}
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
				
				[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
				
				// share instagram
			case 1:{
				UIImage *image = [HONImagingDepictor prepImageForInstagram:[UIImage imageNamed:@"instagram_template-0000"] avatarImage:[HONAppDelegate avatarImage] username:[[HONAppDelegate infoForUser] objectForKey:@"name"]];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SEND_TO_INSTAGRAM" object:[NSDictionary dictionaryWithObjectsAndKeys:
																																	 [HONAppDelegate instagramShareComment], @"caption",
																																	 image, @"image", nil]];
				break;}
				
				// snap
			case 2:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_USER_CHALLENGE" object:_userVO];
				break;
				
				// poke
			case 3:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"POKE_USER" object:_userVO];
				break;
		}
	}
}


@end
