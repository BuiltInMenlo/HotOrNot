//
//  HONVerifyHeaderView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/21/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"

#import "HONVerifyHeaderView.h"
#import "HONUserVO.h"

@interface HONVerifyHeaderView()
@property (nonatomic, retain) HONChallengeVO *challengeVO;
@property (nonatomic, retain) UILabel *ageLabel;
@end

@implementation HONVerifyHeaderView

@synthesize delegate = _delegate;

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 61.0)])) {
		_challengeVO = vo;
		
		self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.85];
		
		UIImageView *creatorAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 9.0, 38.0, 38.0)];
		[creatorAvatarImageView setImageWithURL:[NSURL URLWithString:_challengeVO.creatorVO.avatarURL] placeholderImage:nil];
		creatorAvatarImageView.userInteractionEnabled = YES;
		[self addSubview:creatorAvatarImageView];
		
		UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(58.0, 9.0, 150.0, 19.0)];
		usernameLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:16];
		usernameLabel.textColor = [HONAppDelegate honGrey518Color];
		usernameLabel.backgroundColor = [UIColor clearColor];
		usernameLabel.text = [NSString stringWithFormat:@"@%@", _challengeVO.creatorVO.username];
		[self addSubview:usernameLabel];
		
		_ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(58.0, 31.0, 220.0, 16.0)];
		_ageLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:15];
		_ageLabel.textColor = [HONAppDelegate honBlueTextColor];
		_ageLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_ageLabel];
		
		UILabel *stausLabel = [[UILabel alloc] initWithFrame:CGRectMake(146.0, 8.0, 160.0, 12.0)];
		stausLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:11];
		stausLabel.textColor = [HONAppDelegate honOrthodoxGreenColor];
		stausLabel.backgroundColor = [UIColor clearColor];
		stausLabel.textAlignment = NSTextAlignmentRight;
		stausLabel.text = @"just joined Volley";
		[self addSubview:stausLabel];
		
		UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(146.0, 21.0, 160.0, 16.0)];
		timeLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
		timeLabel.textColor = [HONAppDelegate honGreyTimeColor];
		timeLabel.backgroundColor = [UIColor clearColor];
		timeLabel.textAlignment = NSTextAlignmentRight;
		timeLabel.text = (_challengeVO.expireSeconds > 0) ? [HONAppDelegate formattedExpireTime:_challengeVO.expireSeconds] : [HONAppDelegate timeSinceDate:_challengeVO.updatedDate];
		[self addSubview:timeLabel];
		
		UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		avatarButton.frame = creatorAvatarImageView.frame;
		[avatarButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
		[avatarButton addTarget:self action:@selector(_goCreatorTimeline) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:avatarButton];
		
		[self _retrieveUser];
	}
	
	return (self);
}

#pragma mark - Data Calls
- (void)_retrieveUser {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 5], @"action",
							[NSString stringWithFormat:@"%d", _challengeVO.creatorVO.userID], @"userID", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil)
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		else {
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			HONUserVO *userVO = [HONUserVO userWithDictionary:userResult];
			_ageLabel.text = ([userVO.birthday timeIntervalSince1970] == 0.0) ? @"hasn't set a birthday yet" : [NSString stringWithFormat:@"does this new user look %d?", [HONAppDelegate ageForDate:userVO.birthday]];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}


#pragma mark - Navigation
- (void)_goCreatorTimeline {
	[self.delegate verifyHeaderView:self showCreatorTimeline:_challengeVO];
}

@end
