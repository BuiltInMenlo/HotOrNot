//
//  HONClubAssistant.h
//  HotOrNot
//
//  Created by Matt Holcombe on 05/04/2014 @ 00:29 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserClubVO.h"
#import "HONClubPhotoVO.h"
#import "HONCommentVO.h"
#import "HONEmotionVO.h"

@interface HONClubAssistant : NSObject
+ (HONClubAssistant *)sharedInstance;

- (void)generateSelfieclubOwnedClubWithName:(NSString *)clubName andBlurb:(NSString *)blurb;
- (NSArray *)clubTypeKeys;
- (NSMutableDictionary *)emptyClubDictionaryWithOwner:(NSDictionary *)owner;
- (NSMutableDictionary *)clubDictionaryWithOwner:(NSDictionary *)owner activeMembers:(NSArray *)active pendingMembers:(NSArray *)pending;
- (void)createLocationClubWithCompletion:(void (^)(id result))completion;
- (void)locationClubWithCompletion:(void (^)(id result))completion;
- (HONUserClubVO *)currentLocationClub;
- (NSMutableDictionary *)emptyClubPhotoDictionary;
- (NSString *)userSignupClubCoverImageURL;
- (NSString *)defaultCoverImageURL;
- (NSString *)rndCoverImageURL;
- (NSString *)defaultClubPhotoURL;
- (NSArray *)clubCoverPhotoAlbumPrefixes;
- (int)labelIDForAreaCode:(NSString *)areaCode;
- (BOOL)isMemberOfClub:(HONUserClubVO *)clubVO includePending:(BOOL)isPending;
- (BOOL)isMemberOfClubWithClubID:(int)clubID includePending:(BOOL)isPending;
- (BOOL)isClubNameMatchedForUserClubs:(NSString *)clubName;
- (BOOL)isClubNameMatchedForUserClubs:(NSString *)clubName considerWhitespace:(BOOL)isWhitespace;
- (void)isStatusUpdateSeenWithID:(int)statusUpdateID completion:(void (^)(BOOL isSeen))completion;
- (BOOL)hasVotedForClubPhoto:(HONClubPhotoVO *)clubPhotoVO;
- (BOOL)hasVotedForComment:(HONCommentVO *)commentVO;
- (HONUserClubVO *)userSignupClub;
- (NSArray *)emotionsForClubPhoto:(HONClubPhotoVO *)clubPhotoVO;

- (void)copyUserSignupClubToClipboardWithAlert:(BOOL)showsAlert;
- (void)copyClubToClipBoard:(HONUserClubVO *)clubVO withAlert:(BOOL)showsAlert;

- (NSArray *)suggestedClubs;
- (HONUserClubVO *)suggestedAreaCodeClubVO;
- (HONUserClubVO *)suggestedEmailClubVO:(NSArray *)domains;
- (HONUserClubVO *)suggestedFamilyClubVO;
- (HONUserClubVO *)suggestedSchoolClubVO;
- (HONUserClubVO *)suggestedBAEClubVO;
- (HONUserClubVO *)suggestedBFFsClubVO;
- (HONUserClubVO *)suggestedWorkplaceClubVO;

- (void)writePreClubWithTitle:(NSString *)title andBlurb:(NSString *)blurb andCoverPrefixURL:(NSString *)coverPrefix;
- (NSDictionary *)fetchPreClub;

- (void)wipeUserClubs;
- (NSDictionary *)fetchUserClubs;
- (HONUserClubVO *)fetchClubWithClubID:(int)clubID;
- (HONClubPhotoVO *)fetchClubPhotoWithClubPhotoID:(int)challengeID;
- (void)writeClub:(NSDictionary *)clubDictionary;
- (void)writeUserClubs:(NSDictionary *)clubs;
- (void)writeStatusUpdateAsSeenWithID:(int)statusUpdateID completion:(void (^)(id result))completion;
- (void)writeStatusUpdateAsVotedWithID:(int)statusUpdateID asUpVote:(BOOL)isUpVote;
- (void)writeCommentAsVotedWithID:(int)commentID asUpVote:(BOOL)isUpVote;
- (void)sendClubInvites:(HONUserClubVO *)clubVO toInAppUsers:(NSArray *)inAppUsers toNonAppContacts:(NSArray *)nonAppContacts completion:(void (^)(BOOL success))completion;

- (NSArray *)repliesForClubPhoto:(HONClubPhotoVO *)clubPhotoVO;

- (HONUserClubVO *)clubWithClubID:(int)clubID;
- (HONUserClubVO *)clubWithName:(NSString *)clubName;
- (HONUserClubVO *)clubWithParticipants:(NSArray *)participants;
- (HONUserClubVO *)createClubWithSameParticipants:(NSArray *)participants;
- (HONClubPhotoVO *)submitClubPhotoIntoClub:(HONUserClubVO *)clubVO;

@end
