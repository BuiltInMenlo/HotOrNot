//
//  HONVerifyOverlayView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/16/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"

#import "HONVerifyOverlayView.h"
#import "HONUserVO.h"


@interface HONVerifyOverlayView()
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) UILabel *ageLabel;
@end

@implementation HONVerifyOverlayView

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super initWithFrame:[UIScreen mainScreen].bounds])) {
		_challengeVO = vo;
		
		self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
		
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = self.frame;
		[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchDown];
		[self addSubview:closeButton];
		
		UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 108.0) * 0.5, 320.0, 128.0)];
		[self addSubview:holderView];
		
		UIImageView *blueBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blueBackground"]];
		[holderView addSubview:blueBGImageView];
		
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 13.0, 37.0, 37.0)];
		[avatarImageView setImageWithURL:[NSURL URLWithString:_challengeVO.creatorVO.avatarURL] placeholderImage:nil];
		[holderView addSubview:avatarImageView];
		
		UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		avatarButton.frame = avatarImageView.frame;
		[avatarButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchDown];
		[holderView addSubview:avatarButton];
		
		UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(62.0, 15.0, 300.0, 35.0)];
		captionLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:14];
		captionLabel.textColor = [UIColor whiteColor];
		captionLabel.backgroundColor = [UIColor clearColor];
		captionLabel.numberOfLines = 2;
		captionLabel.text = [NSString stringWithFormat:@"is @%@\nbetween 14 & 24?", _challengeVO.creatorVO.username];
		[holderView addSubview:captionLabel];
		
		_ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(245.0, 25.0, 50.0, 14.0)];
		_ageLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:14];
		_ageLabel.textColor = [UIColor whiteColor];
		_ageLabel.backgroundColor = [UIColor clearColor];
		_ageLabel.textAlignment = NSTextAlignmentRight;
		[holderView addSubview:_ageLabel];
		
		UIButton *yayButton = [UIButton buttonWithType:UIButtonTypeCustom];
		yayButton.frame = CGRectMake(0.0, 64.0, 159.0, 64.0);
		[yayButton setBackgroundImage:[UIImage imageNamed:@"verifyButton_nonActive"] forState:UIControlStateNormal];
		[yayButton setBackgroundImage:[UIImage imageNamed:@"verifyButton_Active"] forState:UIControlStateHighlighted];
		[yayButton addTarget:self action:@selector(_goYay) forControlEvents:UIControlEventTouchUpInside];
		[holderView addSubview:yayButton];
		
		UIButton *nayButton = [UIButton buttonWithType:UIButtonTypeCustom];
		nayButton.frame = CGRectMake(160.0, 64.0, 159.0, 64.0);
		[nayButton setBackgroundImage:[UIImage imageNamed:@"noButton_nonActive"] forState:UIControlStateNormal];
		[nayButton setBackgroundImage:[UIImage imageNamed:@"noButton_Active"] forState:UIControlStateHighlighted];
		[nayButton addTarget:self action:@selector(_goNay) forControlEvents:UIControlEventTouchUpInside];
		[holderView addSubview:nayButton];
		
		[self _retrieveUser:_challengeVO.creatorVO.username];
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
			_ageLabel.text = ([userVO.birthday timeIntervalSince1970] == 0.0) ? @"" : [NSString stringWithFormat:@"%d", [HONAppDelegate ageForDate:userVO.birthday]];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}


#pragma mark - Navigation
- (void)_goClose {
	[self.delegate verifyOverlayViewClose:self];
}

- (void)_goYay {
	[self.delegate verifyOverlayView:self approve:YES forChallenge:_challengeVO];
}

- (void)_goNay {
	[self.delegate verifyOverlayView:self approve:NO forChallenge:_challengeVO];
}

- (void)_goProfile {
	[self.delegate verifyOverlayView:self showProfile:_challengeVO.creatorVO];
}

@end
