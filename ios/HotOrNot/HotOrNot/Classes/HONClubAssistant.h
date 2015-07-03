//
//  HONClubAssistant.h
//  HotOrNot
//
//  Created by Matt Holcombe on 05/04/2014 @ 00:29 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserClubVO.h"
#import "HONClubPhotoVO.h"
#import "HONStatusUpdateVO.h"
#import "HONCommentVO.h"
#import "HONSubjectVO.h"
#import "HONTopicVO.h"
#import "HONUserVO.h"

@interface HONClubAssistant : NSObject
+ (HONClubAssistant *)sharedInstance;

- (void)generateSelfieclubOwnedClubWithName:(NSString *)clubName andBlurb:(NSString *)blurb;
- (NSArray *)clubTypeKeys;
- (NSMutableDictionary *)emptyClubDictionaryWithOwner:(NSDictionary *)owner;
- (NSMutableDictionary *)clubDictionaryWithOwner:(NSDictionary *)owner activeMembers:(NSArray *)active pendingMembers:(NSArray *)pending;
- (void)createLocationClubWithCompletion:(void (^)(id result))completion;
- (void)nearbyClubWithCompletion:(void (^)(id result))completion;
- (void)joinGlobalClubWithCompletion:(void (^)(id result))completion;
- (NSArray *)staffDesignatedClubsWithThreshold:(int)threshold;
- (HONUserClubVO *)globalClub;
- (HONUserClubVO *)currentLocationClub;
- (void)writeCurrentLocationClub:(HONUserClubVO *)clubVO;

- (HONUserClubVO *)homeLocationClub;
- (void)writeHomeLocationClub:(HONUserClubVO *)clubVO;

- (HONUserVO *)clubMemberWithUserID:(int)userID;

//- (NSMutableDictionary *)emptyClubPhotoDictionary;
//- (NSString *)userSignupClubCoverImageURL;
- (NSString *)defaultCoverImageURL;
//- (NSString *)rndCoverImageURL;
//- (NSString *)defaultClubPhotoURL;
- (NSString *)defaultStatusUpdatePhotoURL;
//- (NSArray *)clubCoverPhotoAlbumPrefixes;
//- (int)labelIDForAreaCode:(NSString *)areaCode;
- (BOOL)isMemberOfClub:(HONUserClubVO *)clubVO;
- (BOOL)isMemberOfClubWithClubID:(int)clubID;
- (BOOL)isStaffClub:(HONUserClubVO *)clubVO;
//- (BOOL)isClubNameMatchedForUserClubs:(NSString *)clubName;
//- (BOOL)isClubNameMatchedForUserClubs:(NSString *)clubName considerWhitespace:(BOOL)isWhitespace;
//- (BOOL)hasVotedForClubPhoto:(HONClubPhotoVO *)clubPhotoVO;
- (BOOL)hasVotedForStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO;
- (BOOL)hasVotedForComment:(HONCommentVO *)commentVO;
//- (HONUserClubVO *)userSignupClub;
- (HONSubjectVO *)subjectForClubPhoto:(HONClubPhotoVO *)clubPhotoVO;
- (HONSubjectVO *)subjectForStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO;
- (HONTopicVO *)topicForClubPhoto:(HONClubPhotoVO *)clubPhotoVO;
- (HONTopicVO *)topicForStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO;

- (void)copyClubToClipBoard:(HONUserClubVO *)clubVO withAlert:(BOOL)showsAlert;

//- (void)wipeUserClubs;
//- (NSDictionary *)fetchUserClubs;
//- (HONUserClubVO *)fetchClubWithClubID:(int)clubID;
//- (HONClubPhotoVO *)fetchClubPhotoWithClubPhotoID:(int)challengeID;
//- (void)writeClub:(NSDictionary *)clubDictionary;
//- (void)writeUserClubs:(NSDictionary *)clubs;
//- (void)writeStatusUpdateAsSeenWithID:(int)statusUpdateID completion:(void (^)(id result))completion;
- (void)writeStatusUpdateAsVotedWithID:(int)statusUpdateID asUpVote:(BOOL)isUpVote;
- (void)writeCommentAsVotedWithID:(int)commentID asUpVote:(BOOL)isUpVote;
//- (void)sendClubInvites:(HONUserClubVO *)clubVO toInAppUsers:(NSArray *)inAppUsers toNonAppContacts:(NSArray *)nonAppContacts completion:(void (^)(BOOL success))completion;

- (NSArray *)repliesForStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO;

//- (HONUserClubVO *)clubWithClubID:(int)clubID;
//- (HONUserClubVO *)clubWithName:(NSString *)clubName;
//- (HONUserClubVO *)clubWithParticipants:(NSArray *)participants;
//- (HONUserClubVO *)createClubWithSameParticipants:(NSArray *)participants;
//- (HONClubPhotoVO *)submitClubPhotoIntoClub:(HONUserClubVO *)clubVO;

@end
