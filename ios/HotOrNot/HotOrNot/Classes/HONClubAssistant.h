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
- (NSDictionary *)emptyClubDictionaryWithOwner:(NSDictionary *)owner;
- (NSArray *)defaultCoverImagePrefixes;
- (NSString *)defaultCoverImagePrefix;
- (NSArray *)emotionsForClubPhoto:(HONClubPhotoVO *)clubPhotoVO;

- (void)wipeUserClubs;
- (NSDictionary *)fetchUserClubs;
- (void)writeUserClubs:(NSDictionary *)clubs;
@end
