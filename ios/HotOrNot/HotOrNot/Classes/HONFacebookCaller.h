//
//  HONFacebookCaller.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.22.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <FacebookSDK/FacebookSDK.h>
#import "Facebook.h"

#import "HONChallengeVO.h"

@interface HONFacebookCaller : NSObject

@property (strong, nonatomic) Facebook *facebook;

+ (void)postToActivity:(HONChallengeVO *)vo withAction:(NSString *)action;
+ (void)postStatus:(NSString *)msg;
+ (void)postToTimeline:(HONChallengeVO *)vo;
+ (void)postToTicker:(NSString *)msg;
+ (void)postToFriendTimeline:(NSString *)fbID article:(HONChallengeVO *)vo;
+ (void)postMessageToFriendTimeline:(NSString *)fbID message:(NSString *)msg;
+ (void)sendAppRequest:(NSString *)fbID;

@end
