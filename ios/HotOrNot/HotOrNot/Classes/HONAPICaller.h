//
//  HONAPICaller.h
//  HotOrNot
//
//  Created by Matt Holcombe on 12/10/2013 @ 12:40.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"

#import "HONOpponentVO.h"

// api endpts
extern NSString * const kAPIChallenges;
extern NSString * const kAPIComments;
extern NSString * const kAPISearch;
extern NSString * const kAPIUsers;
extern NSString * const kAPIVotes;

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


@interface HONAPICaller : NSObject

+ (HONAPICaller *)sharedInstance;


/**
 * Utility
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
- (AFHTTPClient *)getHttpClientWithHMAC;
- (NSMutableString *)hmacForKey:(NSString *)key withData:(NSString *)data;
- (NSMutableString *)hmacToken;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯

/**
 * Images
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
- (void)notifyToCreateImageSizesForURL:(NSString *)imageURL forAvatarBucket:(BOOL)isAvatarBucket completion:(void (^)(NSObject *result))completion;
- (void)notifyToCreateImageSizesForURL:(NSString *)imageURL forAvatarBucket:(BOOL)isAvatarBucket preDelay:(int64_t)delay completion:(void (^)(NSObject *result))completion;
- (void)uploadPhotosToS3:(NSArray *)imageData intoBucket:(NSString *)bucket withFilename:(NSString *)filename completion:(void (^)(NSObject *result))completion;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯

/**
 * Users
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
- (void)checkForAvailableUsername:(NSString *)username andEmail:(NSString *)email completion:(void (^)(NSObject *result))completion;
- (void)deactivateUserWithCompletion:(void (^)(NSObject *result))completion;
- (void)finalizeUserWithDictionary:(NSDictionary *)dict completion:(void (^)(NSObject *result))completion;
- (void)flagUserByUserID:(int)userID completion:(void (^)(NSObject *result))completion;
- (void)recreateUserWithCompletion:(void (^)(NSObject *result))completion;
- (void)registerNewUserWithCompletion:(void (^)(NSObject *result))completion;
- (void)retrieveAlertsForUserByUserID:(int)userID completion:(void (^)(NSObject *result))completion;
- (void)retrieveChallengesForUserByUserID:(int)userID completion:(void (^)(NSObject *result))completion;
- (void)retrieveChallengesForUserByUsername:(NSString *)username completion:(void (^)(NSObject *result))completion;
- (void)retrieveFollowingUsersForUserByUserID:(int)userID completion:(void (^)(NSObject *result))completion;
- (void)retrieveUserByUserID:(int)userID completion:(void (^)(NSObject *result))completion;
- (void)removeAllChallengesForUserWithCompletion:(void (^)(NSObject *result))completion;
- (void)removeUserFromVerifyListWithUserID:(int)userID completion:(void (^)(NSObject *result))completion;
- (void)submitPasscodeToLiftAccountSuspension:(NSString *)passcode completion:(void (^)(NSObject *result))completion;
- (void)togglePushNotificationsForUserByUserID:(int)userID areEnabled:(BOOL)isEnabled completion:(void (^)(NSObject *result))completion;
- (void)updateAvatarWithImagePrefix:(NSString *)avatarPrefix completion:(void (^)(NSObject *result))completion;
- (void)updateTabBarBadgeTotalsForUserByUserID:(int)userID completion:(void (^)(NSObject *result))completion;
- (void)updateUsernameForUser:(NSString *)username completion:(void (^)(NSObject *result))completion;
- (void)verifyUserWithUserID:(int)userID asLegit:(BOOL)isLegit completion:(void (^)(NSObject *result))completion;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯

/**
 * Challenges
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
- (void)createShoutoutChallengeWithChallengeID:(int)challengeID completion:(void (^)(NSObject *result))completion;
- (void)createShoutoutChallengeWithUserID:(int)userID completion:(void (^)(NSObject *result))completion;
- (void)flagChallengeByChallengeID:(int)challengeID completion:(void (^)(NSObject *result))completion;
- (void)markChallengeAsSeenWithChallengeID:(int)challengeID completion:(void (^)(NSObject *result))completion;
- (void)markChallengeAsUnseenWithChallengeID:(int)challengeID completion:(void (^)(NSObject *result))completion;
- (void)removeChallengeForChallengeID:(int)challengeID withImagePrefix:(NSString *)imagePrefix completion:(void (^)(NSObject *result))completion;
- (void)retrieveChallengeForChallengeID:(int)challengeID completion:(void (^)(NSObject *result))completion;
- (void)retrieveChallengeForChallengeID:(int)challengeID igoringNextPushes:(BOOL)isIgnore completion:(void (^)(NSObject *result))completion;
- (void)retrieveVerifyListForUserID:(int)userID completion:(void (^)(NSObject *result))completion;
- (void)submitChallengeWithDictionary:(NSDictionary *)dict completion:(void (^)(NSObject *result))completion;
- (void)upvoteChallengeWithChallengeID:(int)challengeID forOpponent:(HONOpponentVO *)opponentVO completion:(void (^)(NSObject *result))completion;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯

/**
 * Messages
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
- (void)markMessageAsSeenForMessageID:(int)messageID forParticipant:(int)userID completion:(void (^)(NSObject *result))completion;
- (void)retrieveMessageForMessageID:(int)messageID completion:(void (^)(NSObject *result))completion;
- (void)retrieveMessagesForUserByUserID:(int)userID completion:(void (^)(NSObject *result))completion;
- (void)submitNewMessageWithDictionary:(NSDictionary *)dict completion:(void (^)(NSObject *result))completion;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯

/**
 * Clubs
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
- (void)showDataErrorHUD;
- (void)showSuccessHUD;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯

/**
 * Clubs
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯

/**
 * Invite / Social
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
- (void)followUserWithUserID:(int)userID completion:(void (^)(NSObject *result))completion;
- (void)followUserWithUserID:(int)userID isReciprocal:(BOOL)isMutualFollow completion:(void (^)(NSObject *result))completion;
- (void)followUsersByUserIDWithDelimitedList:(NSString *)userIDs completion:(void (^)(NSObject *result))completion;
- (void)followUsersByUserIDWithDelimitedList:(NSString *)userIDs isReciprocal:(BOOL)isMutualFollow completion:(void (^)(NSObject *result))completion;
- (void)searchForUsersByUsername:(NSString *)username completion:(void (^)(NSObject *result))completion;
- (void)sendDelimitedEmailContacts:(NSString *)emailAddresses completion:(void (^)(NSObject *result))completion;
- (void)sendDelimitedPhoneContacts:(NSString *)phoneNumbers completion:(void (^)(NSObject *result))completion;
- (void)sendEmailInvitesFromDelimitedList:(NSString *)emailAddresses completion:(void (^)(NSObject *result))completion;
- (void)sendSMSInvitesFromDelimitedList:(NSString *)phoneNumbers completion:(void (^)(NSObject *result))completion;
- (void)stopFollowingUserWithUserID:(int)userID completion:(void (^)(NSObject *result))completion;
- (void)submitEmailAddressForContactsMatching:(NSString *)phoneNumber completion:(void (^)(NSObject *result))completion;
- (void)submitPhoneNumberForContactsMatching:(NSString *)phoneNumber completion:(void (^)(NSObject *result))completion;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯



/**
 * UI Presentation
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
- (void)showDataErrorHUD;
- (void)showSuccessHUD;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯


@end
