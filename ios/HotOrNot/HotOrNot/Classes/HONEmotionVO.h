//
//  HONEmotionVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 10/26/13 @ 4:53 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HONEmotionVO : NSObject
+ (HONEmotionVO *)emotionWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int emotionID;
@property (nonatomic, retain) NSString *emotionName;
@property (nonatomic, retain) NSString *hastagName;
@property (nonatomic, retain) NSString *imagePrefix;
@property (nonatomic, retain) NSString *imageLargeURL;
@property (nonatomic, retain) NSString *imageSmallURL;
@property (nonatomic) CGFloat price;
@property (nonatomic) BOOL isFree;
@end