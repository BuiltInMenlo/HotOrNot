//
//  TalkChainCredentials.h
//  TalkChain
//
//  Created by Charles Chase on 12/8/14.
//  Copyright (c) 2014 AFTY, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TalkChainCredentials : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;

+ (instancetype)new;

/*
    Validate Credentials
 
    All credentials are optional and will only be validated if provided.
 
    Username must be at least 3 characters. Valid characters include letters, numbers and underscore.
    Password must be at least 5 characters.
 
 */

- (BOOL)areValid;

@end
