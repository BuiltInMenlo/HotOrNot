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
#import "HONTrivialUserVO.h"
#import "HONUserClubVO.h"
#import "HONClubPhotoVO.h"


typedef NS_ENUM(NSUInteger, HONS3BucketType) {
	HONS3BucketTypeAvatars = 0,
	HONS3BucketTypeSelfies,
	HONS3BucketTypeClubs
};



// api endpts
extern NSString * const kAPIChallenges;
extern NSString * const kAPIComments;
extern NSString * const kAPISearch;
extern NSString * const kAPIUsers;
extern NSString * const kAPIVotes;

extern NSString * const kAPIMemberClubs;
extern NSString * const kAPIClubStatusUpdates;
extern NSString * const kAPIStatusUpdate;
extern NSString * const kAPIStatusUpdateChildren;
extern NSString * const kAPIStatusUpdateVoters;

extern NSString * const kAPIGetFriends;
extern NSString * const kAPIGetSubscribees;
extern NSString * const kAPIAddFriend;
extern NSString * const kAPIRemoveFriend;
extern NSString * const kAPISMSInvites;
extern NSString * const kAPIEmailInvites;
extern NSString * const kAPITumblrLogin;
extern NSString * const kAPIEmailVerify;
extern NSString * const kAPIPhoneVerify;
extern NSString * const kAPIEmailContacts;
extern NSString * const kAPIChallengeObject;
extern NSString * const kAPIGetPublicChallenges;
//extern NSString * const kAPIUsersGetUsersClubs;
extern NSString * const kAPICheckNameAndEmail;
extern NSString * const kAPIUsersFirstRunComplete;
extern NSString * const kAPISetUserAgeGroup;
extern NSString * const kAPICreateChallenge;
extern NSString * const kAPIJoinChallenge;
extern NSString * const kAPIGetVerifyList;
extern NSString * const kAPIProcessChallengeImage;
extern NSString * const kAPIProcessUserImage;
extern NSString * const kAPISuspendedAccount;
extern NSString * const kAPIPurgeUser;
extern NSString * const kAPIPurgeContent;
extern NSString * const kAPIGetActivity;
extern NSString * const kAPIDeleteImage;
extern NSString * const kAPIVerifyShoutout;
extern NSString * const kAPIProfileShoutout;
extern NSString * const kAPIGetMessages;
extern NSString * const kAPICreateMessage;
extern NSString * const kAPIChallengesMessageSeen;

extern NSString * const kAPIClubsCreate;
extern NSString * const kAPIClubsEdit;
extern NSString * const kAPIClubsInvite;
extern NSString * const kAPIClubsProcessImage;
extern NSString * const kAPIClubsDelete;
extern NSString * const kAPIClubsGet;
extern NSString * const kAPIClubsJoin;
extern NSString * const kAPIClubsQuit;
extern NSString * const kAPIClubsBlock;
extern NSString * const kAPIClubsUnblock;
extern NSString * const kAPIClubsFeatured;
extern NSString * const kAPIUsersGetClubs;
extern NSString * const kAPIUsersSetDeviceToken;
extern NSString * const kAPIUsersGetClubInvites;
extern NSString * const kAPIUsersCheckUsername;
extern NSString * const kAPIUsersCheckPhone;
extern NSString * const kAPIStatusupdate;

// network error descriptions
extern NSString * const kNetErrorNoConnection;
extern NSString * const kNetErrorStatusCode404;

// network times
extern const CGFloat kNotifiyDelay;



@interface HONAPICaller : NSObject
+ (HONAPICaller *)sharedInstance;


/**
 * Utility
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
- (NSString *)phpAPIBasePath;
- (NSString *)pythonAPIBasePath;

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
- (void)notifyToCreateImageSizesForPrefix:(NSString *)prefixURL forBucketType:(HONS3BucketType)bucketType completion:(void (^)(id result))completion;
- (void)notifyToCreateImageSizesForPrefix:(NSString *)prefixURL forBucketType:(HONS3BucketType)bucketType preDelay:(int64_t)delay completion:(void (^)(id result))completion;
//- (void)notifyToCreateImageSizesForURL:(NSString *)imageURL forAvatarBucket:(BOOL)isAvatarBucket completion:(void (^)(id result))completion;
//- (void)notifyToCreateImageSizesForURL:(NSString *)imageURL forAvatarBucket:(BOOL)isAvatarBucket preDelay:(int64_t)delay completion:(void (^)(id result))completion;
- (void)uploadPhotosToS3:(NSArray *)imageData intoBucketType:(HONS3BucketType)bucketType withFilename:(NSString *)filename completion:(void (^)(id result))completion;
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
