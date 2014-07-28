//
//  HONContactsAssistant.m
//  HotOrNot
//
//  Created by Matt Holcombe on 07/26/2014 @ 11:50 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

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


- (void)writeContactUser:(HONContactUserVO *)contactUserVO toInvitedClub:(HONUserClubVO *)clubVO {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] == nil)
		[[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"club_invites"];
	
	NSMutableArray *invites = [[[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] mutableCopy];
	
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
}

- (void)writeTrivialUser:(HONTrivialUserVO *)trivialUserVO toInvitedClub:(HONUserClubVO *)clubVO {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] == nil)
		[[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"club_invites"];
	
	NSMutableArray *invites = [[[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] mutableCopy];
	
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
}

- (BOOL)isContactUserInvitedToClubs:(HONContactUserVO *)contactUserVO {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] == nil)
		[[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"club_invites"];
	
	BOOL isFound = NO;
	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"]) {
		NSLog(@"CLUB INVITES:[%@]", dict);
		
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
	
	BOOL isFound = NO;
	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"]) {
		NSLog(@"CLUB INVITES:[%@]", dict);
		
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
	
	BOOL isFound = NO;
	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"]) {
		NSLog(@"CLUB INVITES:[%@]", dict);
		
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
	
	BOOL isFound = NO;
	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"]) {
		NSLog(@"CLUB INVITES:[%@]", dict);
		
		if ([[dict objectForKey:@"club_id"] isEqualToString:[@"" stringFromInt:clubVO.clubID]] && [[dict objectForKey:@"user_id"] isEqualToString:[@"" stringFromInt:trivialUserVO.userID]]) {
			isFound = YES;
			break;
		}
	}
	
	return (isFound);
}

@end
