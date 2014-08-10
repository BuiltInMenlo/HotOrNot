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
- (NSDictionary *)emptyClubDictionaryWithOwner:(NSDictionary *)owner;
- (NSDictionary *)orthodoxThresholdClubDictionary;
- (NSArray *)defaultCoverImagePrefixes;
- (NSString *)userSignupClubCoverImageURL;
- (NSString *)defaultCoverImageURL;
- (NSString *)defaultClubPhotoURL;
- (NSArray *)clubCoverPhotoAlbumPrefixes;
- (int)labelIDForAreaCode:(NSString *)areaCode;
- (BOOL)isClubNameMatchedForUserClubs:(NSString *)clubName;
- (HONUserClubVO *)userSignupClub;
- (NSArray *)emotionsForClubPhoto:(HONClubPhotoVO *)clubPhotoVO;
- (NSArray *)suggestedClubs;

- (HONUserClubVO *)suggestedAreaCodeClubVO;
- (HONUserClubVO *)suggestedEmailClubVO:(NSArray *)domains;
- (HONUserClubVO *)suggestedFamilyClubVO;
- (HONUserClubVO *)suggestedWorkplaceClubVO;

- (void)wipeUserClubs;
- (NSDictionary *)fetchUserClubs;
- (void)addClub:(NSDictionary *)club forKey:(NSString *)key;
- (void)writeUserClubs:(NSDictionary *)clubs;

- (NSArray *)excludedClubDomains;
@end
