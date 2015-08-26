//
//  HONPubNubOverseer.h
//  HotOrNot
//
//  Created by BIM  on 3/18/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import <PubNub/PubNub.h>


@interface HONPubNubOverseer : NSObject
+ (HONPubNubOverseer *)sharedInstance;

- (void)activateService;
@end
