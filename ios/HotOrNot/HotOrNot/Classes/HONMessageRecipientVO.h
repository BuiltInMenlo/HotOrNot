//
//  HONMessageRecipientVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 01/22/2014 @ 14:53.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HONMessageRecipientVO : NSObject
+ (HONMessageRecipientVO *)recipientWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int userID;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *avatarPrefix;
@end
