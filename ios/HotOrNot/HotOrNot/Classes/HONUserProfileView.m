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
@property (nonatomic, strong) UILabel *nameAgeLabel;
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
		
		//[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profileBlurBackground"]]];
		
		UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 68.0, 320.0, 401.0)];
		holderView.backgroundColor = [UIColor blackColor];
		[self addSubview:holderView];
		
		UIView *avatarHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 204.0)];
		avatarHolderView.clipsToBounds = YES;
		[holderView addSubview:avatarHolderView];
		
		__weak typeof(self) weakSelf = self;
		_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 427.0)];
		_avatarImageView.userInteractionEnabled = YES;
		//_avatarImageView.alpha = 0.0;
		[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
								placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
									weakSelf.avatarImageView.image = image;
									//[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.avatarImageView.alpha = 1.0; } completion:nil];
								} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
		
		[avatarHolderView addSubview:_avatarImageView];
		
		UIButton *profilePicButton = [UIButton buttonWithType:UIButtonTypeCustom];
		profilePicButton.frame = CGRectMake(271.0, 159.0, 44.0, 44.0);
		[profilePicButton setBackgroundImage:[UIImage imageNamed:@"addPhoto_nonActive"] forState:UIControlStateNormal];
		[profilePicButton setBackgroundImage:[UIImage imageNamed:@"addPhoto_Active"] forState:UIControlStateHighlighted];
		[profilePicButton addTarget:self action:@selector(_goChangeAvatar) forControlEvents:UIControlEventTouchUpInside];
		[holderView addSubview:profilePicButton];
		
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		NSDate *birthday = [dateFormat dateFromString:[[HONAppDelegate infoForUser] objectForKey:@"age"]];
		
		_nameAgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 222.0, 280.0, 26.0)];
		_nameAgeLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:22];
		_nameAgeLabel.textColor = [UIColor whiteColor];
		_nameAgeLabel.textAlignment = NSTextAlignmentCenter;
		_nameAgeLabel.backgroundColor = [UIColor clearColor];
		_nameAgeLabel.text = [NSString stringWithFormat:@"@%@, %d", [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate ageForDate:birthday]];
		[holderView addSubview:_nameAgeLabel];
		
		CGSize size = [_nameAgeLabel.text sizeWithFont:_nameAgeLabel.font constrainedToSize:CGSizeMake(280.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
		_nameAgeLabel.frame = CGRectMake(160.0 - (size.width * 0.5), 222.0, size.width, size.height);
		
		UIImageView *checkIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkMarkIcon"]];
		checkIconImageView.frame = CGRectOffset(checkIconImageView.frame, 8.0 + (160.0 - (size.width * 0.5)) + size.width, 221.0);
		[holderView addSubview:checkIconImageView];
		
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		
		_volleysValLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 275.0, 107.0, 16.0)];
		_volleysValLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:15];
		_volleysValLabel.textColor = [UIColor whiteColor];
		_volleysValLabel.backgroundColor = [UIColor clearColor];
		_volleysValLabel.textAlignment = NSTextAlignmentCenter;
		_volleysValLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]]]];
		[holderView addSubview:_volleysValLabel];
		
		UILabel *volleysLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 296.0, 107.0, 16.0)];
		volleysLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:15];
		volleysLabel.textColor = [UIColor whiteColor];
		volleysLabel.backgroundColor = [UIColor clearColor];
		volleysLabel.textAlignment = NSTextAlignmentCenter;
		volleysLabel.text = ([[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue] == 1) ? @"Volley" : @"Volleys";
		[holderView addSubview:volleysLabel];
		
		_subscribersValLabel = [[UILabel alloc] initWithFrame:CGRectMake(107.0, 275.0, 107.0, 16.0)];
		_subscribersValLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:15];
		_subscribersValLabel.textColor = [UIColor whiteColor];
		_subscribersValLabel.backgroundColor = [UIColor clearColor];
		_subscribersValLabel.textAlignment = NSTextAlignmentCenter;
		_subscribersValLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[HONAppDelegate friendsList] count]]]];
		[holderView addSubview:_subscribersValLabel];
		
		UILabel *subscribersLabel = [[UILabel alloc] initWithFrame:CGRectMake(107.0, 296.0, 107.0, 16.0)];
		subscribersLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:15];
		subscribersLabel.textColor = [UIColor whiteColor];
		subscribersLabel.backgroundColor = [UIColor clearColor];
		subscribersLabel.textAlignment = NSTextAlignmentCenter;
		subscribersLabel.text = ([[HONAppDelegate friendsList] count] == 1) ? @"Subscriber" : @"Subscribers";
		[holderView addSubview:subscribersLabel];
		
		_likesValLabel = [[UILabel alloc] initWithFrame:CGRectMake(214.0, 275.0, 107.0, 16.0)];
		_likesValLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:15];
		_likesValLabel.textColor = [UIColor whiteColor];
		_likesValLabel.backgroundColor = [UIColor clearColor];
		_likesValLabel.textAlignment = NSTextAlignmentCenter;
		_likesValLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue]]]];
		[holderView addSubview:_likesValLabel];
		
		UILabel *likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(214.0, 296.0, 107.0, 16.0)];
		likesLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:15];
		likesLabel.textColor = [UIColor whiteColor];
		likesLabel.backgroundColor = [UIColor clearColor];
		likesLabel.textAlignment = NSTextAlignmentCenter;
		likesLabel.text = ([[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue] == 1) ? @"Like" : @"Likes";
		[holderView addSubview:likesLabel];
		
		UIButton *friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		friendsButton.frame = CGRectMake(9.0, 340.0, 114.0, 44.0);
		[friendsButton setBackgroundImage:[UIImage imageNamed:@"findFriendsProfileButton_nonActive"] forState:UIControlStateNormal];
		[friendsButton setBackgroundImage:[UIImage imageNamed:@"findFriendsProfileButton_Active"] forState:UIControlStateHighlighted];
		[friendsButton addTarget:self action:@selector(_goFindFriends) forControlEvents:UIControlEventTouchUpInside];
		[holderView addSubview:friendsButton];
		
		UIButton *promoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		promoteButton.frame = CGRectMake(137.0, 340.0, 114.0, 44.0);
		[promoteButton setBackgroundImage:[UIImage imageNamed:@"promoteButton_nonActive"] forState:UIControlStateNormal];
		[promoteButton setBackgroundImage:[UIImage imageNamed:@"promoteButton_Active"] forState:UIControlStateHighlighted];
		[promoteButton addTarget:self action:@selector(_goPromote) forControlEvents:UIControlEventTouchUpInside];
		[holderView addSubview:promoteButton];
		
		UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
		moreButton.frame = CGRectMake(264.0, 340.0, 44.0, 44.0);
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButtonProfile_nonActive"] forState:UIControlStateNormal];
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButtonProfile_Active"] forState:UIControlStateHighlighted];
		[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
		[holderView addSubview:moreButton];
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
//			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
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
			
			_nameAgeLabel.text = [NSString stringWithFormat:@"@%@, %d", [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate ageForDate:[dateFormat dateFromString:[[HONAppDelegate infoForUser] objectForKey:@"age"]]]];
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
		self.frame = CGRectOffset(self.frame, 0.0, 323.0);
	} completion:^(BOOL finished) {
	}];
}

- (void)hide {
	[UIView animateWithDuration:kProfileTime delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
		self.frame = CGRectOffset(self.frame, 0.0, -323.0);
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
