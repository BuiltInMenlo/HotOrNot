//
//  HONAPICaller.h
//  HotOrNot
//
//  Created by Matt Holcombe on 12/10/2013 @ 02:40 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HONOpponentVO.h"

@interface HONAPICaller : NSObject

+ (HONAPICaller *)sharedInstance;


/**
 * Helpers
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
- (void)notifyToProcessImageSizesForURL:(NSString *)imageURL completion:(void (^)(NSObject *result))completion;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯

/**
 * Users
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
- (void)checkForAvailableUsername:(NSString *)username andEmail:(NSString *)email completion:(void (^)(NSObject *result))completion;
- (void)finalizeUserWithDictionary:(NSDictionary *)dict completion:(void (^)(NSObject *result))completion;
- (void)flagUserByUserID:(int)userID completion:(void (^)(NSObject *result))completion;
- (void)recreateUserWithCompletion:(void (^)(NSObject *result))completion;
- (void)registerNewUserWithCompletion:(void (^)(NSObject *result))completion;
- (void)retrieveAlertsForUserByUserID:(int)userID completion:(void (^)(NSObject *result))completion;
- (void)retrieveChallengesForUserByUsername:(NSString *)username completion:(void (^)(NSObject *result))completion;
- (void)retrieveFollowersForUserByUserID:(int)userID completion:(void (^)(NSObject *result))completion;
- (void)retrieveUserByUserID:(int)userID completion:(void (^)(NSObject *result))completion;
- (void)removeUserFromVerifyListWithUserID:(int)userID completion:(void (^)(NSObject *result))completion;
- (void)togglePushNotificationsForUserByUserID:(int)userID areEnabled:(BOOL)isEnabled completion:(void (^)(NSObject *result))completion;
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
 * Invite / Social
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
- (void)followUserWithUserID:(int)userID completion:(void (^)(NSObject *result))completion;
- (void)followUserWithUserID:(int)userID isReciprocal:(BOOL)isMutualFollow completion:(void (^)(NSObject *result))completion;
- (void)followUsersByUserIDWithDelimitedList:(NSString *)userIDs completion:(void (^)(NSObject *result))completion;
- (void)followUsersByUserIDWithDelimitedList:(NSString *)userIDs isReciprocal:(BOOL)isMutualFollow completion:(void (^)(NSObject *result))completion;
- (void)sendDelimitedEmailContacts:(NSString *)emailAddresses completion:(void (^)(NSObject *result))completion;
- (void)sendDelimitedPhoneContacts:(NSString *)phoneNumbers completion:(void (^)(NSObject *result))completion;
- (void)sendEmailInvitesFromDelimitedList:(NSString *)emailAddresses completion:(void (^)(NSObject *result))completion;
- (void)sendSMSInvitesFromDelimitedList:(NSString *)phoneNumbers completion:(void (^)(NSObject *result))completion;
- (void)stopFollowingUserWithUserID:(int)userID completion:(void (^)(NSObject *result))completion;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯



/**
 *
 **/




@end
