//
//  HONPopularUserVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 9/25/13 @ 6:09 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HONPopularUserVO : NSObject
+ (HONPopularUserVO *)userWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int userID;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *avatarPrefix;
@end
