//
//  PCContentManager.h
//  PicoCandySDK
//
//  Created by khangtoh on 17/12/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CandyBox.h"

typedef void (^PCContentManagerLookupBlock)(CandyBoxContent *content);

@interface PCContentManager : NSObject

+(PCContentManager *)sharedManager;

+(NSURL *)lookupLocalURLUsingRemoteURL:(NSURL *)url;

+(NSURL *)lookupremoteURLUsingLocalURL:(NSURL *)localURL;

+(NSURL *)createContentWithURL:(NSURL *)url;


@end
