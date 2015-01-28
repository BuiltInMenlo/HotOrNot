//
//  HONContactsAssistant.h
//  HotOrNot
//
//  Created by Matt Holcombe on 07/26/2014 @ 11:50 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONContactUserVO.h"
#import "HONTrivialUserVO.h"
#import "HONUserClubVO.h"

@interface HONSocialAssistant : NSObject
+ (HONSocialAssistant *)sharedInstance;

- (BOOL)hasAdressBookPermission;
- (NSArray *)deviceContactsSortedByName:(BOOL)isSorted;

- (BOOL)isContactUserInvitedToClubs:(HONContactUserVO *)contactUserVO;
- (BOOL)isTrivialUserInvitedToClubs:(HONTrivialUserVO *)trivialUserVO;
- (BOOL)isContactUser:(HONContactUserVO *)contactUserVO invitedToClub:(HONUserClubVO *)clubVO;
- (BOOL)isTrivialUser:(HONTrivialUserVO *)trivialUserVO invitedToClub:(HONUserClubVO *)clubVO;

- (int)totalInvitedContacts;
- (void)writeContactUser:(HONContactUserVO *)contactUserVO toInvitedClub:(HONUserClubVO *)clubVO;
- (void)writeTrivialUser:(HONTrivialUserVO *)trivialUserVO toInvitedClub:(HONUserClubVO *)clubVO;

- (void)writeTrivialUserToDeviceContacts:(HONTrivialUserVO *)trivialUserVO;

@end
