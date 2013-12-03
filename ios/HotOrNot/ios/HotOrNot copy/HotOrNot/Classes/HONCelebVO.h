//
//  HONCelebVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 7/8/13 @ 4:05 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HONCelebVO : NSObject
+ (HONCelebVO *)celebWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int userID;
@property (nonatomic, retain) NSString *fullName;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *avatarURL;
@end
