//
//  HONPopularUserVO.h
//  HotOrNot
//
//  Created by Sparkle Mountain iMac on 9/18/12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HONPopularUserVO : NSObject

+ (HONPopularUserVO *)userWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int userID;
@property (nonatomic) int points;
@property (nonatomic) int votes;
@property (nonatomic) int pokes;
@property (nonatomic) int score;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *imageURL;

@end
