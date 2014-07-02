//
//  PCCandyStoreEventDataController.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 6/12/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCCandyStoreEvent.h"

typedef enum {
    kCandyStoreEventDataControllerUnknownEvent,
    kCandyStoreEventDataControllerMainEvent,
    kCandyStoreEventDataControllerMiniEvent
} kCandyStoreEventDataControllerEventType;

@protocol PCCandyStoreEventDataControllerDelegate <NSObject>

-(void)candyStoreEventDataController:(id)controller fetchedBanners:(PCCandyStoreEvent *)event forEvent:(kCandyStoreEventDataControllerEventType)eventType;
-(void)candyStoreEventDataController:(id)controller failedToFetchBannersForEvent:(kCandyStoreEventDataControllerEventType)eventType;

@end

@interface PCCandyStoreEventDataController : NSObject

@property (nonatomic, strong) id<PCCandyStoreEventDataControllerDelegate> delegate;

-(void)fetchBannersForMainEvents;

-(void)fetchBannersForMiniEvents;

@end
