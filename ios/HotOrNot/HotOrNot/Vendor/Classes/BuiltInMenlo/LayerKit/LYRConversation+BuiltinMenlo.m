//
//  LYRConversation+Additions.m
//  HotOrNot
//
//  Created by BIM  on 1/23/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+BuiltInMenlo.h"
#import "NSString+BuiltinMenlo.h"

#import "LYRConversation+BuiltInMenlo.h"

@implementation LYRConversation (BuiltInMenlo)

- (NSString *)identifierSuffix {
	return ([self.identifier.absoluteString lastComponentByDelimeter:@"/"]);
}

- (int)creatorID {
	return (([self.metadata objectForKey:@"creator_id"] != nil) ? [[self.metadata objectForKey:@"creator_id"] intValue] : 0);
}

- (NSString *)creatorName {
	return (([self.metadata objectForKey:@"creator_name"] != nil) ? [self.metadata objectForKey:@"creator_name"] : @"");
}

- (NSString *)creatorAvatarPrefix {
	return ([[HONUserAssistant sharedInstance] avatarURLForUserID:self.creatorID]);
}

- (NSString *)toString {
	NSMutableString *string = [NSMutableString stringWithFormat:@"\n.identifier		: %@", self.identifier];
	[string appendFormat:@"\n.identifierSuffix	: %@", self.identifierSuffix];
	[string appendFormat:@"\n.creatorID		: %d", self.creatorID];
	[string appendFormat:@"\n.creatorName			: %@", self.creatorName];
	[string appendFormat:@"\n.creatorAvatarPrefix	: %@", self.creatorAvatarPrefix];
	[string appendFormat:@"\n.participants	: %@", self.participants];
	[string appendFormat:@"\n.lastMessage		: %@", self.lastMessage];
	[string appendFormat:@"\n.hasUnreadMessages	: %@", NSStringFromBOOL(self.hasUnreadMessages)];
	[string appendFormat:@"\n.isDeleted		: %@", NSStringFromBOOL(self.isDeleted)];
	[string appendFormat:@"\n.createdAt		: %@", [self.createdAt formattedISO8601StringUTC]];
	[string appendFormat:@"\n.metadata		: %@", self.metadata];
	
	return (string);
}

@end


@implementation LYRMessage (BuiltInMenlo)

- (NSString *)identifierSuffix {
	return ([self.identifier.absoluteString lastComponentByDelimeter:@"/"]);
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
	NSMutableString *string = [NSMutableString stringWithFormat:@"\n.identifier		: %@", self.identifier];
	[string appendFormat:@"\n.identifierSuffix	: %@", self.identifierSuffix];
	[string appendFormat:@"\n.conversation		: %@", self.conversation.identifierSuffix];
	[string appendFormat:@"\n.creatorID			: %d", self.creatorID];
	[string appendFormat:@"\n.creatorName			: %@", self.creatorName];
	[string appendFormat:@"\n.creatorAvatarPrefix		: %@", self.creatorAvatarPrefix];
	[string appendFormat:@"\n.sentByUserID	: %@", self.sentByUserID];
	[string appendFormat:@"\n.index			: %d", (int)self.index];
	[string appendFormat:@"\n.parts			: %@", self.parts];
	[string appendFormat:@"\n.isSent			: %@", NSStringFromBOOL(self.isSent)];
	[string appendFormat:@"\n.isUnread		: %@", NSStringFromBOOL(self.isUnread)];
	[string appendFormat:@"\n.isDeleted		: %@", NSStringFromBOOL(self.isDeleted)];
	[string appendFormat:@"\n.sentAt			: %@", [self.sentAt formattedISO8601StringUTC]];
	[string appendFormat:@"\n.receivedAt		: %@", [self.receivedAt formattedISO8601StringUTC]];
	[string appendFormat:@"\n.recipientStatusByUserID		: %@", self.recipientStatusByUserID];
	
	return (string);
}

@end



@implementation LYRMessagePart (BuiltInMenlo)
- (NSString *)textContent {
	return (([self.MIMEType isEqualToString:kMIMETypeTextPlain]) ? [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding] : @"");
}

- (UIImage *)imageContent {
	return (([self.MIMEType isEqualToString:kMIMETypeImagePNG]) ? [UIImage imageWithData:self.data] : nil);
}

- (NSString *)dbIdentifier {
	NSError *error = nil;
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.JSONData options:0 error:&error];
	
	return ([dict objectForKey:@"databaseIdentifier"]);
}

- (NSString *)toString {
	NSMutableString *string = [NSMutableString stringWithFormat:@"\n.MIMEType		: %@", self.MIMEType];
	[string appendFormat:@"\n.data		: %@", self.data];
	[string appendFormat:@"\n.textContent	: %@", self.textContent];
	[string appendFormat:@"\n.imageContent	: %@", self.imageContent];
	[string appendFormat:@"\n.JSONString	: %@", self.JSONString];
	
	return (string);
}

@end

