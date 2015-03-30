	   //
//  HONAPICaller.m
//  HotOrNot
//
//  Created by Matt Holcombe on 12/10/2013 @ 12:40.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import <CommonCrypto/CommonHMAC.h>

#import <AWSiOSSDKv2/S3.h>

#import "NSDate+BuiltinMenlo.h"

#import "MBProgressHUD.h"
//#import "S3.h"

#import "HONAPICaller.h"



#if __DEV_BUILD__ == 0 || __APPSTORE_BUILD__ == 1
NSString * const kAPIHostKey = @"prod";
NSString * const kConfigURL = @"https://volley-api.selfieclubapp.com";
NSString * const kConfigJSON = @"boot_sc0011.json";
#else
NSString * const kAPIHostKey = @"devint";
//NSString * const kConfigURL = @"https://volley-api.devint.selfieclubapp.com";
//NSString * const kConfigJSON = @"boot_marsh.json";
#endif

//NSString * const kConfigURL = @"https://volley-api.selfieclubapp.com";
//NSString * const kConfigJSON = @"boot_sc0011.json";


//] api endpts [>
//]=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=[>
NSString * const kAPIChallenges	= @"Challenges.php";
NSString * const kAPIComments	= @"Comments.php";
NSString * const kAPISearch		= @"Search.php";
NSString * const kAPIUsers		= @"Users.php";
NSString * const kAPIVotes		= @"Votes.php";

NSString * const kAPIMemberClubs			= @"member/%d/clubs/";
NSString * const kAPIMemberStatusUpdates	= @"member/%d/statusupdates/";
NSString * const kAPIClubStatusUpdates		= @"club/%d/statusupdates/";
NSString * const kAPIStatusUpdate			= @"statusupdate/%d/";
NSString * const kAPIStatusUpdateChildren	= @"statusupdate/%d/children/";
NSString * const kAPIStatusUpdateVoters		= @"statusupdate/%d/voters/";

NSString * const kAPICreateChallenge		= @"challenges/create";
NSString * const kAPICreateMessage			= @"challenges/createprivate";
NSString * const kAPIDeleteImage			= @"challenges/deleteimage";
NSString * const kAPIChallengeObject		= @"challenges/get";
NSString * const kAPIGetMessages			= @"challenges/getprivate";
NSString * const kAPIGetPublicChallenges	= @"challenges/getpublic";
NSString * const kAPIGetVerifyList			= @"challenges/getVerifyList";
NSString * const kAPIJoinChallenge			= @"challenges/join";
NSString * const kAPIChallengesMessageSeen	= @"challenges/messageseen";
NSString * const kAPIProcessChallengeImage	= @"challenges/processimage";
NSString * const kAPIProfileShoutout		= @"challenges/selfieshoutout";
NSString * const kAPIVerifyShoutout			= @"challenges/shoutout";

NSString * const kAPIClubsBlock			= @"clubs/block";
NSString * const kAPIClubsCreate		= @"clubs/create";
NSString * const kAPIClubsDelete		= @"clubs/delete"; // <--PENDING //
NSString * const kAPIClubsEdit			= @"clubs/edit";   // <--PENDING //
NSString * const kAPIClubsGet			= @"clubs/get";
NSString * const kAPIClubsFeatured		= @"clubs/featured";
NSString * const kAPIClubsInvite		= @"clubs/invite";
NSString * const kAPIClubsJoin			= @"clubs/join";
NSString * const kAPIClubsProcessImage	= @"clubs/processimage";
NSString * const kAPIClubsQuit			= @"clubs/quit";
NSString * const kAPIClubsUnblock		= @"clubs/unblock";

NSString * const kAPIEmailInvites	= @"g/emailinvites";
NSString * const kAPISMSInvites		= @"g/smsinvites";

NSString * const kAPIGetFriends		= @"social/getfriends";
NSString * const kAPIAddFriend		= @"social/addfriend";
NSString * const kAPIRemoveFriend	= @"social/removefriend";

NSString * const kAPICheckNameAndEmail		= @"users/checkNameAndEmail";
NSString * const kAPIGetActivity			= @"users/getactivity";
NSString * const kAPIUsersGetClubs			= @"users/getOtherUsersClubs";//@"users/getclubs";
NSString * const kAPIUsersGetClubInvites	= @"users/getclubinvites";
NSString * const kAPIGetSubscribees			= @"users/getsubscribees";
NSString * const kAPIEmailContacts			= @"users/ffemail";
NSString * const kAPIUsersFirstRunComplete	= @"users/firstruncomplete";
NSString * const kAPITumblrInvite			= @"users/invitetumblr";
NSString * const kAPIProcessUserImage		= @"users/processimage";
NSString * const kAPIPurgeUser				= @"users/purge";
NSString * const kAPIPurgeContent			= @"users/purgecontent";
NSString * const kAPISetUserAgeGroup		= @"users/setage";
NSString * const kAPISuspendedAccount		= @"users/suspendedaccount";
NSString * const kAPIEmailVerify			= @"users/verifyemail";
NSString * const kAPIPhoneVerify			= @"users/verifyphone";
NSString * const kAPIUsersSetDeviceToken	= @"users/setDeviceToken";
NSString * const kAPIUsersUpdatePhone		= @"userPhone/updatePhone";
NSString * const kAPIUsersValidatePIN		= @"userPhone/validatePhone";
NSString * const kAPIUsersCheckUsername		= @"users/checkUsername";
NSString * const kAPIUsersCheckPhone		= @"users/checkPhone";
NSString * const kAPIStatusupdate			= @"statusupdate/";

//]=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=[

// network error descriptions
NSString * const kNetErrorNoConnection = @"The Internet connection appears to be offline."; //{NSErrorFailingURLStringKey=https://api.tapstream.com/yunder/event/ios-yunder-open/, NSErrorFailingURLKey=https://api.tapstream.com/yunder/event/ios-yunder-open/, NSLocalizedDescription=The Internet connection appears to be offline., NSUnderlyingError=0x16695210 "The Internet connection appears to be offline."}
NSString * const kNetErrorStatusCode404 = @"Expected status code in (200-299), got 404";


// MIME types
NSString * const kMIMETypeApplicationJSON = @"application/json";
NSString * const kMIMETypeApplicationOctetStream = @"application/octet-stream";
NSString * const kMIMETypeApplicationXFormURLEncoded = @"application/x-www-form-urlencoded";
NSString * const kMIMETypeApplicationXML = @"application/xml";
NSString * const kMIMETypeApplicationXPlist = @"application/x-plist";
NSString * const kMIMETypeImage = @"image/*";
NSString * const kMIMETypeImageGIF = @"image/gif";
NSString * const kMIMETypeImageJPEG = @"image/jpeg";
NSString * const kMIMETypeImagePNG = @"image/png";
NSString * const kMIMETypeMultipartFormData = @"multipart/form-data";
NSString * const kMIMETypeTextJavascript = @"text/javascript";
NSString * const kMIMETypeTextJSON = @"text/json";
NSString * const kMIMETypeTextPlain = @"text/plain";
NSString * const kMIMETypeTextXML = @"text/xml";

// netowrk rules
const CGFloat kNotifiyDelay = (float)(2 / 3);
const NSURLRequestCachePolicy kOrthodoxURLCachePolicy = NSURLRequestReturnCacheDataElseLoad;
//const NSURLRequestCachePolicy kOrthodoxURLCachePolicy = NSURLRequestReloadIgnoringCacheData;


//void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error);
//void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
//	SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[[HONAPICaller sharedInstance] class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, [error localizedDescription]);
//
//	[[HONAPICaller sharedInstance] showDataErrorHUD];
//};

@interface HONAPICaller ()
@property (nonatomic) int awsUploadCounter;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSMutableSet *requestQueueSet;
//@property (nonatomic, copy) imageLoadComplete_t heroCompleteBlock;
//@property (nonatomic, copy) imageLoadFailure_t heroFailureBlock;
@end


@implementation HONAPICaller
static HONAPICaller *sharedInstance = nil;

+ (HONAPICaller *)sharedInstance {
	static HONAPICaller *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[self alloc] init];
	});

	return (s_sharedInstance);
}

- (id)init {
	if ((self = [super init])) {
		_requestQueueSet = [[NSMutableSet alloc] init];
	}
	
	return (self);
}


#pragma mark - Utility
+ (NSDictionary *)s3Credentials {
	return (@{@"key"		: @"AKIAIHUQ42RE7R7CIMEA",
			  @"secret"		: @"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"});
}

+ (NSString *)s3BucketForType:(HONAmazonS3BucketType)s3BucketType {
	NSString *key = @"";
	
	NSDictionary *dict = @{@"avatars"	: @[@"https://hotornot-avatars.s3.amazonaws.com",
											@"https://d3j8du2hyvd35p.cloudfront.net"],
						   @"banners"	: @[@"https://hotornot-banners.s3.amazonaws.com",
											@"https://hotornot-banners.s3.amazonaws.com"],
						   @"clubs"		: @[@"https://hotornot-challenges.s3.amazonaws.com",
											@"https://d1fqnfrnudpaz6.cloudfront.net"],
						   @"emoticons"	: @[@"https://hotornot-emotions.s3.amazonaws.com",
											@"https://hotornot-banners.s3.amazonaws.com"]};
	
	if (s3BucketType == HONAmazonS3BucketTypeAvatarsSource || s3BucketType == HONAmazonS3BucketTypeAvatarsCloudFront)
		key = @"avatars";
	
	else if (s3BucketType == HONAmazonS3BucketTypeBannersSource || s3BucketType == HONAmazonS3BucketTypeBannersCloudFront)
		key = @"banners";
	
	else if (s3BucketType == HONAmazonS3BucketTypeClubsSource || s3BucketType == HONAmazonS3BucketTypeClubsCloudFront)
		key = @"clubs";
	
	else if (s3BucketType == HONAmazonS3BucketTypeEmotionsSource || s3BucketType == HONAmazonS3BucketTypeEmoticonsCloudFront)
		key = @"emoticons";
	
	return ([[dict objectForKey:key] objectAtIndex:(s3BucketType % 2)]);
}


+ (NSTimeInterval)timeoutInterval {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"timeout_interval"] doubleValue]);
}




- (NSString *)phpAPIBasePath {
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"server_apis"] objectForKey:kAPIHostKey] objectForKey:@"php"]);
}

- (NSString *)pythonAPIBasePath {
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"server_apis"] objectForKey:kAPIHostKey] objectForKey:@"python"]);
}

- (AFHTTPClient *)appendHeaders:(NSDictionary *)headers toHTTPCLient:(AFHTTPClient *)httpClient {
	[headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[httpClient setDefaultHeader:(NSString *)key value:(NSString *)obj];
	}];
	
	return (httpClient);
}

- (AFHTTPClient *)getHttpClientWithHMACUsingPHPBasePath {
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] appendHeaders:@{@"HMAC"		: [[HONDeviceIntrinsics sharedInstance] hmacToken],
																			  @"X-DEVICE"	: [[HONDeviceIntrinsics sharedInstance] modelName]} toHTTPCLient:[[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[[HONAPICaller sharedInstance] phpAPIBasePath]]]];
	return (httpClient);
}

- (AFHTTPClient *)getHttpClientWithHMACUsingPythonBasePath {
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] appendHeaders:@{@"HMAC"		: [[HONDeviceIntrinsics sharedInstance] hmacToken],
																			  @"X-DEVICE"	: [[HONDeviceIntrinsics sharedInstance] modelName]} toHTTPCLient:[[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[[HONAPICaller sharedInstance] pythonAPIBasePath]]]];
	
	return (httpClient);
}

- (NSString *)hmacForKey:(NSString *)key withData:(NSString *)data {
	const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
	const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
	unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
	CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
	
	NSMutableString *result = [NSMutableString string];
	for (int i=0; i<sizeof cHMAC; i++)
		[result appendFormat:@"%02hhx", cHMAC[i]];
		
	return ([result copy]);
}

- (NSString *)normalizePrefixForImageURL:(NSString *)imageURL {
	NSMutableString *imagePrefix = [imageURL mutableCopy];
	
	[imagePrefix replaceOccurrencesOfString:[kSnapThumbSuffix substringToIndex:[kSnapThumbSuffix length] - 4] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imagePrefix length])];
	[imagePrefix replaceOccurrencesOfString:[kSnapMediumSuffix substringToIndex:[kSnapMediumSuffix length] - 4] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imagePrefix length])];
	[imagePrefix replaceOccurrencesOfString:[kSnapLargeSuffix substringToIndex:[kSnapLargeSuffix length] - 4] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imagePrefix length])];
	[imagePrefix replaceOccurrencesOfString:@"_o" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imagePrefix length])];
	[imagePrefix replaceOccurrencesOfString:@".jpg" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imagePrefix length])];
	[imagePrefix replaceOccurrencesOfString:@".png" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imagePrefix length])];
	
	return ([imagePrefix copy]);
}

- (BOOL)canPingAPIServer {
	return (YES);
//	return (!([[Reachability reachabilityWithHostName:[[[[HONAPICaller sharedInstance] phpAPIBasePath] componentsSeparatedByString: @"/"] objectAtIndex:2]] currentReachabilityStatus] == NotReachable));
}


- (BOOL)canPingConfigServer {
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


- (void)retrieveLocationFromIPAddressWithCompletion:(void (^)(id result))completion {
	NSDictionary *params = @{};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"GET", @"http://ip-api.com", @"json", params);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://ip-api.com"]];
	[httpClient getPath:@"json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
			
		} else {
			SelfieclubJSONLog(@"AFNetworking [-] %@ |[:]>> IP LOCATION [:]|>>\n%@", [[self class] description], result);
			
			if ([result isEqual:[NSNull null]]) {
				[[HONAPICaller sharedInstance] showDataErrorHUD];
			}
			
			else {
				NSDictionary *dict = @{@"city"		: [result objectForKey:@"city"],
									   @"country"	: [result objectForKey:@"country"],
									   @"state"		: [result objectForKey:@"region"],
									   @"region"	: [result objectForKey:@"regionName"],
									   @"lat"		: [result objectForKey:@"lat"],
									   @"lon"		: [result objectForKey:@"lon"]};
				
				if (completion)
					completion(dict);
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
		
	}];
}



- (void)retreiveBootConfigWithCompletion:(void (^)(id result))completion {
	NSDictionary *params = @{@"epoch"	: @([NSDate elapsedUTCSecondsSinceUnixEpoch])};
	
	SelfieclubJSONLog(@"\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\nCONFIG_JSON:[%@/%@]", kConfigURL, kConfigJSON);
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"GET", kConfigURL, kConfigJSON, params);

	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kConfigURL]];
	[httpClient getPath:kConfigJSON parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];

			
		} else {
//			SelfieclubJSONLog(@"AFNetworking [-] %@ |[:]>> BOOT JSON [:]|>>\n%@", [[self class] description], result);
			
			if ([result isEqual:[NSNull null]]) {
				[[HONAPICaller sharedInstance] showDataErrorHUD];
			}
			
			else {
				if (completion)
					completion(result);
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, [error localizedDescription]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];

	}];
}


#pragma mark - Images
- (void)notifyToCreateImageSizesForPrefix:(NSString *)prefixURL forBucketType:(HONAmazonS3BucketType)bucketType completion:(void (^)(id result))completion {
	[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:prefixURL forBucketType:bucketType preDelay:kNotifiyDelay completion:completion];
}

- (void)notifyToCreateImageSizesForPrefix:(NSString *)prefixURL forBucketType:(HONAmazonS3BucketType)bucketType preDelay:(int64_t)delay completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"imgURL"	: [[HONAPICaller sharedInstance] normalizePrefixForImageURL:prefixURL]};
	
	dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
	dispatch_after(dispatchTime, dispatch_get_main_queue(), ^(void) {
		SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], (bucketType == HONAmazonS3BucketTypeAvatarsSource) ? kAPIProcessUserImage : (bucketType == HONAmazonS3BucketTypeClubsSource) ? kAPIProcessChallengeImage : (bucketType == HONAmazonS3BucketTypeClubsSource) ? kAPIClubsProcessImage : kAPIProcessChallengeImage, params);
		AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
		[httpClient postPath:(bucketType == HONAmazonS3BucketTypeAvatarsSource) ? kAPIProcessUserImage : (bucketType == HONAmazonS3BucketTypeClubsSource) ? kAPIProcessChallengeImage : (bucketType == HONAmazonS3BucketTypeClubsSource) ? kAPIClubsProcessImage : kAPIProcessChallengeImage parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSError *error = nil;
			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			
			if (error != nil) {
				SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
				[[HONAPICaller sharedInstance] showDataErrorHUD];
				
			} else {
				SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
				
				if (completion)
					completion(result);
			}
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], (bucketType == HONAmazonS3BucketTypeAvatarsSource) ? kAPIProcessUserImage : (bucketType == HONAmazonS3BucketTypeClubsSource) ? kAPIProcessChallengeImage : (bucketType == HONAmazonS3BucketTypeClubsSource) ? kAPIClubsProcessImage : kAPIProcessChallengeImage, [error localizedDescription]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
		}];
	});
}

//- (void)uploadPhotosToS3:(NSArray *)imageData intoBucketType:(HONS3BucketType)bucketType withFilename:(NSString *)filename completion:(void (^)(id result))completion {
//	NSString *bucketName = (bucketType == HONS3BucketTypeAvatars) ? @"hotornot-avatars" : (bucketType == HONS3BucketTypeSelfies) ? @"hotornot-challenges" : (bucketType == HONS3BucketTypeClubs) ? @"hotornot-challenges" : @"hotornot-challenges";
	
//	S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[filename stringByAppendingString:kSnapLargeSuffix] inBucket:bucketName];
//	por1.data = [imageData objectAtIndex:0];
//	por1.requestTag = [NSString stringWithFormat:@"%@|%@|%u", por1.bucket, kSnapLargeSuffix, bucketType];
//	por1.contentType = @"image/jpeg";
//	por1.delegate = self;
//	
//	S3PutObjectRequest *por2 = [[S3PutObjectRequest alloc] initWithKey:[filename stringByAppendingString:kSnapTabSuffix] inBucket:bucketName];
//	por2.data = [imageData objectAtIndex:1];
//	por2.requestTag = [NSString stringWithFormat:@"%@|%@|%u", por2.bucket, kSnapTabSuffix, bucketType];
//	por2.contentType = @"image/jpeg";
//	por2.delegate = self;
//	
//	_awsUploadCounter = 0;
//	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAPICaller s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAPICaller s3Credentials] objectForKey:@"secret"]];
//	
//	@try {
//		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:bucketName]];
//		[s3 putObject:por1];
//		[s3 putObject:por2];
//		
//	} @catch (AmazonClientException *exception) {
//		if (_progressHUD == nil)
//			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
//		
//		_progressHUD.minShowTime = kProgressHUDMinDuration;
//		_progressHUD.mode = MBProgressHUDModeCustomView;
//		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
//		_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
//		[_progressHUD show:NO];
//		[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
//		_progressHUD = nil;
//		
//		if ([bucketName rangeOfString:@"hotornot-challenges"].location != NSNotFound)
//			[[HONImageBroker sharedInstance] writeImageFromWeb:[NSString stringWithFormat:@"%@/defaultAvatar%@", [HONAPICaller s3BucketForType:HONAmazonS3BucketTypeAvatarsSource], kSnapLargeSuffix] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
//	}
//	
//	if (completion)
//		completion(nil);
//}

- (void)uploadPhotoToS3:(NSData *)imageData intoBucketType:(HONAmazonS3BucketType)bucketType withFilename:(NSString *)filename completion:(void (^)(BOOL success, NSError * error))completion {
	NSString *bucketName = (bucketType == HONAmazonS3BucketTypeAvatarsSource) ? @"hotornot-avatars" : (bucketType == HONAmazonS3BucketTypeClubsSource) ? @"hotornot-challenges" : @"hotornot-challenges";

	NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[filename stringByAppendingString:kPhotoHDSuffix]];
	[imageData writeToFile:path atomically:YES];
	
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	
	AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
	uploadRequest.bucket = bucketName;
	uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
	uploadRequest.key = [[path pathComponents] lastObject];
	uploadRequest.contentType = @"image/jpeg";
	uploadRequest.body = url;
	
	AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
	[[transferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
		if (task.error)
			NSLog(@"AWSS3TransferManager: **ERROR** [%@]", task.error);
			
		else
			NSLog(@"AWSS3TransferManager: !!SUCCESS!! [%@]", task.error);
		
		
		if (completion)
			completion((task.error == nil), task.error);
		
		
		return (nil);
	}];
}


#pragma mark - Users
- (void)checkForAvailableUsername:(NSString *)username completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: @([[HONUserAssistant sharedInstance] activeUserID]),
							 @"username"	: username};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsersCheckUsername, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsersCheckUsername parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@ ) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsersCheckUsername, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)checkForAvailablePhone:(NSString *)phone completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"	: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"phone"	: phone,
							 @"sku"		: [[[[NSBundle mainBundle] bundleIdentifier] componentsSeparatedByString:@"."] lastObject]};//phone};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsersCheckPhone, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsersCheckPhone parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@ ) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsersCheckPhone, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)deactivateUserWithCompletion:(void (^)(id result))completion {
	SelfieclubJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIPurgeUser);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIPurgeUser parameters:[NSDictionary dictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIPurgeUser, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)finalizeUserWithDictionary:(NSDictionary *)dict completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"		: @(9),
							 @"userID"		: @([[dict objectForKey:@"user_id"] intValue]),
							 @"username"	: [dict objectForKey:@"username"],
							 @"password"	: [dict objectForKey:@"phone"],
							 @"age"	 		: @"0000-00-00 00:00:00",
							 @"token"		: @"",
							 @"imgURL"		: [[HONUserAssistant sharedInstance] rndAvatarURL],
							 @"sku"			: [[[[NSBundle mainBundle] bundleIdentifier] componentsSeparatedByString:@"."] lastObject]};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsersFirstRunComplete, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsersFirstRunComplete parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@\n%@", [[self class] description], [error localizedFailureReason], result);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@ ) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)flagUserByUserID:(int)userID completion:(void (^)(id result))completion {
	[[HONAPICaller sharedInstance] verifyUserWithUserID:userID asLegit:NO completion:completion];
}

- (void)recreateUserWithCompletion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"	: NSStringFromInt(1)};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)registerNewUserWithCompletion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"	: NSStringFromInt(1)};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveActivityForUserByUserID:(int)userID fromPage:(int)page completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"format"		: @"json",
							 @"member_id"	: @(userID),
							 @"page"		: @(page)};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"GET", [[HONAPICaller sharedInstance] pythonAPIBasePath], @"newsfeed/member/", params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPythonBasePath];
	[httpClient getPath: @"newsfeed/member/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] pythonAPIBasePath], @"newsfeed/member/", [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveActivityTotalForUserByUserID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"format"		: @"json",
							 @"member_id"	: @(userID)};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"GET", [[HONAPICaller sharedInstance] pythonAPIBasePath], @"newsfeed/member/", params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPythonBasePath];
	[httpClient getPath: @"newsfeed/member/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) COUNT:[%@]", [[self class] description], [[operation request] URL], [result objectForKey:@"count"]);
			
//			__block int cnt = [[result objectForKey:@"count"] intValue];
			__block int score = 0;
			[[result objectForKey:@"results"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSDictionary *dict = (NSDictionary *)obj;
				
//				NSLog(@"VOTE:[%d / %d]~(%@) -=- \"%@\"", [[dict objectForKey:@"status_update_id"] intValue], [[[dict objectForKey:@"subject_member"] objectForKey:@"id"] intValue], NSStringFromBOOL(([[[dict objectForKey:@"event_type"] uppercaseString] isEqualToString:@"STATUS_UPVOTED"])), [dict objectForKey:@"event_type"]);
				if ([[[dict objectForKey:@"event_type"] uppercaseString] isEqualToString:@"STATUS_UPVOTED"])
					score++;
				
				else if ([[[dict objectForKey:@"event_type"] uppercaseString] isEqualToString:@"STATUS_DOWNVOTED"])
					score--;
			}];
			
//			cnt -= 10;
			
//				if (cnt > 0)
//					[[HONAPICaller sharedInstance] retrieveActivityTotalForUserByUserID:<#(int)#> completion:<#^(id result)completion#>]
			
			if (completion)
				completion(@(score));
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] pythonAPIBasePath], @"newsfeed/member/", [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveNewActivityForUserByUserID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"format"		: @"json",
							 @"member_id"	: @(userID)};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"GET", [[HONAPICaller sharedInstance] pythonAPIBasePath], @"newsfeed/member/", params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPythonBasePath];
	[httpClient getPath: @"newsfeed/member/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		__block int score = 0;
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			[[result objectForKey:@"results"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSDictionary *dict = (NSDictionary *)obj;
				
				
				NSLog(@"VOTE:[%@] (%@)", [dict objectForKey:@"event_type"], @"");
				if ([[dict objectForKey:@"event_type"] isEqualToString:@"STATUS_UPVOTED"])
					score++;
				
				else
					score--;
			}];
			
			if (completion)
				completion(@(score));
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] pythonAPIBasePath], @"newsfeed/member/", [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveChallengesForUserByUserID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: @(userID),
							 @"action"		: @(10),
							 @"isPrivate"	: @"N"};
	
	SelfieclubJSONLog(@"%@ _retrieveChallenges —/> (%@/%@)\n%@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIVotes, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [result firstObject]);
			SelfieclubJSONLog(@"AFNetworking [-] %@: FEED TOTAL %ld", [[self class] description], (unsigned long)[result count]);
			
			if (completion)
				completion(result);
		}
				
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIVotes, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveChallengesForUserByUsername:(NSString *)username completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"action"		: NSStringFromInt(9),
							 @"isPrivate"	: @"N",
							 @"username"	: username,
							 @"p"			: NSStringFromInt(1)};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIVotes, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [result firstObject]);
			SelfieclubJSONLog(@"AFNetworking [-] %@: USER CHALLENGES:[%ld]", [[self class] description], (unsigned long)[result count]);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIVotes, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveTopClubsForUserWithUserID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"	: @(userID),
							 @"sort"	: @"top"};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsersGetClubs, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsersGetClubs parameters:[params copy] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);

			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsersGetClubs, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveRecentClubsForUserByUserID:(int)userID afterDate:(NSDate *)date completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"	: @(userID)};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsersGetClubs, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsersGetClubs parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//						SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsersGetClubs, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveClubsForUserByUserID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"	: @(userID)};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsersGetClubs, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsersGetClubs parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsersGetClubs, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveStatusUpdatesForUserByUserID:(int)userID fromPage:(int)page completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"page"	: @(page),
							 @"format"	: @"json"};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"GET", [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:kAPIMemberStatusUpdates, userID], params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPythonBasePath];
	[httpClient getPath:[NSString stringWithFormat:kAPIMemberStatusUpdates, userID] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			//SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) Failed Request - %@", [[self class] description], [[operation request] URL], [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveUserByUserID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"	: NSStringFromInt(5),
							 @"userID"	: @(userID)};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, [error localizedDescription]);
		
		if ([error.description isEqualToString:kNetErrorNoConnection]) {
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kProgressHUDMinDuration;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = @"No network connection!";
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
			_progressHUD = nil;
		}
	}];
}

- (void)removeAllChallengesForUserWithCompletion:(void (^)(id result))completion {
	SelfieclubJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIPurgeContent);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIPurgeContent parameters:[NSDictionary dictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) Failed Request - %@", [[self class] description], [[operation request] URL], [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)removeUserFromVerifyListWithUserID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"		: @(10),
							 @"userID"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"targetID"	: @(userID),
							 @"approves"	: @(-1)};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)submitPasscodeToLiftAccountSuspension:(NSString *)passcode completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"passcode"	: passcode};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPISuspendedAccount, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPISuspendedAccount parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)togglePushNotificationsForUserByUserID:(int)userID areEnabled:(BOOL)isEnabled completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"			: NSStringFromInt(4),
							 @"userID"			: @(userID),
							 @"isNotifications"	: (isEnabled) ? @"Y" : @"N"};
	
	SelfieclubJSONLog(@"%@ —/> (%@/%@)\n%@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)updateAvatarWithImagePrefix:(NSString *)avatarPrefix completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"		: NSStringFromInt(9),
							 @"userID"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"username"	: [[HONUserAssistant sharedInstance] activeUsername],
							 @"imgURL"		: avatarPrefix};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [NSString stringWithFormat:@"%@ \"%@\"", [[self class] description], @"updateAvatarWithImagePrefix"], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)updateTabBarBadgeTotalsForUserByUserID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"	: NSStringFromInt(3),
							 @"userID"	: @(userID)};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIChallenges, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)updateUsernameForUser:(NSString *)username completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"		: NSStringFromInt(7),
							 @"userID"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"username"	: username};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [NSString stringWithFormat:@"%@ \"%@\"", [[self class] description], @"updateUsernameForUser"], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)updatePhoneNumberForUserWithCompletion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"	: @([[HONUserAssistant sharedInstance] activeUserID]),
							 @"phone"	: [[HONDeviceIntrinsics sharedInstance] phoneNumber]};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsersUpdatePhone, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsersUpdatePhone parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [NSString stringWithFormat:@"%@ \"%@\"", [[self class] description], @"updatePhoneNumberForUserWithCompletion"], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsersUpdatePhone, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)validatePhoneNumberForUser:(int)userID usingPINCode:(NSString *)pinCode completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"	: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"phone"	: [[HONDeviceIntrinsics sharedInstance] phoneNumber],
							 @"pin"		: pinCode};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsersValidatePIN, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsersValidatePIN parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsersValidatePIN, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)updateDeviceTokenWithCompletion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"	: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"token"	: ([[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"] != nil) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"] : @""};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsersSetDeviceToken, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsersSetDeviceToken parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsersSetDeviceToken, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)verifyUserWithUserID:(int)userID asLegit:(BOOL)isLegit completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"		: @(10),
							 @"userID"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"targetID"	: @(userID),
							 @"approves"	: @((int)isLegit)};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}


#pragma mark - Challenges
- (void)createShoutoutChallengeWithChallengeID:(int)challengeID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"challengeID"	: @(challengeID),
							 @"userID"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID])};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIVerifyShoutout, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIVerifyShoutout parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)createShoutoutChallengeWithUserID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"targetID"	: @(userID)};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIProfileShoutout, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIProfileShoutout parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)flagStatusUpdateByStatusUpdateID:(int)statusUpdateID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"member_id"	: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"vote"		: @"flag"};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:@"statusupdate/%d/voters/", statusUpdateID], params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPythonBasePath];
	[httpClient postPath:[NSString stringWithFormat:@"statusupdate/%d/voters/", statusUpdateID] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:@"statusupdate/%d/voters/", statusUpdateID], [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)markChallengeAsSeenWithChallengeID:(int)challengeID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"member_id"	: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID])};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:@"statusupdate/%d/viewers/", challengeID], params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPythonBasePath];
	[httpClient postPath:[NSString stringWithFormat:@"statusupdate/%d/viewers/", challengeID] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:@"statusupdate/%d/viewers/", challengeID], [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)removeChallengeForChallengeID:(int)challengeID withImagePrefix:(NSString *)imagePrefix completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"challengeID"	: @(challengeID),
							 @"imgURL"		: imagePrefix};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIDeleteImage, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIDeleteImage parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveChallengeForChallengeID:(int)challengeID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"challengeID"	: @(challengeID)};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIChallengeObject, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIChallengeObject parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
//			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
			if (completion)
				completion(@{});
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveChallengeForChallengeID:(int)challengeID igoringNextPushes:(BOOL)isIgnore completion:(void (^)(id result))completion {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(challengeID), @"challengeID", nil];
	
	if (isIgnore)
		[params setObject:NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]) forKey:@"cancelFor"];
	
	SelfieclubJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIChallengeObject);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIChallengeObject parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveSeenTotalForChallengeWithChallengeID:(int)challengeID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"format"	: @"json"};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"GET", [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:@"statusupdate/%d/viewers/", challengeID], params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPythonBasePath];
	[httpClient getPath:[NSString stringWithFormat:@"statusupdate/%d/viewers/", challengeID] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:@"statusupdate/%d/viewers/", challengeID], [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveSeenMembersChallengeWithChallengeID:(int)challengeID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"format"	: @"json"};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"GET", [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:@"statusupdate/%d/viewers/", challengeID], params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPythonBasePath];
	[httpClient getPath:[NSString stringWithFormat:@"statusupdate/%d/viewers/", challengeID] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:@"statusupdate/%d/viewers/", challengeID], [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveVerifyListForUserID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"	: @(userID)};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIGetVerifyList, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIGetVerifyList parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSString stringWithFormat:@"TOTAL:[%ld]", (long int)[result count]]);
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [result objectAtIndex:0]);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveVoteTotalForStatusUpdateByStatusUpdateID:(int)statusUpdateID completion:(void (^)(id))completion {
	NSDictionary *params = @{@"format"	: @"json"};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"GET", [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:@"statusupdate/%d/voters/", statusUpdateID], params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPythonBasePath];
	[httpClient getPath:[NSString stringWithFormat:@"statusupdate/%d/voters/", statusUpdateID] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			__block int score = 0;
			[[result objectForKey:@"results"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSDictionary *dict = (NSDictionary *)obj;
				
				if ([[[dict objectForKey:@"vote"] lowercaseString] isEqualToString:@"up"])
					score++;
				
				else if ([[[dict objectForKey:@"vote"] lowercaseString] isEqualToString:@"down"])
					score--;
			}];
			
			if (completion)
				completion(@(score));
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:@"statusupdate/%d/voters/", statusUpdateID], [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)upvoteChallengeWithChallengeID:(int)challengeID forOpponent:(HONClubPhotoVO *)opponentVO completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"			: NSStringFromInt(6),
							 @"userID"			: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"challengeID"		: @(challengeID),
							 @"challengerID"	: @(opponentVO.userID),
							 @"imgURL"			: opponentVO.imagePrefix};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIVotes, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIVotes, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)voteClubPhotoWithChallengeID:(int)challengeID isUpVote:(BOOL)isUpVote completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"member_id"	: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"vote"		: (isUpVote) ? @"up" : @"down"};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:@"statusupdate/%d/voters/", challengeID], params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPythonBasePath];
	[httpClient postPath:[NSString stringWithFormat:@"statusupdate/%d/voters/", challengeID] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:@"statusupdate/%d/voters/", challengeID], [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)voteStatusUpdateWithStatusUpdateID:(int)statusUpdateID isUpVote:(BOOL)isUpVote completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"member_id"	: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"vote"		: (isUpVote) ? @"up" : @"down"};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:@"statusupdate/%d/voters/", statusUpdateID], params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPythonBasePath];
	[httpClient postPath:[NSString stringWithFormat:@"statusupdate/%d/voters/", statusUpdateID] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:@"statusupdate/%d/voters/", statusUpdateID], [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}


#pragma mark - Messages
//- (void)markMessageAsSeenForMessageID:(int)messageID forParticipant:(int)userID completion:(void (^)(id result))completion {
//	NSDictionary *params = @{@"challengeID"	: @(messageID),
//							 @"userID"		: @(userID)};
//	
//	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIChallengesMessageSeen, params);
//	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
//	[httpClient postPath:kAPIChallengesMessageSeen parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		NSError *error = nil;
//		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//		
//		if (error != nil) {
//			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
//			[[HONAPICaller sharedInstance] showDataErrorHUD];
//			
//		} else {
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
//			if (completion)
//				completion(result);
//		}
//		
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIChallenges, [error localizedDescription]);
//		[[HONAPICaller sharedInstance] showDataErrorHUD];
//	}];
//}
//
//- (void)retrieveMessageForMessageID:(int)messageID completion:(void (^)(id result))completion {
//	[[HONAPICaller sharedInstance] retrieveChallengeForChallengeID:messageID completion:completion];
//}
//
//- (void)retrieveMessagesForUserByUserID:(int)userID completion:(void (^)(id result))completion {
//	NSDictionary *params = @{@"userID"		: @(userID)};
//	
//	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIChallengesMessageSeen, params);
//	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
//	[httpClient postPath:kAPIGetMessages parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		NSError *error = nil;
//		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//		
//		if (error != nil) {
//			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
//			[[HONAPICaller sharedInstance] showDataErrorHUD];
//			
//		} else {
////			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
////			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [result firstObject]);
//			SelfieclubJSONLog(@"AFNetworking [-] %@: MESSAGES TOTAL %d", [[self class] description], [result count]);
//			
//			if (completion)
//				completion(result);
//		}
//		
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIVotes, [error localizedDescription]);
//		[[HONAPICaller sharedInstance] showDataErrorHUD];
//	}];
//}
//
//- (void)submitNewMessageWithDictionary:(NSDictionary *)dict completion:(void (^)(id result))completion {
//	NSDictionary *params = @{@"userID"		: [dict objectForKey:@"user_id"],
//							 @"imgURL"		: [dict objectForKey:@"img_url"],
//							 @"subject"		: [dict objectForKey:@"subject"],
//							 @"targets"		: [dict objectForKey:@"recipients"],
//							 @"isPrivate"	: @"Y"};
//	
//	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPICreateMessage, params);
//	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
//	[httpClient postPath:kAPICreateMessage parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		NSError *error = nil;
//		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//		
//		if (error != nil) {
//			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
//			[[HONAPICaller sharedInstance] showDataErrorHUD];
//			
//		} else {
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
//			
//			if (completion)
//				completion(result);
//		}
//		
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIChallenges, [error localizedDescription]);
//		[[HONAPICaller sharedInstance] showDataErrorHUD];
//	}];
//}


#pragma mark - Clubs
- (void)retrieveUserClubsByUserID:(int)userID fromPage:(int)page completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"page"	: @(page),
							 @"format"	: @"json"};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"GET", [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:kAPIMemberClubs, userID], params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPythonBasePath];
	[httpClient getPath:[NSString stringWithFormat:kAPIMemberClubs, userID] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) Failed Request - %@", [[self class] description], [[operation request] URL], [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}




- (void)retrieveStatusUpdatesForClubByClubID:(int)clubID fromPage:(int)page completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"page"	: @(page),
							 @"format"	: @"json"};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"GET", [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:kAPIClubStatusUpdates, clubID], params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPythonBasePath];
	[httpClient getPath:[NSString stringWithFormat:kAPIClubStatusUpdates, clubID] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) Failed Request - %@", [[self class] description], [[operation request] URL], [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveStatusUpdateByStatusUpdateID:(int)statusUpdateID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"format"	: @"json"};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"GET", [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:kAPIStatusUpdate, statusUpdateID], params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPythonBasePath];
	[httpClient getPath:[NSString stringWithFormat:kAPIStatusUpdate, statusUpdateID] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			//[[HONAPICaller sharedInstance] showDataErrorHUD];
			
			if (completion)
				completion(@{@"detail"	: @"Not found"});
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) Failed Request - %@", [[self class] description], [[operation request] URL], [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveRepliesForStatusUpdateByStatusUpdateID:(int)statusUpdateID fromPage:(int)page completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"page"	: @(page),
							 @"format"	: @"json"};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"GET", [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:kAPIStatusUpdateChildren, statusUpdateID], params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPythonBasePath];
	[httpClient getPath:[NSString stringWithFormat:kAPIStatusUpdateChildren, statusUpdateID] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) Failed Request - %@", [[self class] description], [[operation request] URL], [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}


- (void)createClubWithTitle:(NSString *)title withDescription:(NSString *)blurb withImagePrefix:(NSString *)imagePrefix atLocation:(CLLocation *)location completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"name"		: title,
							 @"description"	: blurb,
							 @"imgURL"		: imagePrefix,
							 @"lat"			: @(location.coordinate.latitude),
							 @"lon"			: @(location.coordinate.longitude)};

	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIClubsCreate, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIClubsCreate parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIClubsCreate, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)createClubWithTitle:(NSString *)title withDescription:(NSString *)blurb withImagePrefix:(NSString *)imagePrefix completion:(void (^)(id result))completion {
	[[HONAPICaller sharedInstance] createClubWithTitle:title withDescription:blurb withImagePrefix:imagePrefix atLocation:[[HONDeviceIntrinsics sharedInstance] deviceLocation] completion:^(NSDictionary *result) {
		if (completion)
			completion(result);
	}];
}

- (void)deleteClubWithClubID:(int)clubID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"clubID"		: @(clubID),
							 @"ownerID"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID])};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIClubsDelete, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIClubsDelete parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIClubsDelete, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)editClubWithClubID:(int)clubID withTitle:(NSString *)title withDescription:(NSString *)blurb withImagePrefix:(NSString *)imagePrefix completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"clubID"		: @(clubID),
							 @"ownerID"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"name"		: title,
							 @"description"	: blurb,
							 @"imgURL"		: imagePrefix};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIClubsEdit, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIClubsEdit parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIClubsEdit, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)inviteInAppUsers:(NSArray *)inAppUsers toClubWithID:(int)clubID withClubOwnerID:(int)ownerID completion:(void (^)(id result))completion {
	[[HONAPICaller sharedInstance] inviteInAppUsers:inAppUsers toClubWithID:clubID withClubOwnerID:ownerID inviteNonAppContacts:@[] completion:completion];
}

- (void)inviteInAppUsers:(NSArray *)inAppUsers toClubWithID:(int)clubID withClubOwnerID:(int)ownerID inviteNonAppContacts:(NSArray*)nonAppContacts completion:(void (^)(id result))completion {
	
	NSString *userIDs = @"";
	for (HONUserVO *vo in inAppUsers)
		userIDs = [userIDs stringByAppendingFormat:@"%d,", vo.userID];
	
	NSString *contacts = @"";
	for (HONContactUserVO *vo in nonAppContacts)
		contacts = [contacts stringByAppendingFormat:@"%@:::%@:::%@|||", vo.fullName, vo.mobileNumber, vo.email];
	
	NSDictionary *params = @{@"clubID"		: @(clubID),
							 @"userID"		: @(ownerID),
							 @"users"		: ([inAppUsers count] > 0) ? [userIDs substringToIndex:[userIDs length] - 1] : @"",
							 @"nonUsers"	: ([nonAppContacts count] > 0) ? [contacts substringToIndex:[contacts length] - 3] : @""};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIClubsInvite, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIClubsInvite parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIClubsInvite, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)inviteNonAppUsers:(NSArray *)contacts toClubWithID:(int)clubID withClubOwnerID:(int)ownerID completion:(void (^)(id result))completion {
	[[HONAPICaller sharedInstance] inviteInAppUsers:@[] toClubWithID:clubID withClubOwnerID:ownerID inviteNonAppContacts:contacts completion:completion];
}

- (void)joinClub:(HONUserClubVO *)userClubVO completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"clubID"		: @(userClubVO.clubID),
							 @"ownerID"		: @(userClubVO.ownerID),
							 @"userID"		: @([[HONUserAssistant sharedInstance] activeUserID])};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIClubsJoin, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIClubsJoin parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIClubsJoin, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)leaveClub:(HONUserClubVO *)userClubVO completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"clubID"		: @(userClubVO.clubID),
							 @"ownerID"		: @(userClubVO.ownerID),
							 @"memeberID"	: @([[HONUserAssistant sharedInstance] activeUserID])};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIClubsQuit, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIClubsQuit parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIClubsQuit, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveClubByClubID:(int)clubID withOwnerID:(int)ownerID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"clubID"		: @(clubID),
							 @"userID"		: @(ownerID)};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIClubsGet, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIClubsGet parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIClubsGet, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveClubInvitesForUserWithUserID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: @(userID)};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsersGetClubInvites, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsersGetClubInvites parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsersGetClubInvites, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveFeaturedClubsWithCompletion:(void (^)(id result))completion {
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@)\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIClubsFeatured);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIClubsFeatured parameters:[NSDictionary dictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIClubsFeatured, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveLocalSchoolTypeClubsWithAreaCode:(NSString *)areaCode completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"format"	: @"json"};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@)\n\n", [[self class] description], @"GET", [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:@"club/labeled/areacode-%@-highschool/", areaCode]);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPythonBasePath];
	[httpClient getPath:[NSString stringWithFormat:@"club/labeled/areacode-%@-highschool/", areaCode] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] pythonAPIBasePath], [NSString stringWithFormat:@"club/labeled/areacode-%@-highschool/", areaCode], [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
	
//	} else {
//		if (completion)
//			completion(@{@"clubs"	: @[]});
//	}
}

- (void)retrieveNearbyClubFromLocation:(CLLocation *)location withinRadius:(CGFloat)radius completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"format"	: @"json",
							 @"lat"		: @([[NSString stringWithFormat:@"%.04f", location.coordinate.latitude] floatValue]),
							 @"lon"		: @([[NSString stringWithFormat:@"%.04f", location.coordinate.longitude] floatValue]),
							 @"radius"	: @(radius)};

	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"GET", [[HONAPICaller sharedInstance] pythonAPIBasePath], @"club/", params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPythonBasePath];
	[httpClient getPath: @"club/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [[result objectForKey:@"results"] firstObject]);
			
			if ([[result objectForKey:@"count"] intValue] == 0) {
				if (completion)
					completion([@{} mutableCopy]);
			
			} else {
				NSDictionary *dict = [[result objectForKey:@"results"] firstObject];
				
				if (completion)
					completion([dict mutableCopy]);
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] pythonAPIBasePath], @"club/", [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)searchForClubsByClubName:(NSString *)name completion:(void (^)(id result))completion {
	[[HONAPICaller sharedInstance] retrieveLocalSchoolTypeClubsWithAreaCode:[[HONDeviceIntrinsics sharedInstance] areaCodeFromPhoneNumber] completion:completion];
}

- (void)submitStatusUpdateWithDictionary:(NSDictionary *)dict completion:(void (^)(id))completion {
	NSDictionary *params = @{@"userID"		: ([dict objectForKey:@"user_id"] != nil) ? @([[dict objectForKey:@"user_id"] intValue]) : @([[HONUserAssistant sharedInstance] activeUserID]),
							 @"imgURL"		: ([dict objectForKey:@"img_url"] != nil) ? [dict objectForKey:@"img_url"] : [NSString stringWithFormat:@"%@/%@", [HONAPICaller s3BucketForType:HONAmazonS3BucketTypeClubsSource], [[HONClubAssistant sharedInstance] defaultStatusUpdatePhotoURL]],
							 @"challengeID"	: ([dict objectForKey:@"img_url"] != nil) ? @([[dict objectForKey:@"challenge_id"] intValue]) : @(0),
							 @"clubID"		: ([dict objectForKey:@"club_id"] != nil) ? @([[dict objectForKey:@"club_id"] intValue]) : @(0),
							 @"subject"		: ([dict objectForKey:@"subject"] != nil) ? [dict objectForKey:@"subject"] : @"",
							 @"subjects"	: ([dict objectForKey:@"subjects"] != nil) ? [dict objectForKey:@"subjects"] : @"",
							 @"targets"		: ([dict objectForKey:@"targets"] != nil) ? [dict objectForKey:@"targets"] : @""};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPICreateChallenge, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPICreateChallenge parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPICreateChallenge, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

//- (void)submitClubPhotoWithDictionary:(NSDictionary *)dict completion:(void (^)(id result))completion {
//	NSDictionary *params = @{@"userID"		: ([dict objectForKey:@"user_id"] != nil) ? @([[dict objectForKey:@"user_id"] intValue]) : @([[HONUserAssistant sharedInstance] activeUserID]),
//							 @"imgURL"		: ([dict objectForKey:@"img_url"] != nil) ? [dict objectForKey:@"img_url"] : [NSString stringWithFormat:@"%@/%@", [HONAPICaller s3BucketForType:HONAmazonS3BucketTypeClubsSource], [[HONClubAssistant sharedInstance] defaultClubPhotoURL]],
//							 @"challengeID"	: ([dict objectForKey:@"img_url"] != nil) ? @([[dict objectForKey:@"challenge_id"] intValue]) : @(0),
//							 @"clubID"		: ([dict objectForKey:@"club_id"] != nil) ? @([[dict objectForKey:@"club_id"] intValue]) : @(0),
//							 @"subject"		: ([dict objectForKey:@"subject"] != nil) ? [dict objectForKey:@"subject"] : @"",
//							 @"subjects"	: ([dict objectForKey:@"subjects"] != nil) ? [dict objectForKey:@"subjects"] : @"",
//							 @"targets"		: ([dict objectForKey:@"targets"] != nil) ? [dict objectForKey:@"targets"] : @""};
//	
//	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPICreateChallenge, params);
//	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
//	[httpClient postPath:kAPICreateChallenge parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		NSError *error = nil;
//		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//		
//		if (error != nil) {
//			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
//			[[HONAPICaller sharedInstance] showDataErrorHUD];
//			
//		} else {
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
//			
//			if (completion)
//				completion(result);
//		}
//		
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPICreateChallenge, [error localizedDescription]);
//		[[HONAPICaller sharedInstance] showDataErrorHUD];
//	}];
//}


#pragma mark - Invite / Social
- (void)searchUsersByPhoneNumber:(NSString *)phoneNumber completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"	: @(13),
							 @"userID"	: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"phone"	: phoneNumber};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			result = [NSMutableArray arrayWithArray:[[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]
													 sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)searchForUsersByUsername:(NSString *)username completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"		: NSStringFromInt(1),
							 @"username"	: username};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPISearch, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPISearch parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			result = [NSArray arrayWithArray:[[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]
											  sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPISearch, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)sendEmailInvitesWithDelimitedList:(NSString *)emailAddresses completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"addresses"	: emailAddresses};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIEmailInvites, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIEmailInvites parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIEmailInvites, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)sendSMSInvitesWithDelimitedList:(NSString *)phoneNumbers completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"numbers"		: phoneNumbers};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPISMSInvites, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPISMSInvites parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPISMSInvites, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)submitDelimitedEmailContacts:(NSString *)emailAddresses completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"emailList"	: emailAddresses};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIEmailContacts, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIEmailContacts parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			result = [NSMutableArray arrayWithArray:[[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]
													 sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIEmailContacts, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)submitDelimitedPhoneContacts:(NSString *)phoneNumbers completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"	: @(11),
							 @"userID"	: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"phone"	: phoneNumbers};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			//SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			result = [NSMutableArray arrayWithArray:[[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]
													 sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)submitEmailAddressForUserMatching:(NSString *)email completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"	: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"code"	: [[[HONUserAssistant sharedInstance] activeUserInfo] objectForKey:@"sms_code"],
							 @"email"	: email};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIEmailVerify, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIEmailVerify parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIEmailVerify, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)submitPhoneNumberForUserMatching:(NSString *)phoneNumber completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"	: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							 @"code"	: [[[HONUserAssistant sharedInstance] activeUserInfo] objectForKey:@"sms_code"],
							 @"phone"	: phoneNumber};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIPhoneVerify, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingPHPBasePath];
	[httpClient postPath:kAPIPhoneVerify parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			//SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] phpAPIBasePath], kAPIPhoneVerify, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}


#pragma mark - UI Presentation
- (void)showDataErrorHUD {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.minShowTime = kProgressHUDMinDuration;
	_progressHUD.mode = MBProgressHUDModeCustomView;
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
	_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
	[_progressHUD show:NO];
	[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
	_progressHUD = nil;
}

- (void)showSuccessHUD {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.minShowTime = kProgressHUDMinDuration;
	_progressHUD.mode = MBProgressHUDModeCustomView;
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_pass"]];
	[_progressHUD show:NO];
	[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
	_progressHUD = nil;
}


- (NSSet *)requestQueue {
	return (_requestQueueSet);
}

- (void)addRequestToQueue:(AFHTTPRequestOperation *)requestOperation {
	[_requestQueueSet addObject:requestOperation];
}

- (void)removeRequestToQueue:(AFHTTPRequestOperation *)requestOperation {
	[_requestQueueSet removeObject:requestOperation];
}


//#pragma mark - AWS Delegates
//- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
//	NSArray *tag = [request.requestTag componentsSeparatedByString:@"|"];
//	NSLog(@"\nAWS didCompleteWithResponse:\n[%@] - %@", tag, request.url);
//	
//	if ([[tag objectAtIndex:1] isEqualToString:kSnapLargeSuffix]) {
//		switch ((HONAmazonS3BucketType)[[tag objectAtIndex:2] intValue]) {
//			case HONAmazonS3BucketTypeAvatarsSource:
//				break;
//				
//			case HONAmazonS3BucketTypeClubsSource:
//				break;
//				
//			default:
//				break;
//		}
//	}
//	
//	_awsUploadCounter++;
//	if (_awsUploadCounter == 2) {
//		_awsUploadCounter = 0;
//	}
//}
//
//- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
//	NSLog(@"AWS didFailWithError:\n%@", [error description]);
////	NSArray *tag = [request.requestTag componentsSeparatedByString:@"|"];
//	
//	if (_progressHUD == nil)
//		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
//	_progressHUD.minShowTime = kProgressHUDMinDuration;
//	_progressHUD.mode = MBProgressHUDModeCustomView;
//	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
//	_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
//	[_progressHUD show:NO];
//	[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
//	_progressHUD = nil;
//}

@end
