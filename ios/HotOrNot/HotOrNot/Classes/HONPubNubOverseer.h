//
//  HONPubNubOverseer.h
//  HotOrNot
//
//  Created by BIM  on 3/18/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "PNImports.h"

#import "HONStatusUpdateVO.h"


@interface HONPubNubOverseer : NSObject
+ (HONPubNubOverseer *)sharedInstance;

- (void)activateService;
- (PNChannel *)channelForStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO;
- (void)statusUpdateForChannel:(PNChannel *)channel withCompletion:(void (^)(id))completion;
@end
