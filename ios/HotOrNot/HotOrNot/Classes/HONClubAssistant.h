//
//  HONClubAssistant.h
//  HotOrNot
//
//  Created by Matt Holcombe on 05/04/2014 @ 00:29 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserClubVO.h"

@interface HONClubAssistant : NSObject
+ (HONClubAssistant *)sharedInstance;

- (NSArray *)clubTypeKeys;
- (NSDictionary *)fpoInviteClubDictionary;
- (NSDictionary *)fpoJoinedClubDictionary;
- (NSDictionary *)fpoOwnedClubDictionary;
- (NSDictionary *)emptyClubDictionary;
@end
