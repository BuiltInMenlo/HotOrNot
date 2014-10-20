	   //
//  HONAPICaller.m
//  HotOrNot
//
//  Created by Matt Holcombe on 12/10/2013 @ 12:40.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import <CommonCrypto/CommonHMAC.h>

#import "NSString+DataTypes.h"

#import "MBProgressHUD.h"

#import "HONAPICaller.h"



//] api endpts [>
//]=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=[>
NSString * const kAPIChallenges	= @"Challenges.php";
NSString * const kAPIComments	= @"Comments.php";
NSString * const kAPISearch		= @"Search.php";
NSString * const kAPIUsers		= @"Users.php";
NSString * const kAPIVotes		= @"Votes.php";

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



const CGFloat kNotifiyDelay = (float)(2 / 3);


//void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error);
//void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
//	SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[[HONAPICaller sharedInstance] class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
//
//	[[HONAPICaller sharedInstance] showDataErrorHUD];
//};

@interface HONAPICaller () <AmazonServiceRequestDelegate>
@property (nonatomic) int awsUploadCounter;
@property (nonatomic, retain) MBProgressHUD *progressHUD;
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
	}
	
	return (self);
}


#pragma mark - Utility
- (AFHTTPClient *)getHttpClientWithHMACUsingBasePath:(NSString *)basePath {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:basePath]];
	[httpClient setDefaultHeader:@"HMAC" value:[[HONDeviceIntrinsics sharedInstance] hmacToken]];
	[httpClient setDefaultHeader:@"X-DEVICE" value:[[HONDeviceIntrinsics sharedInstance] modelName]];
	
	return (httpClient);
}

- (AFHTTPClient *)getHttpClientWithHMAC {
	return ([[HONAPICaller sharedInstance] getHttpClientWithHMACUsingBasePath:[HONAppDelegate apiServerPath]]);
//	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
//	[httpClient setDefaultHeader:@"HMAC" value:[[HONAPICaller sharedInstance] hmacToken]];
//	[httpClient setDefaultHeader:@"X-DEVICE" value:[[HONDeviceIntrinsics sharedInstance] modelName]];
//	
//	return (httpClient);
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




- (void)retreiveBootConfigWithCompletion:(void (^)(id result))completion {
	NSString *configURLWithTimestamp = [NSString stringWithFormat:@"%@?epoch=%d", kConfigJSON, [[HONDateTimeAlloter sharedInstance] elapsedSecondsSinceUnixEpoch]];
	SelfieclubJSONLog(@"\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\nCONFIG_JSON:[%@/%@]", kConfigURL, kConfigJSON);
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@)", [[self class] description], kConfigURL, configURLWithTimestamp);
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kConfigURL]];
	[httpClient postPath:configURLWithTimestamp parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
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
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = NSLocalizedString(@"alert_connectionError_t", @"Connection Error");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;

	}];
}


#pragma mark - Images
- (void)notifyToCreateImageSizesForPrefix:(NSString *)prefixURL forBucketType:(HONS3BucketType)bucketType completion:(void (^)(id result))completion {
	[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:prefixURL forBucketType:bucketType preDelay:kNotifiyDelay completion:completion];
}

- (void)notifyToCreateImageSizesForPrefix:(NSString *)prefixURL forBucketType:(HONS3BucketType)bucketType preDelay:(int64_t)delay completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"imgURL"	: [[HONAPICaller sharedInstance] normalizePrefixForImageURL:prefixURL]};
	
	dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
	dispatch_after(dispatchTime, dispatch_get_main_queue(), ^(void){
		SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], (bucketType == HONS3BucketTypeAvatars) ? kAPIProcessUserImage : (bucketType == HONS3BucketTypeSelfies) ? kAPIProcessChallengeImage : (bucketType == HONS3BucketTypeClubs) ? kAPIClubsProcessImage : kAPIProcessChallengeImage, params);
		AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
		[httpClient postPath:(bucketType == HONS3BucketTypeAvatars) ? kAPIProcessUserImage : (bucketType == HONS3BucketTypeSelfies) ? kAPIProcessChallengeImage : (bucketType == HONS3BucketTypeClubs) ? kAPIClubsProcessImage : kAPIProcessChallengeImage parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSError *error = nil;
			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			
			if (error != nil) {
				SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
				[[HONAPICaller sharedInstance] showDataErrorHUD];
				
			} else {
				SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
				
				if (completion)
					completion(result);
			}
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], (bucketType == HONS3BucketTypeAvatars) ? kAPIProcessUserImage : (bucketType == HONS3BucketTypeSelfies) ? kAPIProcessChallengeImage : (bucketType == HONS3BucketTypeClubs) ? kAPIClubsProcessImage : kAPIProcessChallengeImage, [error localizedDescription]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
		}];
	});
}

- (void)uploadPhotosToS3:(NSArray *)imageData intoBucketType:(HONS3BucketType)bucketType withFilename:(NSString *)filename completion:(void (^)(id result))completion {
	NSString *bucketName = (bucketType == HONS3BucketTypeAvatars) ? @"hotornot-avatars" : (bucketType == HONS3BucketTypeSelfies) ? @"hotornot-challenges" : (bucketType == HONS3BucketTypeClubs) ? @"hotornot-challenges" : @"hotornot-challenges";
	
	S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[filename stringByAppendingString:kSnapLargeSuffix] inBucket:bucketName];
	por1.data = [imageData objectAtIndex:0];
	por1.requestTag = [NSString stringWithFormat:@"%@|%@|%d", por1.bucket, kSnapLargeSuffix, bucketType];
	por1.contentType = @"image/jpeg";
	por1.delegate = self;
	
	S3PutObjectRequest *por2 = [[S3PutObjectRequest alloc] initWithKey:[filename stringByAppendingString:kSnapTabSuffix] inBucket:bucketName];
	por2.data = [imageData objectAtIndex:1];
	por2.requestTag = [NSString stringWithFormat:@"%@|%@|%d", por2.bucket, kSnapTabSuffix, bucketType];
	por2.contentType = @"image/jpeg";
	por2.delegate = self;
	
	_awsUploadCounter = 0;
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	
	@try {
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:bucketName]];
		[s3 putObject:por1];
		[s3 putObject:por2];
		
	} @catch (AmazonClientException *exception) {
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
		
		if ([bucketName rangeOfString:@"hotornot-challenges"].location != NSNotFound)
			[[HONImageBroker sharedInstance] writeImageFromWeb:[NSString stringWithFormat:@"%@/defaultAvatar%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsSource], kSnapLargeSuffix] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
	}
	
	if (completion)
		completion(nil);
}


#pragma mark - Users
//- (void)checkForAvailableUsername:(NSString *)username andPhone:(NSString *)phone completion:(void (^)(id result))completion {
//	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
//							 @"username"	: username,
//							 @"password"	: phone};
//	
//	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPICheckNameAndEmail, params);
//	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
//	[httpClient postPath:kAPICheckNameAndEmail parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		NSError *error = nil;
//		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//		
//		if (error != nil) {
//			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
//			[[HONAPICaller sharedInstance] showDataErrorHUD];
//			
//		} else {
//			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
//			
//			if (completion)
//				completion(result);
//		}
//		
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@ ) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPICheckNameAndEmail, [error localizedDescription]);
//		[[HONAPICaller sharedInstance] showDataErrorHUD];
//	}];
//}

- (void)checkForAvailableUsername:(NSString *)username completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"username"	: username};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsersCheckUsername, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsersCheckUsername parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@ ) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsersCheckUsername, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)checkForAvailablePhone:(NSString *)phone completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"phone"	: phone};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsersCheckPhone, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsersCheckPhone parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@ ) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsersCheckPhone, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)deactivateUserWithCompletion:(void (^)(id result))completion {
	SelfieclubJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIPurgeUser);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIPurgeUser parameters:[NSDictionary dictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIPurgeUser, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)finalizeUserWithDictionary:(NSDictionary *)dict completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"		: [@"" stringFromInt:9],
							 @"userID"		: [dict objectForKey:@"user_id"],
							 @"username"	: [dict objectForKey:@"username"],
							 @"password"	: [dict objectForKey:@"phone"],
							 @"age"			: @"0000-00-00 00:00:00",
							 @"token"		: @"",
							 @"imgURL"		: [[HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront] stringByAppendingString:([[dict objectForKey:@"filename"] length] == 0) ? @"/defaultAvatar" : [@"/" stringByAppendingString:[dict objectForKey:@"filename"]]]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsersFirstRunComplete, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsersFirstRunComplete parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@\n%@", [[self class] description], [error localizedFailureReason], result);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@ ) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)flagUserByUserID:(int)userID completion:(void (^)(id result))completion {
	[[HONAPICaller sharedInstance] verifyUserWithUserID:userID asLegit:NO completion:completion];
}

- (void)recreateUserWithCompletion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"	: [@"" stringFromInt:1]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)registerNewUserWithCompletion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"	: [@"" stringFromInt:1]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveNewActivityForUserByUserID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: [@"" stringFromInt:userID], //131820
							 @"lastUpdated"	: [[NSUserDefaults standardUserDefaults] objectForKey:@"activity_updated"]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIGetActivity, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIGetActivity parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			SelfieclubJSONLog(@"AFNetworking [-] TOTAL ALERTS: %d", [result count]);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveChallengesForUserByUserID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: [@"" stringFromInt:userID],
							 @"action"		: [@"" stringFromInt:10],
							 @"isPrivate"	: @"N"};
	
	SelfieclubJSONLog(@"%@ _retrieveChallenges —/> (%@/%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [result firstObject]);
			SelfieclubJSONLog(@"AFNetworking [-] %@: FEED TOTAL %d", [[self class] description], [result count]);
			
			if (completion)
				completion(result);
		}
				
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveChallengesForUserByUsername:(NSString *)username completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"action"		: [@"" stringFromInt:9],
							 @"isPrivate"	: @"N",
							 @"username"	: username,
							 @"p"			: [@"" stringFromInt:1]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
//			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [result firstObject]);
			SelfieclubJSONLog(@"AFNetworking [-] %@: USER CHALLENGES:[%d]", [[self class] description], [result count]);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveClubsForUserByUserID:(int)userID completion:(void (^)(id result))completion {
#if SC_ACCT_BUILD == 0
	NSDictionary *params = @{@"userID"	: [@"" stringFromInt:userID]};
#else
	NSDictionary *params = @{@"userID"	: @"2394"};
#endif
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsersGetClubs, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsersGetClubs parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);

			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsersGetClubs, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveUserByUserID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"	: [@"" stringFromInt:5],
							 @"userID"	: [@"" stringFromInt:userID]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if ([error.description isEqualToString:kNetErrorNoConnection]) {
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = @"No network connection!";
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
		}
	}];
}

- (void)removeAllChallengesForUserWithCompletion:(void (^)(id result))completion {
	SelfieclubJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIPurgeContent);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIPurgeContent parameters:[NSDictionary dictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) Failed Request - %@", [[self class] description], [[operation request] URL], [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)removeUserFromVerifyListWithUserID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"		: [@"" stringFromInt:10],
							 @"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"targetID"	: [@"" stringFromInt:userID],
							 @"approves"	: [@"" stringFromInt:-1]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)submitPasscodeToLiftAccountSuspension:(NSString *)passcode completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"passcode"	: passcode};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPISuspendedAccount, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPISuspendedAccount parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)togglePushNotificationsForUserByUserID:(int)userID areEnabled:(BOOL)isEnabled completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"			: [@"" stringFromInt:4],
							 @"userID"			: [@"" stringFromInt:userID],
							 @"isNotifications"	: (isEnabled) ? @"Y" : @"N"};
	
	SelfieclubJSONLog(@"%@ —/> (%@/%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)updateAvatarWithImagePrefix:(NSString *)avatarPrefix completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"		: [@"" stringFromInt:9],
							 @"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"username"	: [[HONAppDelegate infoForUser] objectForKey:@"username"],
							 @"imgURL"		: [[NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront], avatarPrefix] stringByAppendingString:kSnapLargeSuffix]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)updateTabBarBadgeTotalsForUserByUserID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"	: [@"" stringFromInt:3],
							 @"userID"	: [@"" stringFromInt:userID]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)updateUsernameForUser:(NSString *)username completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"		: [@"" stringFromInt:7],
							 @"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"username"	: username};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)updatePhoneNumberForUserWithCompletion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"phone"	: [[HONDeviceIntrinsics sharedInstance] phoneNumber]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsersUpdatePhone, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsersUpdatePhone parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsersUpdatePhone, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)validatePhoneNumberForUser:(int)userID usingPINCode:(NSString *)pinCode completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"phone"	: [[HONDeviceIntrinsics sharedInstance] phoneNumber],
							 @"pin"		: pinCode};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsersValidatePIN, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsersValidatePIN parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsersValidatePIN, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)updateDeviceTokenWithCompletion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"token"	: ([[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"] != nil) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"] : @""};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsersSetDeviceToken, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsersSetDeviceToken parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsersSetDeviceToken, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)verifyUserWithUserID:(int)userID asLegit:(BOOL)isLegit completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"		: [@"" stringFromInt:10],
							 @"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"targetID"	: [@"" stringFromInt:userID],
							 @"approves"	: [@"" stringFromInt:(int)isLegit]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}


#pragma mark - Challenges
- (void)createShoutoutChallengeWithChallengeID:(int)challengeID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"challengeID"	: [@"" stringFromInt:challengeID],
							 @"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIVerifyShoutout, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIVerifyShoutout parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)createShoutoutChallengeWithUserID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"targetID"	: [@"" stringFromInt:userID]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIProfileShoutout, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIProfileShoutout parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)flagChallengeByChallengeID:(int)challengeID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"		: [@"" stringFromInt:11],
							 @"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"challengeID"	: [@"" stringFromInt:challengeID]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)markChallengeAsSeenWithChallengeID:(int)challengeID completion:(void (^)(id result))completion {
#if __DEV_BUILD__ == 0
	NSString *apiEndPt = @"http://api.selfieclubapp.com";
#else
	NSString *apiEndPt = @"http://api.devint.selfieclubapp.com";
#endif
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@)\n\n", [[self class] description], apiEndPt, [NSString stringWithFormat:@"statusupdate/%d/viewers/", challengeID]);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingBasePath:apiEndPt];
	[httpClient postPath:[NSString stringWithFormat:@"statusupdate/%d/viewers/", challengeID] parameters:@{@"member_id"	: [[HONAppDelegate infoForUser] objectForKey:@"id"]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], apiEndPt, [NSString stringWithFormat:@"statusupdate/%d/viewers/", challengeID], [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)removeChallengeForChallengeID:(int)challengeID withImagePrefix:(NSString *)imagePrefix completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"challengeID"	: [@"" stringFromInt:challengeID],
							 @"imgURL"		: imagePrefix};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIDeleteImage, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIDeleteImage parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveChallengeForChallengeID:(int)challengeID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"challengeID"	: [@"" stringFromInt:challengeID]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallengeObject, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIChallengeObject parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveChallengeForChallengeID:(int)challengeID igoringNextPushes:(BOOL)isIgnore completion:(void (^)(id result))completion {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[@"" stringFromInt:challengeID], @"challengeID", nil];
	
	if (isIgnore)
		[params setObject:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"cancelFor"];
	
	SelfieclubJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallengeObject);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIChallengeObject parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveSeenTotalForChallengeWithChallengeID:(int)challengeID completion:(void (^)(id result))completion {
#if __DEV_BUILD__ == 0
	NSString *apiEndPt = @"http://api.selfieclubapp.com";
#else
	NSString *apiEndPt = @"http://api.devint.selfieclubapp.com";
#endif
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@)\n\n", [[self class] description], apiEndPt, [NSString stringWithFormat:@"statusupdate/%d/viewers/", challengeID]);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingBasePath:apiEndPt];
	[httpClient getPath:[NSString stringWithFormat:@"statusupdate/%d/viewers/", challengeID] parameters:@{@"format"	: @"json"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], apiEndPt, [NSString stringWithFormat:@"statusupdate/%d/viewers/", challengeID], [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveVerifyListForUserID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"	: [@"" stringFromInt:userID]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIGetVerifyList, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIGetVerifyList parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSString stringWithFormat:@"TOTAL:[%d]", [result count]]);
//			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [result objectAtIndex:0]);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)submitChallengeWithDictionary:(NSDictionary *)dict completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: [dict objectForKey:@"user_id"],
							 @"imgURL"		: [dict objectForKey:@"img_url"],
							 @"challengeID"	: [dict objectForKey:@"challenge_id"],
							 @"clubID"		: [dict objectForKey:@"club_id"],
							 @"subject"		: [dict objectForKey:@"subject"],
							 @"subjects"	: [dict objectForKey:@"subjects"],
							 @"targets"		: [dict objectForKey:@"recipients"]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], [dict objectForKey:@"api_endpt"], params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:[dict objectForKey:@"api_endpt"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)upvoteChallengeWithChallengeID:(int)challengeID forOpponent:(HONClubPhotoVO *)opponentVO completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"			: [@"" stringFromInt:6],
							 @"userID"			: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"challengeID"		: [@"" stringFromInt:challengeID],
							 @"challengerID"	: [@"" stringFromInt:opponentVO.userID],
							 @"imgURL"			: opponentVO.imagePrefix};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}


#pragma mark - Messages
//- (void)markMessageAsSeenForMessageID:(int)messageID forParticipant:(int)userID completion:(void (^)(id result))completion {
//	NSDictionary *params = @{@"challengeID"	: [@"" stringFromInt:messageID],
//							 @"userID"		: [@"" stringFromInt:userID]};
//	
//	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallengesMessageSeen, params);
//	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
//	[httpClient postPath:kAPIChallengesMessageSeen parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		NSError *error = nil;
//		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//		
//		if (error != nil) {
//			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
//			[[HONAPICaller sharedInstance] showDataErrorHUD];
//			
//		} else {
//			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
//			if (completion)
//				completion(result);
//		}
//		
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
//		[[HONAPICaller sharedInstance] showDataErrorHUD];
//	}];
//}
//
//- (void)retrieveMessageForMessageID:(int)messageID completion:(void (^)(id result))completion {
//	[[HONAPICaller sharedInstance] retrieveChallengeForChallengeID:messageID completion:completion];
//}
//
//- (void)retrieveMessagesForUserByUserID:(int)userID completion:(void (^)(id result))completion {
//	NSDictionary *params = @{@"userID"		: [@"" stringFromInt:userID]};
//	
//	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallengesMessageSeen, params);
//	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
//	[httpClient postPath:kAPIGetMessages parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		NSError *error = nil;
//		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//		
//		if (error != nil) {
//			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
//			[[HONAPICaller sharedInstance] showDataErrorHUD];
//			
//		} else {
////			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
////			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [result firstObject]);
//			SelfieclubJSONLog(@"AFNetworking [-] %@: MESSAGES TOTAL %d", [[self class] description], [result count]);
//			
//			if (completion)
//				completion(result);
//		}
//		
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
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
//	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPICreateMessage, params);
//	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
//	[httpClient postPath:kAPICreateMessage parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		NSError *error = nil;
//		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//		
//		if (error != nil) {
//			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
//			[[HONAPICaller sharedInstance] showDataErrorHUD];
//			
//		} else {
//			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
//			
//			if (completion)
//				completion(result);
//		}
//		
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
//		[[HONAPICaller sharedInstance] showDataErrorHUD];
//	}];
//}


#pragma mark - Clubs
- (void)createClubWithTitle:(NSString *)title withDescription:(NSString *)blurb withImagePrefix:(NSString *)imagePrefix completion:(void (^)(id result))completion {
#if SC_ACCT_BUILD == 0
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"name"		: [title stringByReplacingOccurrencesOfString:@" " withString:@""],
							 @"description"	: blurb,
							 @"imgURL"		: imagePrefix};
#else
	NSDictionary *params = @{@"userID"		: @"2394",
							 @"name"		: title,
							 @"description"	: blurb,
							 @"imgURL"		: imagePrefix};
#endif
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIClubsCreate, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIClubsCreate parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIClubsCreate, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)deleteClubWithClubID:(int)clubID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"clubID"		: [@"" stringFromInt:clubID],
							 @"ownerID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIClubsDelete, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIClubsDelete parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIClubsDelete, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)editClubWithClubID:(int)clubID withTitle:(NSString *)title withDescription:(NSString *)blurb withImagePrefix:(NSString *)imagePrefix completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"clubID"		: [@"" stringFromInt:clubID],
							 @"ownerID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"name"		: title,
							 @"description"	: blurb,
							 @"imgURL"		: imagePrefix};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIClubsEdit, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIClubsEdit parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIClubsEdit, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)inviteInAppUsers:(NSArray *)inAppUsers toClubWithID:(int)clubID withClubOwnerID:(int)ownerID completion:(void (^)(id result))completion {
	[[HONAPICaller sharedInstance] inviteInAppUsers:inAppUsers toClubWithID:clubID withClubOwnerID:ownerID inviteNonAppContacts:[NSArray array] completion:completion];
}

- (void)inviteInAppUsers:(NSArray *)inAppUsers toClubWithID:(int)clubID withClubOwnerID:(int)ownerID inviteNonAppContacts:(NSArray*)nonAppContacts completion:(void (^)(id result))completion {
	
	NSString *userIDs = @"";
	for (HONTrivialUserVO *vo in inAppUsers)
		userIDs = [userIDs stringByAppendingFormat:@"%d,", vo.userID];
	
	NSString *contacts = @"";
	for (HONContactUserVO *vo in nonAppContacts)
		contacts = [contacts stringByAppendingFormat:@"%@:::%@:::%@|||", vo.fullName, vo.mobileNumber, vo.email];
	
	NSDictionary *params = @{@"clubID"		: [@"" stringFromInt:clubID],
							 @"userID"		: [@"" stringFromInt:ownerID],
							 @"users"		: ([inAppUsers count] > 0) ? [userIDs substringToIndex:[userIDs length] - 1] : @"",
							 @"nonUsers"	: ([nonAppContacts count] > 0) ? [contacts substringToIndex:[contacts length] - 3] : @""};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIClubsInvite, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIClubsInvite parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIClubsInvite, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)inviteNonAppUsers:(NSArray *)contacts toClubWithID:(int)clubID withClubOwnerID:(int)ownerID completion:(void (^)(id result))completion {
	[[HONAPICaller sharedInstance] inviteInAppUsers:[NSArray array] toClubWithID:clubID withClubOwnerID:ownerID inviteNonAppContacts:contacts completion:completion];
}

- (void)joinClub:(HONUserClubVO *)userClubVO withMemberID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"clubID"		: [@"" stringFromInt:userClubVO.clubID],
							 @"ownerID"		: [@"" stringFromInt:userClubVO.ownerID],
							 @"userID"		: [@"" stringFromInt:userID]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIClubsJoin, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIClubsJoin parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIClubsJoin, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)leaveClub:(HONUserClubVO *)userClubVO withMemberID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"clubID"		: [@"" stringFromInt:userClubVO.clubID],
							 @"ownerID"		: [@"" stringFromInt:userClubVO.ownerID],
							 @"memberID"	: [@"" stringFromInt:userID]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIClubsQuit, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIClubsQuit parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIClubsQuit, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveClubByClubID:(int)clubID withOwnerID:(int)ownerID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"clubID"		: [@"" stringFromInt:clubID],
							 @"userID"		: [@"" stringFromInt:ownerID]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIClubsGet, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIClubsGet parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIClubsGet, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveClubInvitesForUserWithUserID:(int)userID completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: [@"" stringFromInt:userID]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsersGetClubInvites, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsersGetClubInvites parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsersGetClubInvites, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveFeaturedClubsWithCompletion:(void (^)(id result))completion {
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@)\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIClubsFeatured);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIClubsFeatured parameters:[NSDictionary dictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIClubsFeatured, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveLocalSchoolTypeClubsWithAreaCode:(NSString *)areaCode completion:(void (^)(id result))completion {
//	if ([[HONClubAssistant sharedInstance] labelIDForAreaCode:areaCode] != 0) {
		
#if __DEV_BUILD__ == 0
		NSString *apiEndPt = @"http://api.selfieclubapp.com";
#else
		NSString *apiEndPt = @"http://api.devint.selfieclubapp.com";
#endif
	
		SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@)\n\n", [[self class] description], apiEndPt, [NSString stringWithFormat:@"club/labeled/areacode-%@-highschool/", areaCode]);
		AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMACUsingBasePath:apiEndPt];
		[httpClient getPath:[NSString stringWithFormat:@"club/labeled/areacode-%@-highschool/", areaCode] parameters:@{@"format"	: @"json"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSError *error = nil;
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			
			if (error != nil) {
				SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
				[[HONAPICaller sharedInstance] showDataErrorHUD];
				
			} else {
				SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
				
				if (completion)
					completion(result);
			}
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], apiEndPt, [NSString stringWithFormat:@"club/labeled/areacode-%@-highschool/", areaCode], [error localizedDescription]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
		}];
	
//	} else {
//		if (completion)
//			completion(@{@"clubs"	: @[]});
//	}
}

- (void)searchForClubsByClubName:(NSString *)name completion:(void (^)(id result))completion {
	[[HONAPICaller sharedInstance] retrieveLocalSchoolTypeClubsWithAreaCode:[[HONDeviceIntrinsics sharedInstance] areaCodeFromPhoneNumber] completion:completion];
}

- (void)submitClubPhotoWithDictionary:(NSDictionary *)dict completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: [dict objectForKey:@"user_id"],
							 @"imgURL"		: [dict objectForKey:@"img_url"],
							 @"challengeID"	: [dict objectForKey:@"challenge_id"],
							 @"clubID"		: [dict objectForKey:@"club_id"],
							 @"subject"		: [dict objectForKey:@"subject"],
							 @"subjects"	: [dict objectForKey:@"subjects"],
							 @"targets"		: [dict objectForKey:@"recipients"]};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], [dict objectForKey:@"api_endpt"], params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:[dict objectForKey:@"api_endpt"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}




#pragma mark - Invite / Social
- (void)searchUsersByPhoneNumber:(NSString *)phoneNumber completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"	: [@"" stringFromInt:13],
							 @"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"phone"	: phoneNumber};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			result = [NSMutableArray arrayWithArray:[[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]
													 sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)searchForUsersByUsername:(NSString *)username completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"		: [@"" stringFromInt:1],
							 @"username"	: username};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPISearch, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPISearch parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			result = [NSArray arrayWithArray:[[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]
											  sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPISearch, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)sendEmailInvitesWithDelimitedList:(NSString *)emailAddresses completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"addresses"	: emailAddresses};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIEmailInvites, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIEmailInvites parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIEmailInvites, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)sendSMSInvitesWithDelimitedList:(NSString *)phoneNumbers completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"numbers"		: phoneNumbers};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPISMSInvites, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPISMSInvites parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPISMSInvites, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)submitDelimitedEmailContacts:(NSString *)emailAddresses completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"emailList"	: emailAddresses};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIEmailContacts, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIEmailContacts parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			result = [NSMutableArray arrayWithArray:[[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]
													 sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIEmailContacts, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)submitDelimitedPhoneContacts:(NSString *)phoneNumbers completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"action"	: [@"" stringFromInt:11],
							 @"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"phone"	: phoneNumbers};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			//SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			result = [NSMutableArray arrayWithArray:[[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]
													 sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)submitEmailAddressForUserMatching:(NSString *)email completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"code"	: [[HONAppDelegate infoForUser] objectForKey:@"sms_code"],
							 @"email"	: email};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIEmailVerify, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIEmailVerify parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIEmailVerify, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)submitPhoneNumberForUserMatching:(NSString *)phoneNumber completion:(void (^)(id result))completion {
	NSDictionary *params = @{@"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"code"	: [[HONAppDelegate infoForUser] objectForKey:@"sms_code"],
							 @"phone"	: phoneNumber};
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIPhoneVerify, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIPhoneVerify parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			//SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIPhoneVerify, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}


#pragma mark - UI Presentation
- (void)showDataErrorHUD {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.mode = MBProgressHUDModeCustomView;
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
	_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
	[_progressHUD show:NO];
	[_progressHUD hide:YES afterDelay:kHUDErrorTime];
	_progressHUD = nil;
}

- (void)showSuccessHUD {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.mode = MBProgressHUDModeCustomView;
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_pass"]];
	[_progressHUD show:NO];
	[_progressHUD hide:YES afterDelay:kHUDErrorTime];
	_progressHUD = nil;
}


#pragma mark - AWS Delegates
- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
	NSArray *tag = [request.requestTag componentsSeparatedByString:@"|"];
	NSLog(@"\nAWS didCompleteWithResponse:\n[%@] - %@", tag, request.url);
	
	HONS3BucketType bucketType = (HONS3BucketType)[[tag objectAtIndex:2] intValue];
	
	if ([[tag objectAtIndex:1] isEqualToString:kSnapLargeSuffix]) {
		switch ((HONS3BucketType)[[tag objectAtIndex:2] intValue]) {
			case HONS3BucketTypeAvatars:
				[[HONImageBroker sharedInstance] writeImageFromWeb:[NSString stringWithFormat:@"%@", request.url] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
				break;
				
			case HONS3BucketTypeClubs:
				break;
				
			case HONS3BucketTypeSelfies:
				break;
				
			default:
				break;
		}
		
		if (bucketType == HONS3BucketTypeAvatars)
			[[HONImageBroker sharedInstance] writeImageFromWeb:[NSString stringWithFormat:@"%@", request.url] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
		
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[NSString stringWithFormat:@"%@", request.url] forBucketType:bucketType completion:nil];
		
		
//		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[NSString stringWithFormat:@"%@", request.url] forBucketType:([[tag objectAtIndex:0] isEqualToString:@"hotornot-avatars"]) ? HONS3BucketTypeAvatars : HONS3BucketTypeSelfies completion:nil];
//		if ([[tag objectAtIndex:0] isEqualToString:@"hotornot-avatars"])
//			[[HONImageBroker sharedInstance] writeImageFromWeb:[NSString stringWithFormat:@"%@", request.url] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
		
		/*
		NSDictionary *params = @{@"imgURL"	: [HONAppDelegate cleanImagePrefixURL:[NSString stringWithFormat:@"%@", request.url]]};
		SelfieclubJSONLog(@"%@ —/> (%@/%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIProcessUserImage, params);
		AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
		[httpClient postPath:kAPIProcessUserImage parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSError *error = nil;
			if (error != nil)
				SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			else
				SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIProcessUserImage, [error localizedDescription]);
		}];
		*/
	}
	
	_awsUploadCounter++;
	if (_awsUploadCounter == 2) {
		if ([[tag objectAtIndex:0] isEqualToString:@"hotornot-avatars"]) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_PROFILE" object:nil];
		}
		
		_awsUploadCounter = 0;
	}
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"AWS didFailWithError:\n%@", [error description]);
	NSArray *tag = [request.requestTag componentsSeparatedByString:@"|"];
	
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.mode = MBProgressHUDModeCustomView;
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
	_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
	[_progressHUD show:NO];
	[_progressHUD hide:YES afterDelay:kHUDErrorTime];
	_progressHUD = nil;
	
	if ([[tag firstObject] isEqualToString:@"hotornot-avatars"]) {
		[[HONImageBroker sharedInstance] writeImageFromWeb:[NSString stringWithFormat:@"%@/defaultAvatar%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront], kSnapLargeSuffix] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_PROFILE" object:nil];
	}
}


@end
