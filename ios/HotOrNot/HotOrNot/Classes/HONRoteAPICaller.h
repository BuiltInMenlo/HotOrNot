//
//  HONRoteAPICaller.h
//  HotOrNot
//
//  Created by Matt Holcombe on 12/10/2013 @ 02:40 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HONRoteAPICaller : NSObject

+ (HONRoteAPICaller *)sharedInstance;


/**
 * Users
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
//- (void)flagUserByUserID:(int)userID;
//- (void)verifyUserWithUserID:(int)userID asLegit:(BOOL)isLegit;
//- (void)removeUserFromVerifyResultsByUserID:(int)userID;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯

/**
 * Challenges
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
//- (void)sendShoutoutChallengeWithUserID:(int)userID;
//- (void)sendShoutoutChallengeWithChallengeID:(int)challengeID;
//- (void)flagChallengeByChallengeID:(int)challengeID;
//- (void)markChallengeAsSeenWithChallengeID:(int)challengeID;
//- (void)notifyToProcessImageSizesForURLPrefix:(NSString *)imagePrefix;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯


/**
 * Invite / Social
 **///]~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~._
//- (void)sendAppInvitesToContactsViaSMS:(NSArray *)phoneNumbers;
//- (void)sendAppInvitesToContactsViaEmail:(NSArray *)emailAddresses;
//- (void)followerUserWithUserID:(int)userID;
//- (void)followerUserWithUserID:(int)userID isReciprocal:(BOOL)isMutualFollow;
//- (void)stopFollowingUserWithUserID:(int)userID;
//**/]~*~~*~~*~~*~~*~~*~~*~~*~~·¯



/**
 *
 **///ddd




@end
