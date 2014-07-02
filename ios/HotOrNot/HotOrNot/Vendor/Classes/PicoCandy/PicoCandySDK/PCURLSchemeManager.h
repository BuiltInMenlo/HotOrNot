//
//  PCURLSchemeManager.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 11/12/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kPCURLSchemeManagerURLUnknownSource,
    kPCURLSchemeManagerURLInternalSource,
    kPCURLSchemeManagerURLExternalSource
} kPCURLSchemeManagerURLSourceType;

typedef enum {
    kPCURLSchemeManagerUnknownDestination,
    kPCURLSchemeManagerDestinationCandyStore,
    kPCURLSchemeManagerDestinationCandyBox
} kPCURLSchemeManagerIntendedDestination;

@protocol PCURLSchemeManagerDelegate <NSObject>

-(void)urlSchemeManager:(id)manager receivedURL:(NSURL *)url source:(kPCURLSchemeManagerURLSourceType)type
    intendedDestination:(kPCURLSchemeManagerIntendedDestination)dest requiredAction:(NSString *)action
                  param:(NSString *)param query:(NSDictionary *)query;

@end

@interface PCURLSchemeManager : NSObject

@property (nonatomic, strong) id<PCURLSchemeManagerDelegate> delegate;
@property (nonatomic, strong) NSString *appId;

+(PCURLSchemeManager *)sharedManager;

-(void)processCustomURL:(NSURL *)url;

@end
