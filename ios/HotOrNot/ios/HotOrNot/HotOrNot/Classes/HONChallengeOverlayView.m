//
//  HONChallengeOverlayView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/16/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"


#import "HONChallengeOverlayView.h"
#import "HONUserVO.h"

@interface HONChallengeOverlayView()
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONOpponentVO *opponentVO;
@property (nonatomic, strong) UILabel *ageLabel;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation HONChallengeOverlayView

- (id)initWithChallenge:(HONChallengeVO *)challengeVO forOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super initWithFrame:[UIScreen mainScreen].bounds])) {
		_challengeVO = challengeVO;
		_opponentVO = opponentVO;
		
		self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.85];
		
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = self.frame;
		[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchDown];
		[self addSubview:closeButton];
		
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 31.0, 37.0, 37.0)];
		[avatarImageView setImageWithURL:[NSURL URLWithString:_opponentVO.avatarURL] placeholderImage:nil];
		[self addSubview:avatarImageView];
		
		UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 39.0, 200.0, 20.0)];
		nameLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:16];
		nameLabel.textColor = [UIColor whiteColor];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.text = [NSString stringWithFormat:@"@%@", _opponentVO.username];
		[self addSubview:nameLabel];
		
		_ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(153.0, 39.0, 150.0, 20.0)];
		_ageLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:16];
		_ageLabel.textAlignment = NSTextAlignmentRight;
		_ageLabel.textColor = [UIColor whiteColor];
		_ageLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_ageLabel];
		
		UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height * 0.5) - 42.0, 320.0, 84.0)];
		[self addSubview:holderView];
		
		UIButton *upvoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		upvoteButton.frame = CGRectMake(18.0, 0.0, 74.0, 74.0);
		[upvoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive"] forState:UIControlStateNormal];
		[upvoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active"] forState:UIControlStateHighlighted];
		[upvoteButton addTarget:self action:@selector(_goUpvote) forControlEvents:UIControlEventTouchUpInside];
		[holderView addSubview:upvoteButton];
		
		UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
		profileButton.frame = CGRectMake(116.0, 0.0, 84.0, 84.0);
		[profileButton setBackgroundImage:[UIImage imageNamed:@"profileButton_nonActive"] forState:UIControlStateNormal];
		[profileButton setBackgroundImage:[UIImage imageNamed:@"profileButton_Active"] forState:UIControlStateHighlighted];
		[profileButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
		[holderView addSubview:profileButton];
		
		UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
		flagButton.frame = CGRectMake(217.0, 0.0, 74.0, 74.0);
		[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_nonActive"] forState:UIControlStateNormal];
		[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_Active"] forState:UIControlStateHighlighted];
		[flagButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
		[holderView addSubview:flagButton];
		
		[self _retrieveUser:_opponentVO.userID];
	}
	
	return (self);
}


#pragma mark - Data Calls
- (void)_retrieveUser:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 5], @"action",
							[NSString stringWithFormat:@"%d", userID], @"userID",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			HONUserVO *userVO = [HONUserVO userWithDictionary:userResult];
			_ageLabel.text = ([userVO.birthday timeIntervalSince1970] == 0.0) ? @"" : [NSString stringWithFormat:@"%d", [HONAppDelegate ageForDate:userVO.birthday]];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}


#pragma mark - Navigation
- (void)_goClose {
	[self.delegate challengeOverlayViewClose:self];
}

- (void)_goUpvote {
	[self.delegate challengeOverlayViewUpvote:self opponent:_opponentVO forChallenge:_challengeVO];
}

- (void)_goProfile {
	[self.delegate challengeOverlayViewProfile:self opponent:_opponentVO forChallenge:_challengeVO];
}

- (void)_goFlag {
	[self.delegate challengeOverlayViewFlag:self opponent:_opponentVO forChallenge:_challengeVO];
}


@end
