//
//  HONAppDelegate.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "MBProgressHUD.h"
#import "KikAPI.h"
#import "Parse/Parse.h"
#import "Reachability.h"
#import "UAirship.h"
#import "UAPush.h"

#import "HONAppDelegate.h"
#import "HONTabBarController.h"
#import "HONChallengesViewController.h"
#import "HONTimelineViewController.h"
#import "HONDiscoveryViewController.h"
#import "HONImagePickerViewController.h"
#import "HONProfileViewController.h"
#import "HONChallengeVO.h"
#import "HONUsernameViewController.h"
#import "HONSearchViewController.h"

const NSInteger kNavBarHeaderHeight = 44;
const NSInteger kSearchHeaderHeight = 44;
const NSInteger kTabBarHeight = 44;
const NSInteger kDefaultCellHeight = 63;


NSString * const kConfigURL = @"http://discover.getassembly.com/hotornot";//@"http://54.243.163.24";
NSString * const kAPIChallenges = @"Challenges.php";
NSString * const kAPIComments = @"Comments.php";
NSString * const kAPIDiscover = @"Discover.php";
NSString * const kAPIPopular = @"Popular.php";
NSString * const kAPISearch = @"Search.php";
NSString * const kAPIUsers = @"Users.php";
NSString * const kAPIVotes = @"Votes.php";

const CGSize kTabSize = {80.0, 44.0};
const CGSize kSnapThumbSize = {38.0, 50.0};
const CGSize kSnapMediumSize = {153.0, 205.0};
const CGSize kSnapLargeSize = {612.0, 816.0};
const CGSize kAvatarDefaultSize = {200.0, 200.0};

static const CGFloat kSnapRatio = 1.33333333f;
static const CGFloat kSnapJPEGCompress = 0.75f;


@interface HONAppDelegate() <UIAlertViewDelegate, UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, strong) AVAudioPlayer *mp3Player;
@property (nonatomic) BOOL isFromBackground;
@property (nonatomic, strong) UIImageView *bgImgView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONSearchViewController *searchViewController;
@end

@implementation HONAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;


+ (NSString *)apiServerPath {
	//return ([[NSUserDefaults standardUserDefaults] objectForKey:@"server_api"]);
	//return (@"http://54.243.163.24/hotornot/api-shane");
	return (@"http://54.243.163.24/hotornot/api-dev");
}

+ (NSString *)customerServiceURL {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"service_url"]);
}
+ (NSDictionary *)s3Credentials {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"s3_creds"]);
}

+ (BOOL)isInviteCodeValid:(NSString *)code {
	
	for (NSString *validCode in [[NSUserDefaults standardUserDefaults] objectForKey:@"invite_codes"]) {
		if ([code isEqualToString:validCode])
			return (YES);
	}
	
	return (NO);
}

+ (BOOL)isFUEInviteEnabled {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"fue_invite"] isEqualToString:@"Y"]);
}

+ (NSString *)smsInviteFormat {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"invite_sms"] objectForKey:[HONAppDelegate deviceLocale]]);
}
+ (NSString *)emailInviteFormat {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"invite_email"] objectForKey:[HONAppDelegate deviceLocale]]);
}

+ (NSString *)instagramShareComment {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"insta_profile"] objectForKey:[HONAppDelegate deviceLocale]]);
}

+ (int)createPointMultiplier {
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"point_mult"] objectAtIndex:2] intValue]);
}
+ (int)votePointMultiplier {
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"point_mult"] objectAtIndex:0] intValue]);
}
+ (int)pokePointMultiplier {
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"point_mult"] objectAtIndex:1] intValue]);
}

+ (NSString *)timelineBannerURL {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"timeline_banner"]);
}

+ (NSString *)rndDefaultSubject {
	NSArray *subjects = [[NSUserDefaults standardUserDefaults] objectForKey:@"default_subjects"];
	return ([subjects objectAtIndex:(arc4random() % [subjects count])]);
}

+ (BOOL)isLocaleEnabled {
	//return (NO);
	
	if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled_locales"] objectAtIndex:0] isEqualToString:@""])
		return (YES);
	
	for (NSString *locale in [[NSUserDefaults standardUserDefaults] objectForKey:@"enabled_locales"]) {
		if ([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:locale]) {
			return (YES);
		}
	}
	
	return (NO);
}

+ (NSArray *)searchSubjects {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"search_subjects"]);
}

+ (NSArray *)searchUsers {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"search_users"]);
}

+ (NSArray *)inviteCelebs {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"invite_celebs"]);
}

+ (void)writeDeviceToken:(NSString *)token {
	[[NSUserDefaults standardUserDefaults] setObject:token forKey:@"device_token"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)deviceToken {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"]);
}

+ (void)writeUserInfo:(NSDictionary *)userInfo {
	[[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"user_info"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)writeUserAvatar:(UIImage *)image {
	[[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(image) forKey:@"avatar_image"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)infoForUser {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"]);
}

+ (UIImage *)avatarImage {
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"avatar_image"])
		return ([UIImage imageNamed:@"defaultAvatar"]);
	
	
	return ([UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"avatar_image"]]);
}

+ (void)setAllowsFBPosting:(BOOL)canPost {
	[[NSUserDefaults standardUserDefaults] setObject:(canPost) ? @"YES" : @"NO" forKey:@"fb_posting"];	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)allowsFBPosting {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"fb_posting"] isEqualToString:@"YES"]);
}

+ (int)hasVoted:(int)challengeID {
	NSArray *voteArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"votes"];
	
	for (NSNumber *cID in voteArray) {
		if ([cID intValue] == challengeID || -[cID intValue] == challengeID) {
			return ([cID intValue]);
		}
	}
	
	return (0);
}

+ (NSArray *)fillDiscoverChallenges:(NSArray *)challenges {
	//NSLog(@"challenges:\n%@[%d]", challenges, [challenges count]);
	
	// fill up all challenges if first time
	if ([challenges count] >= 12) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:challenges, @"total", challenges, @"remaining", nil] forKey:@"discover_challenges"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	// send back the 1st or next randomized set
	return ([HONAppDelegate refreshDiscoverChallenges]);
}

+ (NSArray *)refreshDiscoverChallenges {
//	NSLog(@"allChallenges:\n%@", [discover_challenges objectForKey:@"total"]);
//	NSLog(@"remainingChallenges:\n%@", [[[NSUserDefaults standardUserDefaults] objectForKey:@"discover_challenges"] objectForKey:@"remaining"]);
	
	NSArray *allChallenges = [[[NSUserDefaults standardUserDefaults] objectForKey:@"discover_challenges"] objectForKey:@"total"];
	NSMutableArray *remainingChallenges = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"discover_challenges"] objectForKey:@"remaining"] mutableCopy];
	NSMutableArray *newChallenges = [NSMutableArray array];
	
	// loop for new set
	for (int i=0; i<16; i++) {
		//NSLog(@"POP:[%d][%d]", i, [remainingChallenges count]);
		int rnd = arc4random() % [remainingChallenges count];
		
		// pick a random index and remove from pool
		[newChallenges addObject:[remainingChallenges objectAtIndex:rnd]];
		[remainingChallenges removeObjectAtIndex:rnd];
		
		if ([remainingChallenges count] == 0)
			break;
	}
	
	// no more left, repopulate
	if ([remainingChallenges count] == 0) {
		for (int i=0; i<[allChallenges count]; i++)
			[remainingChallenges addObject:[allChallenges objectAtIndex:arc4random() % [allChallenges count]]];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:allChallenges, @"total", remainingChallenges, @"remaining", nil] forKey:@"discover_challenges"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	return (newChallenges);
}

+ (void)setVote:(int)challengeID forCreator:(BOOL)isCreator {
	NSMutableArray *voteArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"votes"] mutableCopy];
	[voteArray addObject:[NSNumber numberWithInt:(isCreator) ? challengeID : -challengeID]];
	
	[[NSUserDefaults standardUserDefaults] setObject:voteArray forKey:@"votes"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


+ (UIViewController *)appTabBarController {
	return ([[UIApplication sharedApplication] keyWindow].rootViewController);
}


+ (BOOL)isRetina5 {
	return ([UIScreen mainScreen].scale == 2.f && [UIScreen mainScreen].bounds.size.height == 568.0f);
}

+ (BOOL)hasNetwork {
	//Reachability *wifiReachability = [Reachability reachabilityForLocalWiFi];
	//[[Reachability reachabilityForLocalWiFi] startNotifier];
	
	//return ([wifiReachability currentReachabilityStatus] == kReachableViaWiFi);
	
	[[Reachability reachabilityForInternetConnection] startNotifier];
	NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
	
	return !(networkStatus == NotReachable);
}

+ (BOOL)canPingAPIServer {
	return (!([[Reachability reachabilityWithHostName:[[[HONAppDelegate apiServerPath] componentsSeparatedByString: @"/"] objectAtIndex:2]] currentReachabilityStatus] == NotReachable));
}

//+ (BOOL)canPingParseServer {
//	return (!([[Reachability reachabilityWithHostName:@"api.parse.com"] currentReachabilityStatus] == NotReachable));
//}

+ (BOOL)canPingConfigServer {
//	struct sockaddr_in address;
//	address.sin_len = sizeof(address);
//	address.sin_family = AF_INET;
//	address.sin_port = htons(80);
//	address.sin_addr.s_addr = inet_addr(kConfigURL);
//	
//	Reachability *reachability = [Reachability reachabilityWithAddress:&address];
	
	//return (!([[Reachability reachabilityWithAddress:kConfigURL] currentReachabilityStatus] == NotReachable));
	return (YES);
}

+ (BOOL)audioMuted {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"audio_muted"] isEqualToString:@"YES"]);
}

+ (NSString *)deviceLocale {
	return ([[NSLocale preferredLanguages] objectAtIndex:0]);
}

+ (NSString *)timeSinceDate:(NSDate *)date {
	NSString *timeSince = @"";
	
	NSDateFormatter *utcFormatter = [[NSDateFormatter alloc] init];
	[utcFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[utcFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	NSDate *utcDate = [dateFormatter dateFromString:[utcFormatter stringFromDate:[NSDate new]]];
	
	int secs = [[utcDate dateByAddingTimeInterval:90] timeIntervalSinceDate:date];
	int mins = secs / 60;
	int hours = mins / 60;
	int days = hours / 24;
	
	//NSLog(@"[%d][%d][%d][%d]", days, hours, mins, secs);
	
	if (days > 0) {
		timeSince = [NSString stringWithFormat:@"%dd", days];
		
	} else {
		if (hours > 0)
			timeSince = [NSString stringWithFormat:@"%dh", hours];
		
		else {
			if (mins > 0)
				timeSince = [NSString stringWithFormat:@"%dm", mins];
			
			else
				timeSince = [NSString stringWithFormat:@"%ds", secs];
		}
	}
	
	if ([[timeSince substringToIndex:[timeSince length] - 1] intValue] < 0)
		timeSince = @"0s";
	
	return (timeSince);
}


+ (UIFont *)helveticaNeueFontBold {
	return ([UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]);
}

+ (UIFont *)helveticaNeueFontBoldItalic {
	return ([UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:18.0]);
}

+ (UIFont *)helveticaNeueFontMedium {
	return ([UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0]);
}

+ (UIFont *)cartoGothicBold {
	return ([UIFont fontWithName:@"CartoGothicStd-Bold" size:24.0]);
}

+ (UIFont *)cartoGothicBoldItalic {
	return ([UIFont fontWithName:@"CartoGothicStd-BoldItalic" size:24.0]);
}

+ (UIFont *)cartoGothicBook {
	return ([UIFont fontWithName:@"CartoGothicStd-Book" size:24.0]);
}

+ (UIFont *)cartoGothicItalic {
	return ([UIFont fontWithName:@"CartoGothicStd-Italic" size:24.0]);
}

+ (UIColor *)honBlueTxtColor {
	return ([UIColor colorWithRed:0.161 green:0.498 blue:1.0 alpha:1.0]);
}

+ (UIColor *)honGrey635Color {
	return ([UIColor colorWithWhite:0.635 alpha:1.0]);
}

+ (UIColor *)honGrey518Color {
	return ([UIColor colorWithWhite:0.518 alpha:1.0]);
}

+ (UIColor *)honGrey455Color {
	return ([UIColor colorWithWhite:0.455 alpha:1.0]);
}


#pragma mark - Notifications
- (void)_showSearchTable:(NSNotification *)notification {
	if (_searchViewController != nil) {
		[_searchViewController.view removeFromSuperview];
		_searchViewController = nil;
	}
	
	_searchViewController = [[HONSearchViewController alloc] init];
	_searchViewController.view.frame = CGRectMake(0.0, 20.0 + kSearchHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 188.0);
	[self.window addSubview:_searchViewController.view];
}

- (void)_hideSearchTable:(NSNotification *)notification {
	if (_searchViewController != nil) {
		[_searchViewController.view removeFromSuperview];
		_searchViewController = nil;
	}
}

- (void)_showSubjectSearchTimeline:(NSNotification *)notification {
	[_searchViewController.view removeFromSuperview];
	
	UINavigationController *navigationController = (UINavigationController *)[self.tabBarController selectedViewController];
	[navigationController pushViewController:[[HONTimelineViewController alloc] initWithSubjectName:[notification object]] animated:YES];
}

- (void)_showUserSearchTimeline:(NSNotification *)notification {
	[_searchViewController.view removeFromSuperview];
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"RESIGN_SEARCH_BAR_FOCUS" object:nil];
	
	
	UINavigationController *navigationController = (UINavigationController *)[self.tabBarController selectedViewController];
	[navigationController pushViewController:[[HONTimelineViewController alloc] initWithUsername:[notification object]] animated:YES];
}

- (void)_pokeUser:(NSNotification *)notification {
	HONUserVO *vo = (HONUserVO *)[notification object];
	
	[[Mixpanel sharedInstance] track:@"Timeline - Poke User"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username], @"challenger", nil]];
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 6], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"pokerID",
									[NSString stringWithFormat:@"%d", vo.userID], @"pokeeID",
									nil];
	
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil)
			NSLog(@"AFNetworking HONAppDelegate - Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSLog(@"AFNetworking HONAppDelegate: %@", result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"ChallengePreviewViewController AFNetworking %@", [error localizedDescription]);
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}


- (void)_sendToInstagram:(NSNotification *)notification {
	NSString *instaURL = @"instagram://app";
	NSString *instaFormat = @"com.instagram.exclusivegram";
	NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/volley_instagram.igo"];
	
	NSDictionary *dict = [notification object];
	UIImage *shareImage = [dict objectForKey:@"image"];//[UIImage imageNamed:@"instagram_template-0000"];
	[UIImageJPEGRepresentation(shareImage, 1.0f) writeToFile:savePath atomically:YES];
	
	
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:instaURL]]) {
		//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:instaURL]];
		
		_documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
		_documentInteractionController.UTI = instaFormat;
		_documentInteractionController.delegate = self;
		_documentInteractionController.annotation = [NSDictionary dictionaryWithObject:[dict objectForKey:@"caption"] forKey:@"InstagramCaption"];
		[_documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:[HONAppDelegate appTabBarController].view animated:YES];
	
	} else {
		[self _showOKAlert:NSLocalizedString(@"alert_instagramError_t", nil)
				 withMessage:NSLocalizedString(@"alert_instagramError_m", nil)];
	}
}

#pragma mark - UI Presentation
- (void)_dropTabs {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
}

- (void)_showOKAlert:(NSString *)title withMessage:(NSString *)message {
	UIAlertView *alertView = [[UIAlertView alloc]
									  initWithTitle:title
									  message:message
									  delegate:nil
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
	[alertView show];
}


#pragma mark - Application Delegates
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	NSLog(@"LANGUAGE:[%@]", [[NSLocale preferredLanguages] objectAtIndex:0]);
	
	_isFromBackground = NO;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSearchTable:) name:@"SHOW_SEARCH_TABLE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_hideSearchTable:) name:@"HIDE_SEARCH_TABLE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSubjectSearchTimeline:) name:@"SHOW_SUBJECT_SEARCH_TIMELINE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showUserSearchTimeline:) name:@"SHOW_USER_SEARCH_TIMELINE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_pokeUser:) name:@"POKE_USER" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sendToInstagram:) name:@"SEND_TO_INSTAGRAM" object:nil];
	
	//[self _testParseCloudCode];
	//[self _showFonts];
	
	[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
	[TestFlight takeOff:@"139f9073-a4d0-4ecd-9bb8-462a10380218"];
	
	if ([HONAppDelegate hasNetwork]) {
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"votes"])
			[[NSUserDefaults standardUserDefaults] setObject:[NSArray array] forKey:@"votes"];
		
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"audio_muted"])
			[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"audio_muted"];
		
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"local_challenges"])
			[[NSUserDefaults standardUserDefaults] setValue:[NSArray array] forKey:@"local_challenges"];
		
		NSMutableDictionary *takeOffOptions = [[NSMutableDictionary alloc] init];
		[takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
		[UAirship takeOff:takeOffOptions];
		[[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
		
		if (![HONAppDelegate canPingConfigServer]) {
			[self _showOKAlert:NSLocalizedString(@"alert_connectionError_t", nil)
				   withMessage:NSLocalizedString(@"alert_connectionError_m", nil)];
		}
		
		[KikAPIClient registerAsKikPluginWithAppID:@"kik-com.builtinmenlo.hotornot"
											withHomepageURI:@"http://www.builtinmenlo.com"
												addAppButton:YES];
		
//
//		[Parse setApplicationId:@"Gi7eI4v6r9pEZmSQ0wchKKelOgg2PIG9pKE160uV" clientKey:@"Bv82pH4YB8EiXZG4V0E2KjEVtpLp4Xds25c5AkLP"];
//		[PFUser enableAutomaticUser];
//		PFACL *defaultACL = [PFACL ACL];
//		[defaultACL setPublicReadAccess:YES];
//		[PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
//		
//		PFQuery *apiActiveQuery = [PFQuery queryWithClassName:@"APIs"];
//		PFObject *apiActiveObject = [apiActiveQuery getObjectWithId:@"eFLGKQWRzD"];
//		
//		// parse is down!!
//		if (apiActiveObject == nil) {
//			[self _showOKAlert:NSLocalizedString(@"alert_connectionError_t", nil)
//				   withMessage:NSLocalizedString(@"alert_connectionError_m", nil)];
//		
//		} else {
//			if ([[apiActiveObject objectForKey:@"active"] isEqualToString:@"Y"]) {
			
				int boot_total = 0;
				if (![[NSUserDefaults standardUserDefaults] objectForKey:@"boot_total"])
					[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:boot_total] forKey:@"boot_total"];
				
				else {
					boot_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"boot_total"] intValue];
					[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++boot_total] forKey:@"boot_total"];
				}
				
				if (![[NSUserDefaults standardUserDefaults] objectForKey:@"install_date"])
					[[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:@"install_date"];
				
				if (boot_total == 5) {
					UIAlertView *alertView = [[UIAlertView alloc]
												 initWithTitle:@"Rate Volley"
												 message:@"Why not rate Volley in the app store!"
												 delegate:self
												 cancelButtonTitle:nil
												 otherButtonTitles:@"No Thanks", @"Ask Me Later", @"Visit App Store", nil];
					[alertView setTag:2];
					[alertView show];
				}
				
				if (![[NSUserDefaults standardUserDefaults] objectForKey:@"fb_posting"])
					[HONAppDelegate setAllowsFBPosting:NO];
				
		//[self _retrieveConfigJSON];
				[[NSUserDefaults standardUserDefaults] synchronize];

				[Mixpanel sharedInstanceWithToken:@"c7bf64584c01bca092e204d95414985f"];
				[[Mixpanel sharedInstance] track:@"App Boot"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
							
				self.tabBarController = [[HONTabBarController alloc] init];
				self.tabBarController.delegate = self;
				
				_bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 20.0, 320.0, ([HONAppDelegate isRetina5]) ? 548.0 : 470.0)];
				_bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h@2x" : @"mainBG"];
				[self.tabBarController.view addSubview:_bgImgView];
				
				self.window.rootViewController = self.tabBarController;
				[self.window makeKeyAndVisible];
						
//			} else {
//				[self _showOKAlert:@"Upgrade Needed"
//					   withMessage:@"Please update to the latest version from the App Store to continue playing Volley."];
//			}
//		}
	
	} else {
		[self _showOKAlert:@"No Network Connection"
			   withMessage:@"This app requires a network connection to work."];
	}
	
	return (YES);
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[[Mixpanel sharedInstance] track:@"App Entering Background"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"APP_ENTERING_BACKGROUND" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	_isFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[FBAppCall handleDidBecomeActive];
	
	if (_isFromBackground && [HONAppDelegate hasNetwork]) {
		[[Mixpanel sharedInstance] track:@"App Leaving Background"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if (![HONAppDelegate canPingConfigServer]) {
			[self _showOKAlert:NSLocalizedString(@"alert_connectionError_t", nil)
				   withMessage:NSLocalizedString(@"alert_connectionError_m", nil)];
		
		} else {
			[self _retrieveConfigJSON];
			
			NSString *notificationName;
			switch ([(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"current_tab"] intValue]) {
				case 0:
					notificationName = @"REFRESH_VOTE_TAB";
					break;
					
				case 1:
					notificationName = @"REFRESH_DISCOVERY_TAB";
					break;
				
				case 2:
					notificationName = @"REFRESH_CHALLENGES_TAB";
					break;
					
				case 3:
					notificationName = @"REFRESH_PROFILE_TAB";
					break;
			}
			
			[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
		}
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[UAirship land];
	[FBSession.activeSession close];
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	return ([FBAppCall handleOpenURL:url sourceApplication:sourceApplication]);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	[[UAPush shared] registerDeviceToken:deviceToken];
	
	NSString *deviceID = [[deviceToken description] substringFromIndex:1];
	deviceID = [deviceID substringToIndex:[deviceID length] - 1];
	deviceID = [deviceID stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken:[%@]", deviceID);
	
	[HONAppDelegate writeDeviceToken:deviceID];
	[self _retrieveConfigJSON];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
	UALOG(@"Failed To Register For Remote Notifications With Error: %@", error);
	
	NSString *deviceID = [NSString stringWithFormat:@"%064d", 0];
	NSLog(@"didFailToRegisterForRemoteNotificationsWithError:[%@]", deviceID);
	
	[HONAppDelegate writeDeviceToken:deviceID];
	[self _retrieveConfigJSON];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	UALOG(@"Received remote notification: %@", userInfo);
	
	// Get application state for iOS4.x+ devices, otherwise assume active
	UIApplicationState appState = UIApplicationStateActive;
	if ([application respondsToSelector:@selector(applicationState)]) {
		appState = application.applicationState;
	}
	
	[[UAPush shared] handleNotification:userInfo applicationState:appState];
	[[UAPush shared] resetBadge]; // zero badge after push received
	
	NSLog(@"alert:(%d)[%@]", [[userInfo objectForKey:@"type"] intValue], [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
	
	// sms sound
	AudioServicesPlaySystemSound(1007);
	
	int type_id = [[userInfo objectForKey:@"type"] intValue];
	switch (type_id) {
		
		// challenge update
		case 1:
			[self _showOKAlert:@"Snap Update"
				   withMessage:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
			break;
			
		// poke
		case 2:
			[self _showOKAlert:@"Poke"
				   withMessage:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
			
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
			[[[UIApplication sharedApplication] delegate].window.rootViewController.navigationController popToRootViewControllerAnimated:NO];
			[self.tabBarController.navigationController popToRootViewControllerAnimated:NO];
			[self.tabBarController.delegate tabBarController:self.tabBarController didSelectViewController:[self.tabBarController.viewControllers objectAtIndex:2]];
			break;
	}
	 	
	UILocalNotification *localNotification = [[UILocalNotification alloc] init];
	localNotification.fireDate = [[NSDate alloc] initWithTimeIntervalSinceNow:1];
	localNotification.alertBody = [NSString stringWithFormat:@"%d", [[userInfo objectForKey:@"type"] intValue]];;
	localNotification.soundName = UILocalNotificationDefaultSoundName;
	 
//	NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Object 1", @"Key 1", @"Object 2", @"Key 2", nil];
//	localNotification.userInfo = infoDict;
	 
	[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//	return [FBSession.activeSession handleOpenURL:url];
//}


#pragma mark - Startup Operations
- (void)_retrieveConfigJSON {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kConfigURL]];
	[httpClient postPath:@"boot-dev.json" parameters:[NSDictionary dictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		
		if (error != nil)
			NSLog(@"AFNetworking HONAppDelegate - Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//NSLog(@"AFNetworking HONAppDelegate: %@", result);
			
			NSMutableArray *locales = [NSMutableArray array];
			for (NSString *locale in [result objectForKey:@"enabled_locales"])
				[locales addObject:locale];
			
			NSMutableArray *inviteCodes = [NSMutableArray array];
			for (NSString *code in [result objectForKey:@"invite_codes"])
				[inviteCodes addObject:code];
			
			NSMutableArray *hashtags = [NSMutableArray array];
			for (NSString *hashtag in [result objectForKey:@"default_hashtags"])
				[hashtags addObject:hashtag];
			
			NSMutableArray *subjects = [NSMutableArray array];
			for (NSString *hashtag in [result objectForKey:@"search_hashtags"])
				[subjects addObject:hashtag];
			
			NSMutableArray *users = [NSMutableArray array];
			for (NSString *user in [result objectForKey:@"search_users"])
				[users addObject:user];
			
			NSMutableArray *celebs = [NSMutableArray array];
			for (NSDictionary *celeb in [result objectForKey:@"invite_celebs"])
				[celebs addObject:celeb];
			
			[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"appstore_id"] forKey:@"appstore_id"];
			[[NSUserDefaults standardUserDefaults] setObject:[[result objectForKey:@"endpts"] objectForKey:@"data_api"] forKey:@"server_api"];
			[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"service_url"] forKey:@"service_url"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:
																			  [[result objectForKey:@"s3_creds"] objectForKey:@"key"], @"key",
																			  [[result objectForKey:@"s3_creds"] objectForKey:@"secret"], @"secret", nil] forKey:@"s3_creds"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:
																			  [[result objectForKey:@"point_multipliers"] objectForKey:@"vote"],
																			  [[result objectForKey:@"point_multipliers"] objectForKey:@"poke"],
																			  [[result objectForKey:@"point_multipliers"] objectForKey:@"create"], nil] forKey:@"point_mult"];
			[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"timeline_banner"] forKey:@"timeline_banner"];
			[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"fue_invite"] forKey:@"fue_invite"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:
																			  [[result objectForKey:@"invite_sms"] objectForKey:@"en"], @"en",
																			  [[result objectForKey:@"invite_sms"] objectForKey:@"id"], @"id",
																			  [[result objectForKey:@"invite_sms"] objectForKey:@"ko"], @"ko",
																			  [[result objectForKey:@"invite_sms"] objectForKey:@"jp"], @"jp",
																			  [[result objectForKey:@"invite_sms"] objectForKey:@"vi"], @"vi",
																			  [[result objectForKey:@"invite_sms"] objectForKey:@"zn-Hant"], @"zn-Hant", nil] forKey:@"invite_sms"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:
																			  [[result objectForKey:@"invite_email"] objectForKey:@"en"], @"en",
																			  [[result objectForKey:@"invite_email"] objectForKey:@"id"], @"id",
																			  [[result objectForKey:@"invite_email"] objectForKey:@"ko"], @"ko",
																			  [[result objectForKey:@"invite_email"] objectForKey:@"jp"], @"jp",
																			  [[result objectForKey:@"invite_email"] objectForKey:@"vi"], @"vi",
																			  [[result objectForKey:@"invite_email"] objectForKey:@"zn-Hant"], @"zn-Hant", nil] forKey:@"invite_email"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:
																			  [[result objectForKey:@"insta_profile"] objectForKey:@"en"], @"en",
																			  [[result objectForKey:@"insta_profile"] objectForKey:@"id"], @"id",
																			  [[result objectForKey:@"insta_profile"] objectForKey:@"ko"], @"ko",
																			  [[result objectForKey:@"insta_profile"] objectForKey:@"jp"], @"jp",
																			  [[result objectForKey:@"insta_profile"] objectForKey:@"vi"], @"vi",
																			  [[result objectForKey:@"insta_profile"] objectForKey:@"zn-Hant"], @"zn-Hant", nil] forKey:@"insta_profile"];
			[[NSUserDefaults standardUserDefaults] setObject:[locales copy] forKey:@"enabled_locales"];
			[[NSUserDefaults standardUserDefaults] setObject:[inviteCodes copy] forKey:@"invite_codes"];
			[[NSUserDefaults standardUserDefaults] setObject:[hashtags copy] forKey:@"default_subjects"];
			[[NSUserDefaults standardUserDefaults] setObject:[subjects copy] forKey:@"search_subjects"];
			[[NSUserDefaults standardUserDefaults] setObject:[users copy] forKey:@"search_users"];
			[[NSUserDefaults standardUserDefaults] setObject:[celebs copy] forKey:@"invite_celebs"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			[self _registerUser];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"HONAppDelegate AFNetworking %@", [error localizedDescription]);
	}];
	

}

- (void)_registerUser {
	//if (![[NSUserDefaults standardUserDefaults] objectForKey:@"user"]) {
	
//	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.parse.com/1/functions/"]];
//	[httpClient setDefaultHeader:@"X-Parse-Application-Id" value:@"Gi7eI4v6r9pEZmSQ0wchKKelOgg2PIG9pKE160uV"];
//	[httpClient setDefaultHeader:@"X-Parse-REST-API-Key" value:@"Lf7cT3m2EC8JsXzubpfhD28phm2gA7Y86kiTnAb6"];
//	[httpClient setDefaultHeader:@"Content-Type" value:@"application/json"];
//	[httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
		
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 1], @"action",
									[HONAppDelegate deviceToken], @"token",
									nil];
	
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			NSLog(@"AppDelegate AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
		
		} else {
			NSLog(@"HONAppDelegate AFNetworking: %@", userResult);
			
			if ([userResult objectForKey:@"id"] != [NSNull null])
				[HONAppDelegate writeUserInfo:userResult];
			
			[self _initTabs];
		}
				
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"AppDelegate AFNetworking %@", [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}


- (void)_initTabs {
	[_bgImgView removeFromSuperview];
	
	UIViewController *challengesViewController, *voteViewController, *discoveryViewController, *profileViewController;
	challengesViewController = [[HONChallengesViewController alloc] init];
	voteViewController = [[HONTimelineViewController alloc] init];//[[HONVoteSubjectsViewController alloc] init];//
	discoveryViewController = [[HONDiscoveryViewController alloc] init];
	profileViewController = [[HONProfileViewController alloc] init];
	
	UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:voteViewController];
	UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:discoveryViewController];
	UINavigationController *navController3 = [[UINavigationController alloc] initWithRootViewController:challengesViewController];
	UINavigationController *navController4 = [[UINavigationController alloc] initWithRootViewController:profileViewController];
	
	[navController1 setNavigationBarHidden:YES];
	[navController2 setNavigationBarHidden:YES];
	[navController3 setNavigationBarHidden:YES];
	[navController4 setNavigationBarHidden:YES];
	
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:navController1, navController2, navController3, navController4, nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
	//[self performSelector:@selector(_dropTabs) withObject:nil afterDelay:2.0];
}


#pragma mark - Debug Calls
- (void)_testParseCloudCode {
	// http://stackoverflow.com/questions/10795710/converting-a-curl-request-with-data-urlencode-into-afnetworking-get-request
	/*
	NSDictionary *jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"app_name", @"PicChallenge", nil];
	 
	NSError *error = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&error];
	 
	if (!jsonData) {
		NSLog(@"NSJSONSerialization failed %@", error);
	}
	 
	NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:json, @"where", nil];
	*/
	// ////////////////////////////////////////////////////////////////////////////////////////////////////////////// //
	
	NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
										 //@"PicChallenge", @"app_name",
										 [NSString stringWithFormat:@"%d", 2], @"user_id",
										 nil];
	
	AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.parse.com/1/functions/"]];
//	[client setDefaultHeader:@"X-Parse-Application-Id" value:@"Gi7eI4v6r9pEZmSQ0wchKKelOgg2PIG9pKE160uV"];
//	[client setDefaultHeader:@"X-Parse-REST-API-Key" value:@"Lf7cT3m2EC8JsXzubpfhD28phm2gA7Y86kiTnAb6"];
	[client setDefaultHeader:@"X-Parse-Application-Id" value:@"avNXwB6BSTKdSeD5lDRVM71Bglq3mY78ORBQvV2i"];
	[client setDefaultHeader:@"X-Parse-REST-API-Key" value:@"yNUthh5WRYuAoKMv2Gyv6vwmg7D0YnvJ83RZWmXr"];
	[client setDefaultHeader:@"Content-Type" value:@"application/json"];
	[client registerHTTPOperationClass:[AFJSONRequestOperation class]];
	
	NSLog(@"%@", parameters);
	
	//[client postPath:@"duration"
	[client postPath:@"getUser"
			parameters:parameters
			  success:^(AFHTTPRequestOperation *operation, id responseObject) {
				  NSError *error = nil;
				  NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
				  NSLog(@"SUCCESS\n%@", result);
				  
			  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				  NSLog(@"FAILED\n%@", error);
			  }
	 ];
}

- (void)_showFonts {
	for (NSString *familyName in [UIFont familyNames]) {
		NSLog(@"Font Family Name = %@", familyName);
		
		NSArray *names = [UIFont fontNamesForFamilyName:familyName];
		NSLog(@"Font Names = %@", names);
	}
}

#pragma mark - TabBarController Delegates
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
	//NSLog(@"shouldSelectViewController:[%@]", viewController);
	
	return (YES);
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	//NSLog(@"didSelectViewController:[%@]", viewController);
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}


#pragma mark - AlertView delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"BUTTON:[%d]", buttonIndex);
	
	if (alertView.tag == 0)
		NSLog(@"EXIT APP");//exit(0);
	
	else if (alertView.tag == 1) {
	}
	
	else if (alertView.tag == 2) {
		switch(buttonIndex) {
			case 0:
				break;
				
			case 1:
				[[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:@"install_date"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				break;
				
			case 2:
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms://itunes.apple.com/us/app/id%@?mt=8", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]]];
				break;
		}
	}
	
	else if (alertView.tag == 5) {
		switch (buttonIndex) {
			case 0:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:nil];
				break;
				
			case 1:
				break;
		}
	}
}


#pragma mark - DocumentInteraction Delegates
- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller {
	[[Mixpanel sharedInstance] track:@"Presenting DocInteraction Shelf"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [controller name], @"controller", nil]];
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
	[[Mixpanel sharedInstance] track:@"Dismissing DocInteraction Shelf"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [controller name], @"controller", nil]];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
	[[Mixpanel sharedInstance] track:@"Launching DocInteraction App"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [controller name], @"controller", nil]];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
	[[Mixpanel sharedInstance] track:@"Entering DocInteraction App Foreground"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [controller name], @"controller", nil]];
}

@end
