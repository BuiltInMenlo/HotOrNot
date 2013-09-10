//
//  HONUserProfileView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/1/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"

#import "HONUserProfileView.h"
#import "HONImageLoadingView.h"

#define kStatsColor [UIColor colorWithRed:0.227 green:0.380 blue:0.349 alpha:1.0]

@interface HONUserProfileView()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *ageLabel;
@property (nonatomic, strong) UILabel *subscribersValLabel;
@property (nonatomic, strong) UILabel *volleysValLabel;
@property (nonatomic, strong) UILabel *likesValLabel;
@end

@implementation HONUserProfileView

@synthesize delegate = _delegate;
@synthesize isOpen = _isOpen;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshAllTabs:) name:@"REFRESH_ALL_TABS" object:nil];
		
		
		UIImageView *holderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profileOverlay"]];
		holderImageView.userInteractionEnabled = YES;
		[self addSubview:holderImageView];
		
		[holderImageView addSubview:[[HONImageLoadingView alloc] initAtPos:CGPointMake(25.0, 24.0)]];
		
		__weak typeof(self) weakSelf = self;
		_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, 10.0, 93.0, 93.0)];
		_avatarImageView.userInteractionEnabled = YES;
		//_avatarImageView.alpha = 0.0;
		[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
								placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
									weakSelf.avatarImageView.image = image;
									//[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.avatarImageView.alpha = 1.0; } completion:nil];
								} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
		
		[holderImageView addSubview:_avatarImageView];
		
		UIButton *profilePicButton = [UIButton buttonWithType:UIButtonTypeCustom];
		profilePicButton.frame = CGRectMake(83.0, 33.0, 44.0, 44.0);
		[profilePicButton setBackgroundImage:[UIImage imageNamed:@"addPhoto_nonActive"] forState:UIControlStateNormal];
		[profilePicButton setBackgroundImage:[UIImage imageNamed:@"addPhoto_Active"] forState:UIControlStateHighlighted];
		[profilePicButton addTarget:self action:@selector(_goChangeAvatar) forControlEvents:UIControlEventTouchUpInside];
		[holderImageView addSubview:profilePicButton];
		
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		NSDate *birthday = [dateFormat dateFromString:[[HONAppDelegate infoForUser] objectForKey:@"age"]];
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(130.0, 22.0, 180.0, 20.0)];
		_nameLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:16];
		_nameLabel.textColor = [HONAppDelegate honBlueTextColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		_nameLabel.text = [NSString stringWithFormat:@"@%@", [[HONAppDelegate infoForUser] objectForKey:@"username"]];
		[holderImageView addSubview:_nameLabel];
		
		UIButton *nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
		nameButton.frame = _nameLabel.frame;
		[nameButton addTarget:self action:@selector(_goTimeline) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:nameButton];
		
		_ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(130.0, 46.0, 180.0, 20.0)];
		_ageLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16];
		_ageLabel.textColor = kStatsColor;
		_ageLabel.backgroundColor = [UIColor clearColor];
		_ageLabel.text = [NSString stringWithFormat:@"Age: %d", [HONAppDelegate ageForDate:birthday]];
		[holderImageView addSubview:_ageLabel];
		
		BOOL isVerified = ([[[HONAppDelegate infoForUser] objectForKey:@"age"] intValue] < 0);
		UIImageView *verifiedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(isVerified) ? @"verified" : @"notVerified"]];
		verifiedImageView.frame = CGRectOffset(verifiedImageView.frame, 128.0, 72.0);
		[holderImageView addSubview:verifiedImageView];
		
		UILabel *verifiedLabel = [[UILabel alloc] initWithFrame:CGRectMake(152.0, 72.0, 180.0, 20.0)];
		verifiedLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:16];
		verifiedLabel.textColor = (isVerified) ? [HONAppDelegate honOrthodoxGreenColor] : [UIColor redColor];
		verifiedLabel.backgroundColor = [UIColor clearColor];
		verifiedLabel.text = (isVerified) ? @"Verified" : @"Not Verified";
		[holderImageView addSubview:verifiedLabel];
		
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		
		_subscribersValLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 142.0, 92.0, 16.0)];
		_subscribersValLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:15];
		_subscribersValLabel.textColor = kStatsColor;
		_subscribersValLabel.backgroundColor = [UIColor clearColor];
		_subscribersValLabel.textAlignment = NSTextAlignmentCenter;
		_subscribersValLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[HONAppDelegate friendsList] count]]]];
		[holderImageView addSubview:_subscribersValLabel];
		
		UILabel *subscribersLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 160.0, 93.0, 16.0)];
		subscribersLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:15];
		subscribersLabel.textColor = [HONAppDelegate honGrey518Color];
		subscribersLabel.backgroundColor = [UIColor clearColor];
		subscribersLabel.textAlignment = NSTextAlignmentCenter;
		subscribersLabel.text = ([[HONAppDelegate friendsList] count] == 1) ? @"Subscriber" : @"Subscribers";
		[holderImageView addSubview:subscribersLabel];
		
		_volleysValLabel = [[UILabel alloc] initWithFrame:CGRectMake(116.0, 142.0, 92.0, 16.0)];
		_volleysValLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:15];
		_volleysValLabel.textColor = kStatsColor;
		_volleysValLabel.backgroundColor = [UIColor clearColor];
		_volleysValLabel.textAlignment = NSTextAlignmentCenter;
		_volleysValLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]]]];
		[holderImageView addSubview:_volleysValLabel];
		
		UILabel *volleysLabel = [[UILabel alloc] initWithFrame:CGRectMake(116.0, 160.0, 93.0, 16.0)];
		volleysLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:15];
		volleysLabel.textColor = [HONAppDelegate honGrey518Color];
		volleysLabel.backgroundColor = [UIColor clearColor];
		volleysLabel.textAlignment = NSTextAlignmentCenter;
		volleysLabel.text = ([[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue] == 1) ? @"Volley" : @"Volleys";
		[holderImageView addSubview:volleysLabel];
		
		_likesValLabel = [[UILabel alloc] initWithFrame:CGRectMake(216.0, 142.0, 92.0, 16.0)];
		_likesValLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:15];
		_likesValLabel.textColor = kStatsColor;
		_likesValLabel.backgroundColor = [UIColor clearColor];
		_likesValLabel.textAlignment = NSTextAlignmentCenter;
		_likesValLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue]]]];
		[holderImageView addSubview:_likesValLabel];
		
		UILabel *likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(217.0, 160.0, 93.0, 16.0)];
		likesLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:15];
		likesLabel.textColor = [HONAppDelegate honGrey518Color];
		likesLabel.backgroundColor = [UIColor clearColor];
		likesLabel.textAlignment = NSTextAlignmentCenter;
		likesLabel.text = ([[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue] == 1) ? @"Like" : @"Likes";
		[holderImageView addSubview:likesLabel];
		
		UIButton *friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		friendsButton.frame = CGRectMake(8.0, 210.0, 109.0, 44.0);
		[friendsButton setBackgroundImage:[UIImage imageNamed:@"findFriendsProfileButton_nonActive"] forState:UIControlStateNormal];
		[friendsButton setBackgroundImage:[UIImage imageNamed:@"findFriendsProfileButton_Active"] forState:UIControlStateHighlighted];
		[friendsButton addTarget:self action:@selector(_goFindFriends) forControlEvents:UIControlEventTouchUpInside];
		[holderImageView addSubview:friendsButton];
		
		UIButton *promoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		promoteButton.frame = CGRectMake(124.0, 210.0, 109.0, 44.0);
		[promoteButton setBackgroundImage:[UIImage imageNamed:@"promoteButton_nonActive"] forState:UIControlStateNormal];
		[promoteButton setBackgroundImage:[UIImage imageNamed:@"promoteButton_Active"] forState:UIControlStateHighlighted];
		[promoteButton addTarget:self action:@selector(_goPromote) forControlEvents:UIControlEventTouchUpInside];
		[holderImageView addSubview:promoteButton];
		
		UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
		moreButton.frame = CGRectMake(240.0, 210.0, 64.0, 44.0);
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButtonProfile_nonActive"] forState:UIControlStateNormal];
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButtonProfile_Active"] forState:UIControlStateHighlighted];
		[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
		[holderImageView addSubview:moreButton];
	}
	
	return (self);
}


#pragma mark - Data Calls
- (void)_retrieveUser {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 5], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			[HONAppDelegate writeUserInfo:userResult];
			
			NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
			[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
			
			NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
			[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
			
			__weak typeof(self) weakSelf = self;
			//_avatarImageView.alpha = 0.0;
			[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
									placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
										weakSelf.avatarImageView.image = image;
										//[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.avatarImageView.alpha = 1.0; } completion:nil];
									} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
			
			_nameLabel.text = [NSString stringWithFormat:@"@%@", [[HONAppDelegate infoForUser] objectForKey:@"username"]];
			_ageLabel.text = [NSString stringWithFormat:@"Age: %d", [HONAppDelegate ageForDate:[dateFormat dateFromString:[[HONAppDelegate infoForUser] objectForKey:@"age"]]]];
			_subscribersValLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[HONAppDelegate friendsList] count]]]];
			_volleysValLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]]]];
			_likesValLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue]]]];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}


#pragma mark - Public APIs
- (void)show {
	[self _retrieveUser];
	
	_isOpen = YES;
	[UIView animateWithDuration:kProfileTime animations:^(void) {
		self.frame = CGRectOffset(self.frame, 0.0, 364.0);
	} completion:^(BOOL finished) {
	}];
}

- (void)hide {
	[UIView animateWithDuration:kProfileTime delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
		self.frame = CGRectOffset(self.frame, 0.0, -364.0);
	} completion:^(BOOL finished) {
		_isOpen = NO;
	}];
	
}


#pragma mark - Navigation
- (void)_goChangeAvatar {
	[self.delegate userProfileViewChangeAvatar:self];
}

- (void)_goFindFriends {
	[self.delegate userProfileViewInviteFriends:self];
}

- (void)_goPromote {
	[self.delegate userProfileViewPromote:self];
}

- (void)_goMore {
	[self.delegate userProfileViewSettings:self];
}

- (void)_goTimeline {
	[self.delegate userProfileViewTimeline:self];
}


#pragma mark - Notifications
- (void)_refreshAllTabs:(NSNotification *)notification {
	[self _retrieveUser];
}

@end
