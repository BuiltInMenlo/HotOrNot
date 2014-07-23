//
//  CandyBoxClient.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 8/11/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PicoHTTPClient.h"

@interface CandyBoxClient : PicoHTTPClient

+(CandyBoxClient *)sharedClient;

-(void)markContentAsUsed:(NSString *)contentId
           asPartOfGroup:(NSString *)contentGroupId
                 success:(void (^)(NSString *contentId, NSString *contentGroupId))success
                    fail:(void (^)(NSString *contentId, NSString *contentGroupId))fail;

-(void)markContentAsFavorite:(NSString *)contentId
                     success:(void (^)(NSString *contentId))success
                        fail:(void (^)(NSString *contentId))fail;
@end
