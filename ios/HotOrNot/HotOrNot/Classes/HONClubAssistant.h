//
//  HONClubAssistant.h
//  HotOrNot
//
//  Created by Matt Holcombe on 05/04/2014 @ 00:29 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserClubVO.h"
#import "HONClubPhotoVO.h"
#import "HONEmotionVO.h"

@interface HONClubAssistant : NSObject
+ (HONClubAssistant *)sharedInstance;

- (NSArray *)clubTypeKeys;
- (NSDictionary *)createClubDictionary;
- (NSMutableDictionary *)emptyClubDictionaryWithOwner:(NSDictionary *)owner;
- (NSDictionary *)orthodoxThresholdClubDictionary;
- (NSDictionary *)emptyClubPhotoDictionary;
- (NSString *)userSignupClubCoverImageURL;
- (NSString *)defaultCoverImageURL;
- (NSString *)rndCoverImageURL;
- (NSString *)defaultClubPhotoURL;
- (NSArray *)clubCoverPhotoAlbumPrefixes;
- (int)labelIDForAreaCode:(NSString *)areaCode;
- (BOOL)isClubNameMatchedForUserClubs:(NSString *)clubName;
- (BOOL)isClubNameMatchedForUserClubs:(NSString *)clubName considerWhitespace:(BOOL)isWhitespace;
- (void)isStatusUpdateSeenWithID:(int)statusUpdateID completion:(void (^)(BOOL isSeen))completion;
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
- (void)addClub:(NSDictionary *)club forKey:(NSString *)key;
- (void)writeUserClubs:(NSDictionary *)clubs;
- (void)writeStatusUpdateAsSeenWithID:(int)statusUpdateID;
- (void)sendClubInvites:(HONUserClubVO *)clubVO toInAppUsers:(NSArray *)inAppUsers ToNonAppContacts:(NSArray *)nonAppContacts onCompletion:(void (^)(BOOL success))completion;

- (NSArray *)excludedClubDomains;

- (HONUserClubVO *)clubWithParticipants:(NSArray *)participants;
//- (void)generateClubWithClubMembers:(NSArray *)
- (HONUserClubVO *)createClubWithSameParticipants:(NSArray *)participants;
- (HONClubPhotoVO *)submitClubPhotoIntoClub:(HONUserClubVO *)clubVO;

@end
