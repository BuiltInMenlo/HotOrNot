//
//  PicoUserDefaults.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 2/12/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PicoUserDefaults : NSObject

/**
 * Shared instance of PicoUserDefaults
 * @return Returns shared instance of PicoUserDefaults
 */
+(PicoUserDefaults *)shared;

-(NSArray *)savedUDIDs;

-(NSString *)activeUDID;

-(BOOL)setActiveUDID:(NSString *)udid;

-(BOOL)addActiveUDID:(NSString *)udid;

/**
 * Synchronizes with file stored in local file system
 * @return Returns YES if synchronization is successful
 */
-(BOOL)synchronize;

@end
