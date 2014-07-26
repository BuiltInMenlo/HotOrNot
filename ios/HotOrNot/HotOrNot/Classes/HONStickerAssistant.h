//
//  HONStickerAssistant.h
//  HotOrNot
//
//  Created by Matt Holcombe on 07/26/2014 @ 13:50 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "PicoManager.h"
#import "PCCandyStoreSearchController.h"


@interface HONStickerAssistant : NSObject
+ (HONStickerAssistant *)sharedInstance;

- (void)registerStickerStore;
- (void)retrieveStickersWithContentGroupIDs:(NSArray *)contentGroupIDs completion:(void (^)(id result))completion;
@end
