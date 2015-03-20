//
//  HONAPICaller.h
//  HotOrNot
//
//  Created by Matt Holcombe on 12/10/2013 @ 12:40.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "AFNetworking.h"

#import "HONContactUserVO.h"
#import "HONOpponentVO.h"
#import "HONUserVO.h"
#import "HONUserClubVO.h"
#import "HONClubPhotoVO.h"


typedef NS_ENUM(NSUInteger, HONAmazonS3BucketType) {
	HONAmazonS3BucketTypeAvatarsSource = 0,
	HONAmazonS3BucketTypeAvatarsCloudFront,
	
	HONAmazonS3BucketTypeBannersSource,
	HONAmazonS3BucketTypeBannersCloudFront,
	
	HONAmazonS3BucketTypeClubsSource,
	HONAmazonS3BucketTypeClubsCloudFront,
	
	HONAmazonS3BucketTypeEmotionsSource,
	HONAmazonS3BucketTypeEmoticonsCloudFront
};

//typedef NS_ENUM(NSUInteger, HONS3BucketType) {
//	HONS3BucketTypeAvatars = 0,
//	HONS3BucketTypeSelfies,
//	HONS3BucketTypeClubs
//};


// network error descriptions
extern NSString * const kNetErrorNoConnection;
extern NSString * const kNetErrorStatusCode404;


// MIME Types
extern NSString * const kMIMETypeApplicationJSON;
extern NSString * const kMIMETypeApplicationOctetStream;
extern NSString * const kMIMETypeApplicationXFormURLEncoded;
extern NSString * const kMIMETypeApplicationXML;
extern NSString * const kMIMETypeApplicationXPlist;
extern NSString * const kMIMETypeImage;
extern NSString * const kMIMETypeImageGIF;
extern NSString * const kMIMETypeImageJPEG;
extern NSString * const kMIMETypeImagePNG;
extern NSString * const kMIMETypeMultipartFormData;
extern NSString * const kMIMETypeTextJavascript;
extern NSString * const kMIMETypeTextJSON;
extern NSString * const kMIMETypeTextPlain;
extern NSString * const kMIMETypeTextXML;



// network times
extern const CGFloat kNotifiyDelay;


// network rules
extern const NSURLRequestCachePolicy kOrthodoxURLCachePolicy;


@interface HONAPICaller : NSObject
+ (HONAPICaller *)sharedInstance;


/**
 * Utility
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
+ (NSDictionary *)s3Credentials;
+ (NSString *)s3BucketForType:(HONAmazonS3BucketType)s3BucketType;

+ (NSTimeInterval)timeoutInterval;

- (NSString *)phpAPIBasePath;
- (NSString *)pythonAPIBasePath;

- (AFHTTPClient *)appendHeaders:(NSDictionary *)headers toHTTPCLient:(AFHTTPClient *)httpClient;
- (AFHTTPClient *)getHttpClientWithHMACUsingPHPBasePath;
- (AFHTTPClient *)getHttpClientWithHMACUsingPythonBasePath;

- (NSMutableString *)hmacForKey:(NSString *)key withData:(NSString *)data;
- (NSString *)normalizePrefixForImageURL:(NSString *)imageURL;

- (BOOL)canPingAPIServer;
- (BOOL)canPingConfigServer;
- (void)retrieveLocationFromIPAddressWithCompletion:(void (^)(id result))completion;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯

/**
 * Config
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
- (void)retreiveBootConfigWithCompletion:(void (^)(id result))completion;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯

/**
 * Images
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
//- (void)notifyToCreateImageSizesForPrefix:(NSString *)prefixURL forBucketType:(HONS3BucketType)bucketType completion:(void (^)(id result))completion;
//- (void)notifyToCreateImageSizesForPrefix:(NSString *)prefixURL forBucketType:(HONS3BucketType)bucketType preDelay:(int64_t)delay completion:(void (^)(id result))completion;
//- (void)uploadPhotosToS3:(NSArray *)imageData intoBucketType:(HONS3BucketType)bucketType withFilename:(NSString *)filename completion:(void (^)(id result))completion;

//- (void)notifyToCreateImageSizesForURL:(NSString *)imageURL forAvatarBucket:(BOOL)isAvatarBucket completion:(void (^)(id result))completion;
//- (void)notifyToCreateImageSizesForURL:(NSString *)imageURL forAvatarBucket:(BOOL)isAvatarBucket preDelay:(int64_t)delay completion:(void (^)(id result))completion;
- (void)uploadPhotoToS3:(NSData *)imageData intoBucketType:(HONAmazonS3BucketType)bucketType withFilename:(NSString *)filename completion:(void (^)(BOOL success, NSError * error))completion;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯

/**
 * Users
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
//- (void)checkForAvailableUsername:(NSString *)username andPhone:(NSString *)phone completion:(void (^)(id result))completion;
- (void)checkForAvailableUsername:(NSString *)username completion:(void (^)(id result))completion;
- (void)checkForAvailablePhone:(NSString *)phone completion:(void (^)(id result))completion;
- (void)deactivateUserWithCompletion:(void (^)(id result))completion;
- (void)finalizeUserWithDictionary:(NSDictionary *)dict completion:(void (^)(id result))completion;
- (void)flagUserByUserID:(int)userID completion:(void (^)(id result))completion;
- (void)recreateUserWithCompletion:(void (^)(id result))completion;
- (void)retrieveActivityForUserByUserID:(int)userID fromPage:(int)page completion:(void (^)(id result))completion;
- (void)retrieveActivityTotalForUserByUserID:(int)userID completion:(void (^)(id result))completion;
- (void)registerNewUserWithCompletion:(void (^)(id result))completion;
- (void)retrieveNewActivityForUserByUserID:(int)userID completion:(void (^)(id result))completion;
- (void)retrieveChallengesForUserByUserID:(int)userID completion:(void (^)(id result))completion;
- (void)retrieveChallengesForUserByUsername:(NSString *)username completion:(void (^)(id result))completion;
- (void)retrieveClubsForUserByUserID:(int)userID completion:(void (^)(id result))completion;
- (void)retrieveStatusUpdatesForUserByUserID:(int)userID fromPage:(int)page completion:(void (^)(id result))completion;
- (void)retrieveTopClubsForUserWithUserID:(int)userID completion:(void (^)(id result))completion;
- (void)retrieveRecentClubsForUserByUserID:(int)userID afterDate:(NSDate *)date completion:(void (^)(id result))completion;
- (void)retrieveUserByUserID:(int)userID completion:(void (^)(id result))completion;
- (void)removeAllChallengesForUserWithCompletion:(void (^)(id result))completion;
- (void)removeUserFromVerifyListWithUserID:(int)userID completion:(void (^)(id result))completion;
- (void)submitPasscodeToLiftAccountSuspension:(NSString *)passcode completion:(void (^)(id result))completion;
- (void)togglePushNotificationsForUserByUserID:(int)userID areEnabled:(BOOL)isEnabled completion:(void (^)(id result))completion;
- (void)updateAvatarWithImagePrefix:(NSString *)avatarPrefix completion:(void (^)(id result))completion;
- (void)updateTabBarBadgeTotalsForUserByUserID:(int)userID completion:(void (^)(id result))completion;
- (void)updateUsernameForUser:(NSString *)username completion:(void (^)(id result))completion;
- (void)updateDeviceTokenWithCompletion:(void (^)(id result))completion;
- (void)updatePhoneNumberForUserWithCompletion:(void (^)(id result))completion;
- (void)validatePhoneNumberForUser:(int)userID usingPINCode:(NSString *)pinCode completion:(void (^)(id result))completion;
- (void)verifyUserWithUserID:(int)userID asLegit:(BOOL)isLegit completion:(void (^)(id result))completion;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯

/**
 * Challenges
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
- (void)createShoutoutChallengeWithChallengeID:(int)challengeID completion:(void (^)(id result))completion;
- (void)createShoutoutChallengeWithUserID:(int)userID completion:(void (^)(id result))completion;
- (void)flagStatusUpdateByStatusUpdateID:(int)statusUpdateID completion:(void (^)(id result))completion;
- (void)markChallengeAsSeenWithChallengeID:(int)challengeID completion:(void (^)(id result))completion;
- (void)removeChallengeForChallengeID:(int)challengeID withImagePrefix:(NSString *)imagePrefix completion:(void (^)(id result))completion;
- (void)retrieveChallengeForChallengeID:(int)challengeID completion:(void (^)(id result))completion;
- (void)retrieveChallengeForChallengeID:(int)challengeID igoringNextPushes:(BOOL)isIgnore completion:(void (^)(id result))completion;
- (void)retrieveSeenTotalForChallengeWithChallengeID:(int)challengeID completion:(void (^)(id result))completion;
- (void)retrieveSeenMembersChallengeWithChallengeID:(int)challengeID completion:(void (^)(id result))completion;
- (void)retrieveVerifyListForUserID:(int)userI completion:(void (^)(id result))completion;
- (void)retrieveVoteTotalForStatusUpdateByStatusUpdateID:(int)statusUpdateID completion:(void (^)(id result))completion;
- (void)upvoteChallengeWithChallengeID:(int)challengeID forOpponent:(HONClubPhotoVO *)opponentVO completion:(void (^)(id result))completion;
- (void)voteClubPhotoWithChallengeID:(int)challengeID isUpVote:(BOOL)isUpVote completion:(void (^)(id result))completion;
- (void)voteStatusUpdateWithStatusUpdateID:(int)statusUpdateID isUpVote:(BOOL)isUpVote completion:(void (^)(id result))completion;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯

/**
 * Messages
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
//- (void)markMessageAsSeenForMessageID:(int)messageID forParticipant:(int)userID completion:(void (^)(id result))completion;
//- (void)retrieveMessageForMessageID:(int)messageID completion:(void (^)(id result))completion;
//- (void)retrieveMessagesForUserByUserID:(int)userID completion:(void (^)(id result))completion;
//- (void)submitNewMessageWithDictionary:(NSDictionary *)dict completion:(void (^)(id result))completion;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯

/**
 * Clubs
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
- (void)retrieveStatusUpdatesForClubByClubID:(int)clubID fromPage:(int)page completion:(void (^)(id result))completion;
- (void)retrieveStatusUpdateByStatusUpdateID:(int)statusUpdateID completion:(void (^)(id result))completion;
- (void)retrieveRepliesForStatusUpdateByStatusUpdateID:(int)statusUpdateID fromPage:(int)page completion:(void (^)(id result))completion;
- (void)retrieveUserClubsByUserID:(int)userID fromPage:(int)page completion:(void (^)(id result))completion;

//- (void)blockUserFromClubWithClubID:(int)clubID withOwnerID:(int)ownerID withUserID:(int)userID completion:(void (^)(id result))completion;
- (void)createClubWithTitle:(NSString *)title withDescription:(NSString *)blurb withImagePrefix:(NSString *)imagePrefix completion:(void (^)(id result))completion;
- (void)createClubWithTitle:(NSString *)title withDescription:(NSString *)blurb withImagePrefix:(NSString *)imagePrefix atLocation:(CLLocation *)location completion:(void (^)(id result))completion;
- (void)deleteClubWithClubID:(int)clubID completion:(void (^)(id result))completion;
- (void)editClubWithClubID:(int)clubID withTitle:(NSString *)title withDescription:(NSString *)blurb withImagePrefix:(NSString *)imagePrefix completion:(void (^)(id result))completion;
- (void)inviteInAppUsers:(NSArray *)inAppUsers toClubWithID:(int)clubID withClubOwnerID:(int)ownerID inviteNonAppContacts:(NSArray*)nonAppContacts completion:(void (^)(id result))completion;
- (void)inviteInAppUsers:(NSArray *)inAppUsers toClubWithID:(int)clubID withClubOwnerID:(int)ownerID completion:(void (^)(id result))completion;
- (void)inviteNonAppUsers:(NSArray *)inAppUsers toClubWithID:(int)clubID withClubOwnerID:(int)ownerID completion:(void (^)(id result))completion;
- (void)joinClub:(HONUserClubVO *)userClubVO completion:(void (^)(id result))completion;
- (void)leaveClub:(HONUserClubVO *)userClubVO completion:(void (^)(id result))completion;
- (void)retrieveClubByClubID:(int)clubID withOwnerID:(int)ownerID completion:(void (^)(id result))completion;
- (void)retrieveClubInvitesForUserWithUserID:(int)userID completion:(void (^)(id result))completion;
- (void)retrieveLocalSchoolTypeClubsWithAreaCode:(NSString *)areaCode completion:(void (^)(id result))completion;
- (void)retrieveFeaturedClubsWithCompletion:(void (^)(id result))completion;
- (void)retrieveNearbyClubFromLocation:(CLLocation *)location withinRadius:(CGFloat)radius completion:(void (^)(id result))completion;
- (void)searchForClubsByClubName:(NSString *)name completion:(void (^)(id result))completion;
//- (void)submitClubPhotoWithDictionary:(NSDictionary *)dict completion:(void (^)(id result))completion;
- (void)submitStatusUpdateWithDictionary:(NSDictionary *)dict completion:(void (^)(id result))completion;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯

/**
 * Invite / Social
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
- (void)searchUsersByPhoneNumber:(NSString *)phoneNumber completion:(void (^)(id result))completion;
- (void)searchForUsersByUsername:(NSString *)username completion:(void (^)(id result))completion;
- (void)sendEmailInvitesWithDelimitedList:(NSString *)emailAddresses completion:(void (^)(id result))completion;
- (void)sendSMSInvitesWithDelimitedList:(NSString *)phoneNumbers completion:(void (^)(id result))completion;
- (void)submitDelimitedEmailContacts:(NSString *)emailAddresses completion:(void (^)(id result))completion;
- (void)submitDelimitedPhoneContacts:(NSString *)phoneNumbers completion:(void (^)(id result))completion;
- (void)submitEmailAddressForUserMatching:(NSString *)phoneNumber completion:(void (^)(id result))completion;
- (void)submitPhoneNumberForUserMatching:(NSString *)phoneNumber completion:(void (^)(id result))completion;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯



/**
 * UI Presentation
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
- (void)showDataErrorHUD;
- (void)showSuccessHUD;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯


- (NSSet *)requestQueue;
- (void)addRequestToQueue:(AFHTTPRequestOperation *)requestOperation;
- (void)removeRequestToQueue:(AFHTTPRequestOperation *)requestOperation;


@end
