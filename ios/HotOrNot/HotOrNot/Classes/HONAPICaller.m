//
//  HONAPICaller.m
//  HotOrNot
//
//  Created by Matt Holcombe on 12/10/2013 @ 12:40.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import <CommonCrypto/CommonHMAC.h>

#import "MBProgressHUD.h"

#import "HONAPICaller.h"
#import "HONImagingDepictor.h"



//] api endpts [>
//]=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=[>
NSString * const kAPIChallenges = @"Challenges.php";
NSString * const kAPIComments = @"Comments.php";
NSString * const kAPISearch = @"Search.php";
NSString * const kAPIUsers = @"Users.php";
NSString * const kAPIVotes = @"Votes.php";

NSString * const kAPICreateChallenge = @"challenges/create";
NSString * const kAPICreateMessage = @"challenges/createprivate";
NSString * const kAPIDeleteImage = @"challenges/deleteimage";
NSString * const kAPIChallengeObject = @"challenges/get";
NSString * const kAPIGetMessages = @"challenges/getprivate";
NSString * const kAPIGetPublicChallenges = @"challenges/getpublic";
NSString * const kAPIGetVerifyList = @"challenges/getVerifyList";
NSString * const kAPIJoinChallenge = @"challenges/join";
NSString * const kAPIChallengesMessageSeen = @"challenges/messageseen";
NSString * const kAPIProcessChallengeImage = @"challenges/processimage";
NSString * const kAPIProfileShoutout = @"challenges/selfieshoutout";
NSString * const kAPIVerifyShoutout = @"challenges/shoutout";

NSString * const kAPIEmailInvites = @"g/emailinvites";
NSString * const kAPISMSInvites = @"g/smsinvites";

NSString * const kAPIGetFriends = @"social/getfriends";
NSString * const kAPIAddFriend = @"social/addfriend";
NSString * const kAPIRemoveFriend = @"social/removefriend";

NSString * const kAPICheckNameAndEmail = @"users/checkNameAndEmail";
NSString * const kAPIGetActivity = @"users/getactivity";
NSString * const kAPIGetSubscribees = @"users/getsubscribees";
NSString * const kAPIEmailContacts = @"users/ffemail";
NSString * const kAPIUsersFirstRunComplete = @"users/firstruncomplete";
NSString * const kAPITumblrInvite = @"users/invitetumblr";
NSString * const kAPIProcessUserImage = @"users/processimage";
NSString * const kAPIPurgeUser = @"users/purge";
NSString * const kAPIPurgeContent = @"users/purgecontent";
NSString * const kAPISetUserAgeGroup = @"users/setage";
NSString * const kAPISuspendedAccount = @"users/suspendedaccount";
NSString * const kAPIEmailVerify = @"users/verifyemail";
NSString * const kAPIPhoneVerify = @"users/verifyphone";
//]=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=[


// hMAC key
NSString * const kHMACKey = @"YARJSuo6/r47LczzWjUx/T8ioAJpUKdI/ZshlTUP8q4ujEVjC0seEUAAtS6YEE1Veghz+IDbNQ";


//void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error);
//void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
//	VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[[HONAPICaller sharedInstance] class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
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
- (AFHTTPClient *)getHttpClientWithHMAC {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient setDefaultHeader:@"HMAC" value:[[HONAPICaller sharedInstance] hmacToken] ];
	[httpClient setDefaultHeader:@"X-DEVICE" value:[HONAppDelegate deviceModel]];
	
	return (httpClient);
}

- (NSString *)hmacForKey:(NSString *)key withData:(NSString *)data{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSMutableString *result = [NSMutableString string];
    for (int i=0; i<sizeof cHMAC; i++)
        [result appendFormat:@"%02hhx", cHMAC[i]];
		
    return ([result copy]);
}

- (NSString *)hmacToken {
    NSMutableString *token = [@"unknown" mutableCopy];
    NSMutableString *data = [[HONAppDelegate deviceToken] mutableCopy];
	
	if( data != nil ){
	    [data appendString:@"+"];
	    [data appendString:[HONAppDelegate advertisingIdentifierWithoutSeperators:NO]];
	    
		token = [[[HONAPICaller sharedInstance] hmacForKey:kHMACKey withData:data] mutableCopy];
	    [token appendString:@"+"];
	    [token appendString:data];
    }
	
    return ([token copy]);
}


#pragma mark - Images
- (void)notifyToCreateImageSizesForURL:(NSString *)imageURL forAvatarBucket:(BOOL)isAvatarBucket completion:(void (^)(NSObject *result))completion {
	[[HONAPICaller sharedInstance] notifyToCreateImageSizesForURL:imageURL forAvatarBucket:isAvatarBucket preDelay:(2/3) completion:completion];
}

- (void)notifyToCreateImageSizesForURL:(NSString *)imageURL forAvatarBucket:(BOOL)isAvatarBucket preDelay:(int64_t)delay completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"imgURL"	: [HONAppDelegate cleanImagePrefixURL:imageURL]};
	
	dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
	dispatch_after(dispatchTime, dispatch_get_main_queue(), ^(void){
		VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], (isAvatarBucket) ? kAPIProcessUserImage : kAPIProcessChallengeImage, params);
		AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
		[httpClient postPath:(isAvatarBucket) ? kAPIProcessUserImage : kAPIProcessChallengeImage parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSError *error = nil;
			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			
			if (error != nil) {
				VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
				[[HONAPICaller sharedInstance] showDataErrorHUD];
				
			} else {
				VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
				
				if (completion)
					completion(result);
			}
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
		}];
	});
}

- (void)uploadPhotosToS3:(NSArray *)imageData intoBucket:(NSString *)bucket withFilename:(NSString *)filename completion:(void (^)(NSObject *result))completion {
	S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[filename stringByAppendingString:kSnapLargeSuffix] inBucket:bucket];
	por1.data = [imageData objectAtIndex:0];
	por1.requestTag = [NSString stringWithFormat:@"%@|%@", por1.bucket, kSnapLargeSuffix];
	por1.contentType = @"image/jpeg";
	por1.delegate = self;
	
	S3PutObjectRequest *por2 = [[S3PutObjectRequest alloc] initWithKey:[filename stringByAppendingString:kSnapTabSuffix] inBucket:bucket];
	por2.data = [imageData objectAtIndex:1];
	por2.requestTag = [NSString stringWithFormat:@"%@|%@", por2.bucket, kSnapTabSuffix];
	por2.contentType = @"image/jpeg";
	por2.delegate = self;
	
	_awsUploadCounter = 0;
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	
	@try {
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:bucket]];
		[s3 putObject:por1];
		[s3 putObject:por2];
		
	} @catch (AmazonClientException *exception) {
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
		
		if ([bucket rangeOfString:@"hotornot-challenges"].location != NSNotFound)
			[HONImagingDepictor writeImageFromWeb:[NSString stringWithFormat:@"%@/defaultAvatar%@", [HONAppDelegate s3BucketForType:@"avatars"], kSnapLargeSuffix] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
	}
	
	if (completion)
		completion(nil);
}

#pragma mark - Users
- (void)checkForAvailableUsername:(NSString *)username andEmail:(NSString *)email completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"username"	: username,
							 @"password"	: email};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPICheckNameAndEmail, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPICheckNameAndEmail parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@ ) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)deactivateUserWithCompletion:(void (^)(NSObject *result))completion {
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIPurgeUser);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIPurgeUser parameters:[NSDictionary dictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)finalizeUserWithDictionary:(NSDictionary *)dict completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"action"		: [NSString stringWithFormat:@"%d", 9],
							 @"userID"		: [dict objectForKey:@"user_id"],
							 @"username"	: [dict objectForKey:@"username"],
							 @"password"	: [dict objectForKey:@"email"],
							 @"age"			: [dict objectForKey:@"birthday"],
							 @"token"		: [HONAppDelegate deviceToken],
							 @"imgURL"		: ([[dict objectForKey:@"filename"] length] == 0) ? [[NSString stringWithFormat:@"%@/defaultAvatar", [HONAppDelegate s3BucketForType:@"avatars"]] stringByAppendingString:kSnapLargeSuffix] : [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:@"avatars"], [[dict objectForKey:@"filename"] stringByAppendingString:kSnapLargeSuffix]]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsersFirstRunComplete, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsersFirstRunComplete parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@ ) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)flagUserByUserID:(int)userID completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"action"		: [NSString stringWithFormat:@"%d", 10],
							 @"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"targetID"	: [NSString stringWithFormat:@"%d", userID],
							 @"approves"	: [NSString stringWithFormat:@"%d", 0]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)recreateUserWithCompletion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"action"	: [NSString stringWithFormat:@"%d", 1]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)registerNewUserWithCompletion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"action"	: [NSString stringWithFormat:@"%d", 1]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveAlertsForUserByUserID:(int)userID completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIGetActivity parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			VolleyJSONLog(@"AFNetworking [-] TOTAL ALERTS: %d", [result count]);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveChallengesForUserByUserID:(int)userID completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"userID"		: [NSString stringWithFormat:@"%d", userID],
							 @"action"		: [NSString stringWithFormat:@"%d", 10],
							 @"isPrivate"	: @"N"};
	
	VolleyJSONLog(@"%@ _retrieveChallenges —/> (%@/%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
//			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [result firstObject]);
			VolleyJSONLog(@"AFNetworking [-] %@: FEED TOTAL %d", [[self class] description], [result count]);
			
			if (completion)
				completion(result);
		}
				
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveChallengesForUserByUsername:(NSString *)username completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"action"		: [NSString stringWithFormat:@"%d", 9],
							 @"isPrivate"	: @"N",
							 @"username"	: username,
							 @"p"			: [NSString stringWithFormat:@"%d", 1]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
//			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [result firstObject]);
			VolleyJSONLog(@"AFNetworking [-] %@: USER CHALLENGES:[%d]", [[self class] description], [result count]);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveFollowingUsersForUserByUserID:(int)userID completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"userID"	: [NSString stringWithFormat:@"%d", userID]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIGetSubscribees, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIGetSubscribees parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %d", [[self class] description], [[operation request] URL], [result count]);
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveUserByUserID:(int)userID completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"action"	: [NSString stringWithFormat:@"%d", 5],
							 @"userID"	: [NSString stringWithFormat:@"%d", userID]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if ([error.description isEqualToString:kNetErrorNoConnection]) {
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = @"No network connection!";
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
		}
	}];
}

- (void)removeAllChallengesForUserWithCompletion:(void (^)(NSObject *result))completion {
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIPurgeContent);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIPurgeContent parameters:[NSDictionary dictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@) Failed Request - %@", [[self class] description], [[operation request] URL], [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)removeUserFromVerifyListWithUserID:(int)userID completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"action"		: [NSString stringWithFormat:@"%d", 10],
							 @"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"targetID"	: [NSString stringWithFormat:@"%d", userID],
							 @"approves"	: [NSString stringWithFormat:@"%d", -1]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)submitPasscodeToLiftAccountSuspension:(NSString *)passcode completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"passcode"	: passcode};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPISuspendedAccount, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPISuspendedAccount parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)togglePushNotificationsForUserByUserID:(int)userID areEnabled:(BOOL)isEnabled completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"action"			: [NSString stringWithFormat:@"%d", 4],
							 @"userID"			: [NSString stringWithFormat:@"%d", userID],
							 @"isNotifications"	: (isEnabled) ? @"Y" : @"N"};
	
	VolleyJSONLog(@"%@ —/> (%@/%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)updateAvatarWithImagePrefix:(NSString *)avatarPrefix completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"action"		: [NSString stringWithFormat:@"%d", 9],
							 @"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"username"	: [[HONAppDelegate infoForUser] objectForKey:@"username"],
							 @"imgURL"		: [[NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:@"avatars"], avatarPrefix] stringByAppendingString:kSnapLargeSuffix]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)updateTabBarBadgeTotalsForUserByUserID:(int)userID completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"action"	: [NSString stringWithFormat:@"%d", 3],
							 @"userID"	: [NSString stringWithFormat:@"%d", userID]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)updateUsernameForUser:(NSString *)username completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"action"		: [NSString stringWithFormat:@"%d", 7],
							 @"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"username"	: username};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)verifyUserWithUserID:(int)userID asLegit:(BOOL)isLegit completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"action"		: [NSString stringWithFormat:@"%d", 10],
							 @"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"targetID"	: [NSString stringWithFormat:@"%d", userID],
							 @"approves"	: [NSString stringWithFormat:@"%d", (int)isLegit]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}


#pragma mark - Challenges
- (void)createShoutoutChallengeWithChallengeID:(int)challengeID completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"challengeID"	: [NSString stringWithFormat:@"%d", challengeID],
							 @"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIVerifyShoutout, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIVerifyShoutout parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)createShoutoutChallengeWithUserID:(int)userID completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"targetID"	: [NSString stringWithFormat:@"%d", userID]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIProfileShoutout, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIProfileShoutout parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)flagChallengeByChallengeID:(int)challengeID completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"action"		: [NSString stringWithFormat:@"%d", 11],
							 @"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"challengeID"	: [NSString stringWithFormat:@"%d", challengeID]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)markChallengeAsSeenWithChallengeID:(int)challengeID completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"action"		: [NSString stringWithFormat:@"%d", 6],
							 @"challengeID"	: [NSString stringWithFormat:@"%d",challengeID],
							 @"hasSeen"		: @"Y"};
	
	VolleyJSONLog(@"%@ —/> (%@/%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)markChallengeAsUnseenWithChallengeID:(int)challengeID completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"action"		: [NSString stringWithFormat:@"%d", 6],
							 @"challengeID"	: [NSString stringWithFormat:@"%d",challengeID],
							 @"hasSeen"		: @"N"};
	
	VolleyJSONLog(@"%@ —/> (%@/%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)removeChallengeForChallengeID:(int)challengeID withImagePrefix:(NSString *)imagePrefix completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"challengeID"	: [NSString stringWithFormat:@"%d", challengeID],
							 @"imgURL"		: imagePrefix};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIDeleteImage, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIDeleteImage parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveChallengeForChallengeID:(int)challengeID completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"challengeID"	: [NSString stringWithFormat:@"%d", challengeID]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallengeObject, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIChallengeObject parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveChallengeForChallengeID:(int)challengeID igoringNextPushes:(BOOL)isIgnore completion:(void (^)(NSObject *result))completion {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", challengeID], @"challengeID", nil];
	
	if (isIgnore)
		[params setObject:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"cancelFor"];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallengeObject);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIChallengeObject parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)retrieveVerifyListForUserID:(int)userID completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"userID"	: [NSString stringWithFormat:@"%d", userID]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIGetVerifyList, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIGetVerifyList parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSString stringWithFormat:@"TOTAL:[%d]", [result count]]);
//			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
//			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [result objectAtIndex:0]);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)submitChallengeWithDictionary:(NSDictionary *)dict completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"userID"		: [dict objectForKey:@"user_id"],
							 @"imgURL"		: [dict objectForKey:@"img_url"],
							 @"challengeID"	: [dict objectForKey:@"challenge_id"],
							 @"subject"		: [dict objectForKey:@"subject"]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], [dict objectForKey:@"api_endpt"], params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:[dict objectForKey:@"api_endpt"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)upvoteChallengeWithChallengeID:(int)challengeID forOpponent:(HONOpponentVO *)opponentVO completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"action"			: [NSString stringWithFormat:@"%d", 6],
							 @"userID"			: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"challengeID"		: [NSString stringWithFormat:@"%d", challengeID],
							 @"challengerID"	: [NSString stringWithFormat:@"%d", opponentVO.userID],
							 @"imgURL"			: opponentVO.imagePrefix};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}


#pragma mark - Messages
- (void)retrieveMessageForMessageID:(int)messageID completion:(void (^)(NSObject *result))completion {
	[[HONAPICaller sharedInstance] retrieveChallengeForChallengeID:messageID completion:completion];
}

- (void)retrieveMessagesForUserByUserID:(int)userID completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"userID"		: [NSString stringWithFormat:@"%d", userID]};
	
	VolleyJSONLog(@"%@ _retrieveChallenges —/> (%@/%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIGetMessages, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIGetMessages parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
//			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [result firstObject]);
			VolleyJSONLog(@"AFNetworking [-] %@: MESSAGES TOTAL %d", [[self class] description], [result count]);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)submitNewMessageWithDictionary:(NSDictionary *)dict completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"userID"		: [dict objectForKey:@"user_id"],
							 @"imgURL"		: [dict objectForKey:@"img_url"],
							 @"subject"		: [dict objectForKey:@"subject"],
							 @"targets"		: [dict objectForKey:@"recipients"],
							 @"isPrivate"	: @"Y"};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPICreateMessage, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPICreateMessage parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)updateMessageAsSeenForMessageID:(int)messageID completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"challengeID"	: [NSString stringWithFormat:@"%d", messageID]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallengesMessageSeen, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIChallengesMessageSeen parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

#pragma mark - Invite / Social
- (void)followUserWithUserID:(int)userID completion:(void (^)(NSObject *result))completion {
	[[HONAPICaller sharedInstance] followUserWithUserID:userID isReciprocal:NO completion:completion];
}


- (void)followUserWithUserID:(int)userID isReciprocal:(BOOL)isMutualFollow completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"target"	: [NSString stringWithFormat:@"%d", userID],
							 @"auto"	: [NSString stringWithFormat:@"%d", isMutualFollow]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIAddFriend, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIAddFriend parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
			
//			void (^completionBlock)(NSObject *result) = ^void(NSObject *result) {
//				[HONAppDelegate writeFollowingList:(NSArray *)result];
//			};
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)followUsersByUserIDWithDelimitedList:(NSString *)userIDs completion:(void (^)(NSObject *result))completion {
	[[HONAPICaller sharedInstance] followUsersByUserIDWithDelimitedList:userIDs isReciprocal:NO completion:completion];
}

- (void)followUsersByUserIDWithDelimitedList:(NSString *)userIDs isReciprocal:(BOOL)isMutualFollow completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"target"	: [userIDs substringToIndex:[userIDs length] - 1],
							 @"auto"	: [NSString stringWithFormat:@"%d", isMutualFollow]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIAddFriend, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIAddFriend parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)searchForUsersByUsername:(NSString *)username completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"action"		: [NSString stringWithFormat:@"%d", 1],
							 @"username"	: username};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPISearch, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPISearch parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			result = [NSArray arrayWithArray:[[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]
											  sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPISearch, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)sendDelimitedEmailContacts:(NSString *)emailAddresses completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"emailList"	: emailAddresses};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIEmailContacts, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIEmailContacts parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			result = [NSMutableArray arrayWithArray:[[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]
													 sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)sendDelimitedPhoneContacts:(NSString *)phoneNumbers completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"action"	: [NSString stringWithFormat:@"%d", 11],
							 @"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"phone"	: phoneNumbers};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			result = [NSMutableArray arrayWithArray:[[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]
													 sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)sendEmailInvitesFromDelimitedList:(NSString *)emailAddresses completion:(void (^)(NSObject *))completion {
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"addresses"	: emailAddresses};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIEmailInvites, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIEmailInvites parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)sendSMSInvitesFromDelimitedList:(NSString *)phoneNumbers completion:(void (^)(NSObject *))completion {
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"numbers"		: phoneNumbers};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPISMSInvites, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPISMSInvites parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)stopFollowingUserWithUserID:(int)userID completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"target"	: [NSString stringWithFormat:@"%d", userID]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIRemoveFriend, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIRemoveFriend parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %d", [[self class] description], [[operation request] URL], [result count]);
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
			
//			void (^completionBlock)(NSObject *result) = ^void(NSObject *result) {
//				[HONAppDelegate writeFollowingList:(NSArray *)result];
//			};
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)submitEmailAddressForContactsMatching:(NSString *)email completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"code"	: [[HONAppDelegate infoForUser] objectForKey:@"sms_code"],
							 @"email"	: email};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIEmailVerify, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIEmailVerify parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)submitPhoneNumberForContactsMatching:(NSString *)phoneNumber completion:(void (^)(NSObject *result))completion {
	NSDictionary *params = @{@"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"code"	: [[HONAppDelegate infoForUser] objectForKey:@"sms_code"],
							 @"phone"	: phoneNumber};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIPhoneVerify, params);
	AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
	[httpClient postPath:kAPIPhoneVerify parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (completion)
				completion(result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}


#pragma mark - UI Presentation
- (void)showDataErrorHUD {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.mode = MBProgressHUDModeCustomView;
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
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
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkIcon"]];
	[_progressHUD show:NO];
	[_progressHUD hide:YES afterDelay:kHUDErrorTime];
	_progressHUD = nil;
}


#pragma mark - AWS Delegates
- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
	NSArray *tag = [request.requestTag componentsSeparatedByString:@"|"];
	NSLog(@"\nAWS didCompleteWithResponse:\n[%@] - %@", tag, request.url);
	
	if ([[tag objectAtIndex:1] isEqualToString:kSnapLargeSuffix]) {
		if ([[tag objectAtIndex:0] isEqualToString:@"hotornot-avatars"])
			[HONImagingDepictor writeImageFromWeb:[NSString stringWithFormat:@"%@", request.url] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
		
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForURL:[NSString stringWithFormat:@"%@", request.url] forAvatarBucket:([[tag objectAtIndex:0] isEqualToString:@"hotornot-avatars"]) completion:nil];
		
		/*
		NSDictionary *params = @{@"imgURL"	: [HONAppDelegate cleanImagePrefixURL:[NSString stringWithFormat:@"%@", request.url]]};
		VolleyJSONLog(@"%@ —/> (%@/%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIProcessUserImage, params);
		AFHTTPClient *httpClient = [[HONAPICaller sharedInstance] getHttpClientWithHMAC];
		[httpClient postPath:kAPIProcessUserImage parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSError *error = nil;
			if (error != nil)
				VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			else
				VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
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
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
	_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
	[_progressHUD show:NO];
	[_progressHUD hide:YES afterDelay:kHUDErrorTime];
	_progressHUD = nil;
	
	if ([[tag firstObject] isEqualToString:@"hotornot-avatars"]) {
		[HONImagingDepictor writeImageFromWeb:[NSString stringWithFormat:@"%@/defaultAvatar%@", [HONAppDelegate s3BucketForType:@"avatars"], kSnapLargeSuffix] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_PROFILE" object:nil];
	}
}


@end
