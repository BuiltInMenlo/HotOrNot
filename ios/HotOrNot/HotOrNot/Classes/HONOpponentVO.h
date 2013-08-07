//
//  HONOpponentVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/6/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HONOpponentVO : NSObject
+ (HONOpponentVO *)opponentWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic) int userID;
@property (nonatomic, retain) NSString *fbID;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *avatarURL;
@property (nonatomic, retain) NSString *imagePrefix;
@property (nonatomic, retain) NSDate *joinedDate;
@property (nonatomic) int score;
@end
