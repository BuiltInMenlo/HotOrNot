//
//  HONContactsAssistant.m
//  HotOrNot
//
//  Created by Matt Holcombe on 07/26/2014 @ 11:50 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "NSString+DataTypes.h"

#import "HONContactsAssistant.h"

@implementation HONContactsAssistant
static HONContactsAssistant *sharedInstance = nil;

+ (HONContactsAssistant *)sharedInstance {
	static HONContactsAssistant *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[self alloc] init];
	});
	
	return (s_sharedInstance);
}

- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}


- (BOOL)hasAdressBookPermission {
	return (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized);
}


- (NSArray *)deviceContactsSortedByName:(BOOL)isSorted {
	NSMutableArray *contactVOs = [NSMutableArray array];
	NSMutableArray *contactDicts = [NSMutableArray array];
	
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
	CFIndex nPeople = MIN(100, ABAddressBookGetPersonCount(addressBook));
	
	for (int i=0; i<nPeople; i++) {
		ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
		
		NSString *fName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
		NSString *lName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
		
		fName = ([fName isEqual:[NSNull null]] || [fName length] == 0) ? @"" : fName;
		lName = ([lName isEqual:[NSNull null]] || [lName length] == 0) ? @"" : lName;
		
		if ([fName length] == 0 && [lName length] == 0)
			continue;
		
		
		NSData *imageData = nil;
		if (ABPersonHasImageData(ref))
			imageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
		imageData = (imageData == nil) ? UIImagePNGRepresentation([UIImage imageNamed:@"avatarPlaceholder"]) : imageData;
		
		
		ABMultiValueRef phoneProperties = ABRecordCopyValue(ref, kABPersonPhoneProperty);
		CFIndex phoneCount = ABMultiValueGetCount(phoneProperties);
		NSString *phoneNumber = (phoneCount > 0) ? (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, 0) : @"";
		CFRelease(phoneProperties);
		
		
		ABMultiValueRef emailProperties = ABRecordCopyValue(ref, kABPersonEmailProperty);
		CFIndex emailCount = ABMultiValueGetCount(emailProperties);
		NSString *email = (emailCount > 0) ? (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailProperties, 0) : @"";
		CFRelease(emailProperties);
		
		
		if ([phoneNumber length] > 0 || [email length] > 0) {
			[contactDicts addObject:@{@"f_name"	: fName,
									  @"l_name"	: lName,
									  @"phone"	: phoneNumber,
									  @"email"	: email,
									  @"image"	: imageData}];
		}
	}
	
	
	contactDicts = (isSorted) ? [[NSArray arrayWithArray:[contactDicts sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"l_name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]] mutableCopy] : contactDicts;
	for (NSDictionary *dict in contactDicts)
		[contactVOs addObject:[HONContactUserVO contactWithDictionary:dict]];

	
	return ([contactVOs copy]);
}


- (int)totalInvitedContacts {
	return (([[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] == nil) ? 0 : [[[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] count]);
}


- (void)writeContactUser:(HONContactUserVO *)contactUserVO toInvitedClub:(HONUserClubVO *)clubVO {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] == nil)
		[[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"club_invites"];
	
	NSMutableArray *invites = [[[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] mutableCopy];
//	NSLog(@"CLUB INVITES:[%@]", invites);
	
	BOOL isFound = NO;
	for (NSDictionary *dict in invites) {
		if ([[dict objectForKey:@"club_id"] isEqualToString:[@"" stringFromInt:clubVO.clubID]] && [[dict objectForKey:@"phone"] isEqualToString:contactUserVO.mobileNumber]) {
			isFound = YES;
			break;
		}
	}
	
	if (!isFound) {
		[invites addObject:@{@"club_id"		: [@"" stringFromInt:clubVO.clubID],
							 @"user_id"		: [@"" stringFromInt:0],
							 @"phone"		: contactUserVO.mobileNumber}];
		
		[[NSUserDefaults standardUserDefaults] setObject:[invites copy] forKey:@"club_invites"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	if ([[HONContactsAssistant sharedInstance] totalInvitedContacts] >= 3)
		[[HONStickerAssistant sharedInstance] retrieveStickersWithPakType:HONStickerPakTypeInviteBonus completion:nil];
}

- (void)writeTrivialUser:(HONTrivialUserVO *)trivialUserVO toInvitedClub:(HONUserClubVO *)clubVO {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] == nil)
		[[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"club_invites"];
	
	NSMutableArray *invites = [[[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] mutableCopy];
//	NSLog(@"CLUB INVITES:[%@]", invites);
	
	BOOL isFound = NO;
	for (NSDictionary *dict in invites) {
		if ([[dict objectForKey:@"club_id"] isEqualToString:[@"" stringFromInt:clubVO.clubID]] && [[dict objectForKey:@"user_id"] isEqualToString:[@"" stringFromInt:trivialUserVO.userID]]) {
			isFound = YES;
			break;
		}
	}
	
	if (!isFound) {
		[invites addObject:@{@"club_id"		: [@"" stringFromInt:clubVO.clubID],
							 @"user_id"		: [@"" stringFromInt:trivialUserVO.userID],
							 @"phone"		: @""}];
		
		[[NSUserDefaults standardUserDefaults] setObject:[invites copy] forKey:@"club_invites"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	if ([[HONContactsAssistant sharedInstance] totalInvitedContacts] >= 3)
		[[HONStickerAssistant sharedInstance] retrieveStickersWithPakType:HONStickerPakTypeInviteBonus completion:nil];
}

- (BOOL)isContactUserInvitedToClubs:(HONContactUserVO *)contactUserVO {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] == nil)
		[[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"club_invites"];
	
//	NSLog(@"CLUB INVITES:[%@]", [[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"]);
	
	BOOL isFound = NO;
	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"]) {
		for (NSString *key in @[@"owned", @"member"]) {
			for (NSDictionary *clubDict in [[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:key]) {
				HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:clubDict];
				
				if ([[dict objectForKey:@"club_id"] isEqualToString:[@"" stringFromInt:vo.clubID]] && [[dict objectForKey:@"phone"] isEqualToString:contactUserVO.mobileNumber]) {
					isFound = YES;
					break;
				}
			}
		}
	}
	
	return (isFound);
}

- (BOOL)isTrivialUserInvitedToClubs:(HONTrivialUserVO *)trivialUserVO {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] == nil)
		[[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"club_invites"];
	
//	NSLog(@"CLUB INVITES:[%@]", [[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"]);
	
	BOOL isFound = NO;
	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"]) {
		for (NSString *key in @[@"owned", @"member"]) {
			for (NSDictionary *clubDict in [[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:key]) {
				HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:clubDict];
				
				if ([[dict objectForKey:@"club_id"] isEqualToString:[@"" stringFromInt:vo.clubID]] && [[dict objectForKey:@"user_id"] isEqualToString:[@"" stringFromInt:trivialUserVO.userID]]) {
					isFound = YES;
					break;
				}
			}
		}
	}
	
	return (isFound);
}

- (BOOL)isContactUser:(HONContactUserVO *)contactUserVO invitedToClub:(HONUserClubVO *)clubVO {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] == nil)
		[[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"club_invites"];
	
//	NSLog(@"CLUB INVITES:[%@]", [[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"]);
	
	BOOL isFound = NO;
	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"]) {
		if ([[dict objectForKey:@"club_id"] isEqualToString:[@"" stringFromInt:clubVO.clubID]] && [[dict objectForKey:@"phone"] isEqualToString:contactUserVO.mobileNumber]) {
			isFound = YES;
			break;
		}
	}
	
	return (isFound);
}

- (BOOL)isTrivialUser:(HONTrivialUserVO *)trivialUserVO invitedToClub:(HONUserClubVO *)clubVO {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] == nil)
		[[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"club_invites"];
	
//	NSLog(@"CLUB INVITES:[%@]", [[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"]);
	
	BOOL isFound = NO;
	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"]) {
		if ([[dict objectForKey:@"club_id"] isEqualToString:[@"" stringFromInt:clubVO.clubID]] && [[dict objectForKey:@"user_id"] isEqualToString:[@"" stringFromInt:trivialUserVO.userID]]) {
			isFound = YES;
			break;
		}
	}
	
	return (isFound);
}

@end
