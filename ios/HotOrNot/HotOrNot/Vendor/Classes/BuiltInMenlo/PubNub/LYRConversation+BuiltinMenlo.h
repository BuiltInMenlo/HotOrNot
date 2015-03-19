//
//  LYRConversation+Additions.h
//  HotOrNot
//
//  Created by BIM  on 1/23/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import <LayerKit/LayerKit.h>

typedef NS_ENUM (NSUInteger, HONMessageType) {
	HONMessageTypeText = 0,
	HONMessageTypeImage = 1,
	HONMessageTypeOther
};

@interface LYRConversation (BuiltInMenlo)
- (NSString *)identifierSuffix;
- (int)creatorID;
- (NSString *)creatorName;
- (NSString *)creatorAvatarPrefix;
- (NSString *)toString;
@end

@interface LYRMessage (BuiltInMenlo)
- (NSString *)identifierSuffix;
- (NSString *)creatorName;
- (NSString *)creatorAvatarPrefix;
- (int)creatorID;
- (NSString *)toString;
@end

@interface LYRMessagePart (BuiltInMenlo)
- (NSString *)textContent;
- (UIImage *)imageContent;
- (NSString *)dbIdentifier;
- (NSString *)toString;
@end
