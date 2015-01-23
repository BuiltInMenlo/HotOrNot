//
//  LYRConversation+Additions.m
//  HotOrNot
//
//  Created by BIM  on 1/23/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "LYRConversation+Additions.h"

@implementation LYRConversation (Additions)

- (NSString *)identifierSuffix {
	return ([[self.identifier.absoluteString componentsSeparatedByString:@"/"] lastObject]);
}

@end


@implementation LYRMessage (Additions)

- (NSString *)identifierSuffix {
	return ([[self.identifier.absoluteString componentsSeparatedByString:@"/"] lastObject]);
}

@end
