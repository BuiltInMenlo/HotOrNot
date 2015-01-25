//
//  LYRConversation+Additions.h
//  HotOrNot
//
//  Created by BIM  on 1/23/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import <LayerKit/LayerKit.h>

@interface LYRConversation (Additions)
- (NSString *)identifierSuffix;
- (int)creatorID;
- (NSString *)creatorName;
- (NSString *)creatorAvatarPrefix;
- (NSString *)toString;
@end

@interface LYRMessage (Additions)
- (NSString *)identifierSuffix;
- (NSString *)toString;
@end
//
//  LYRConversation+Additions.m
//  HotOrNot
//
//  Created by BIM  on 1/23/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"

#import "LYRConversation+Additions.h"

@implementation LYRConversation (Additions)

- (NSString *)identifierSuffix {
	return ([[self.identifier.absoluteString componentsSeparatedByString:@"/"] lastObject]);
}

- (int)creatorID {
	return (([self.metadata objectForKey:@"creator_id"] != nil) ? [[self.metadata objectForKey:@"creator_id"] intValue] : 0);
}

- (NSString *)creatorName {
	return (([self.metadata objectForKey:@"creator_name"] != nil) ? [self.metadata objectForKey:@"creator_name"] : [[HONUserAssistant sharedInstance] usernameForUserID:self.creatorID]);
}

- (NSString *)creatorAvatarPrefix {
	return ([[HONUserAssistant sharedInstance] avatarURLForUserID:self.creatorID]);
}

- (NSString *)toString {
	NSMutableString *string = [NSMutableString stringWithFormat:@".identifier		: %@", self.identifier];
	[string appendFormat:@".identifierSuffix	: %@", self.identifierSuffix];
	[string appendFormat:@".creatorID		: %d", self.creatorID];
	[string appendFormat:@".creatorName			: %@", self.creatorName];
	[string appendFormat:@".creatorAvatarPrefix	: %@", self.creatorAvatarPrefix];
	[string appendFormat:@".participants	: %@", self.participants];
	[string appendFormat:@".lastMessage		: %@", self.lastMessage];
	[string appendFormat:@".hasUnreadMessages	: %@", NSStringFromBOOL(self.hasUnreadMessages)];
	[string appendFormat:@".isDeleted		: %@", NSStringFromBOOL(self.isDeleted)];
	[string appendFormat:@".createdAt		: %@", [self.createdAt formattedISO8601StringUTC]];
	[string appendFormat:@".metadata		: %@", self.metadata];
	
	return (string);
}

@end


@implementation LYRMessage (Additions)

- (NSString *)identifierSuffix {
	return ([[self.identifier.absoluteString componentsSeparatedByString:@"/"] lastObject]);
}

- (int)creatorID {
	return ([self.sentByUserID intValue]);
}

- (NSString *)creatorName {
	return ([[HONUserAssistant sharedInstance] usernameForUserID:[self.sentByUserID intValue]]);
}


- (NSString *)creatorAvatarPrefix {
	return ([[HONUserAssistant sharedInstance] avatarURLForUserID:[self.sentByUserID intValue]]);
}

- (NSString *)toString {
	NSMutableString *string = [NSMutableString stringWithFormat:@".identifier		: %@", self.identifier];
	[string appendFormat:@".identifierSuffix	: %@", self.identifierSuffix];
	[string appendFormat:@".conversation		: %@", self.conversation.identifierSuffix];
	[string appendFormat:@".creatorID			: %d", self.creatorID];
	[string appendFormat:@".creatorName			: %@", self.creatorName];
	[string appendFormat:@".creatorAvatarPrefix		: %@", self.creatorAvatarPrefix];
	[string appendFormat:@".index			: %d", self.index];
	[string appendFormat:@".parts			: %@", self.parts];
	[string appendFormat:@".isSent			: %@", NSStringFromBOOL(self.isSent)];
	[string appendFormat:@".isUnread		: %@", NSStringFromBOOL(self.isUnread)];
	[string appendFormat:@".isDeleted		: %@", NSStringFromBOOL(self.isDeleted)];
	[string appendFormat:@".sentAt			: %@", [self.sentAt formattedISO8601StringUTC]];
	[string appendFormat:@".receivedAt		: %@", [self.receivedAt formattedISO8601StringUTC]];
	[string appendFormat:@".recipientStatusByUserID		: %@", self.recipientStatusByUserID];
	
	return (string);
}

@end
//
//  LYRConversation+Additions.h
//  HotOrNot
//
//  Created by BIM  on 1/23/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import <LayerKit/LayerKit.h>

@interface LYRConversation (Additions)
- (NSString *)identifierSuffix;
- (int)creatorID;
- (NSString *)creatorName;
- (NSString *)creatorAvatarPrefix;
- (NSString *)toString;
@end

@interface LYRMessage (Additions)
- (NSString *)identifierSuffix;
- (NSString *)toString;
@end
//
//  LYRConversation+Additions.m
//  HotOrNot
//
//  Created by BIM  on 1/23/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"

#import "LYRConversation+Additions.h"

@implementation LYRConversation (Additions)

- (NSString *)identifierSuffix {
	return ([[self.identifier.absoluteString componentsSeparatedByString:@"/"] lastObject]);
}

- (int)creatorID {
	return (([self.metadata objectForKey:@"creator_id"] != nil) ? [[self.metadata objectForKey:@"creator_id"] intValue] : 0);
}

- (NSString *)creatorName {
	return (([self.metadata objectForKey:@"creator_name"] != nil) ? [self.metadata objectForKey:@"creator_name"] : [[HONUserAssistant sharedInstance] usernameForUserID:self.creatorID]);
}

- (NSString *)creatorAvatarPrefix {
	return ([[HONUserAssistant sharedInstance] avatarURLForUserID:self.creatorID]);
}

- (NSString *)toString {
	NSMutableString *string = [NSMutableString stringWithFormat:@".identifier		: %@", self.identifier];
	[string appendFormat:@".identifierSuffix	: %@", self.identifierSuffix];
	[string appendFormat:@".creatorID		: %d", self.creatorID];
	[string appendFormat:@".creatorName			: %@", self.creatorName];
	[string appendFormat:@".creatorAvatarPrefix	: %@", self.creatorAvatarPrefix];
	[string appendFormat:@".participants	: %@", self.participants];
	[string appendFormat:@".lastMessage		: %@", self.lastMessage];
	[string appendFormat:@".hasUnreadMessages	: %@", NSStringFromBOOL(self.hasUnreadMessages)];
	[string appendFormat:@".isDeleted		: %@", NSStringFromBOOL(self.isDeleted)];
	[string appendFormat:@".createdAt		: %@", [self.createdAt formattedISO8601StringUTC]];
	[string appendFormat:@".metadata		: %@", self.metadata];
	
	return (string);
}

@end


@implementation LYRMessage (Additions)

- (NSString *)identifierSuffix {
	return ([[self.identifier.absoluteString componentsSeparatedByString:@"/"] lastObject]);
}

- (int)creatorID {
	return ([self.sentByUserID intValue]);
}

- (NSString *)creatorName {
	return ([[HONUserAssistant sharedInstance] usernameForUserID:[self.sentByUserID intValue]]);
}


- (NSString *)creatorAvatarPrefix {
	return ([[HONUserAssistant sharedInstance] avatarURLForUserID:[self.sentByUserID intValue]]);
}

- (NSString *)toString {
	NSMutableString *string = [NSMutableString stringWithFormat:@".identifier		: %@", self.identifier];
	[string appendFormat:@".identifierSuffix	: %@", self.identifierSuffix];
	[string appendFormat:@".conversation		: %@", self.conversation.identifierSuffix];
	[string appendFormat:@".creatorID			: %d", self.creatorID];
	[string appendFormat:@".creatorName			: %@", self.creatorName];
	[string appendFormat:@".creatorAvatarPrefix		: %@", self.creatorAvatarPrefix];
	[string appendFormat:@".index			: %d", self.index];
	[string appendFormat:@".parts			: %@", self.parts];
	[string appendFormat:@".isSent			: %@", NSStringFromBOOL(self.isSent)];
	[string appendFormat:@".isUnread		: %@", NSStringFromBOOL(self.isUnread)];
	[string appendFormat:@".isDeleted		: %@", NSStringFromBOOL(self.isDeleted)];
	[string appendFormat:@".sentAt			: %@", [self.sentAt formattedISO8601StringUTC]];
	[string appendFormat:@".receivedAt		: %@", [self.receivedAt formattedISO8601StringUTC]];
	[string appendFormat:@".recipientStatusByUserID		: %@", self.recipientStatusByUserID];
	
	return (string);
}

@end
