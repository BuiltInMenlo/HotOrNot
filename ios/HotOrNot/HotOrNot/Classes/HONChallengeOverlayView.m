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
@end

@implementation HONChallengeOverlayView

- (id)initWithChallenge:(HONChallengeVO *)challengeVO forOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super initWithFrame:[UIScreen mainScreen].bounds])) {
		_challengeVO = challengeVO;
		_opponentVO = opponentVO;
		
		self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.67];
		
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = self.frame;
		[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchDown];
		[self addSubview:closeButton];
		
		UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 108.0) * 0.5, 320.0, 128.0)];
		[self addSubview:holderView];
		
		UIImageView *blueBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blueBackground"]];
		[holderView addSubview:blueBGImageView];
		
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 13.0, 37.0, 37.0)];
		[avatarImageView setImageWithURL:[NSURL URLWithString:_opponentVO.avatarURL] placeholderImage:nil];
		[holderView addSubview:avatarImageView];
		
		UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(61.0, 25.0, 300.0, 14.0)];
		captionLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:14];
		captionLabel.textColor = [UIColor whiteColor];
		captionLabel.backgroundColor = [UIColor clearColor];
		captionLabel.text = [NSString stringWithFormat:@"@%@", _opponentVO.username];
		[holderView addSubview:captionLabel];
		
		_ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(245.0, 25.0, 50.0, 14.0)];
		_ageLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:14];
		_ageLabel.textColor = [UIColor whiteColor];
		_ageLabel.backgroundColor = [UIColor clearColor];
		_ageLabel.textAlignment = NSTextAlignmentRight;
		[holderView addSubview:_ageLabel];
		
		UIButton *upvoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		upvoteButton.frame = CGRectMake(0.0, 66.0, 105.0, 64.0);
		[upvoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive"] forState:UIControlStateNormal];
		[upvoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active"] forState:UIControlStateHighlighted];
		[upvoteButton addTarget:self action:@selector(_goUpvote) forControlEvents:UIControlEventTouchUpInside];
		[holderView addSubview:upvoteButton];
		
		UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
		profileButton.frame = CGRectMake(108.0, 66.0, 105.0, 64.0);
		[profileButton setBackgroundImage:[UIImage imageNamed:@"profileButton_nonActive"] forState:UIControlStateNormal];
		[profileButton setBackgroundImage:[UIImage imageNamed:@"profileButton_Active"] forState:UIControlStateHighlighted];
		[profileButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
		[holderView addSubview:profileButton];
		
		UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
		flagButton.frame = CGRectMake(215.0, 66.0, 105.0, 64.0);
		[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_nonActive"] forState:UIControlStateNormal];
		[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_Active"] forState:UIControlStateHighlighted];
		[flagButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
		[holderView addSubview:flagButton];
		
		[self _retrieveUser:_opponentVO.username];
	}
	
	return (self);
}


#pragma mark - Data Calls
- (void)_retrieveUser:(NSString *)username {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 8], @"action",
							username, @"username",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			HONUserVO *userVO = [HONUserVO userWithDictionary:userResult];
			_ageLabel.text = [NSString stringWithFormat:@"%d", [HONAppDelegate ageForDate:userVO.birthday]];
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
