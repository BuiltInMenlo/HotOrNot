//
//  HONEmotionVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 10/26/13 @ 4:53 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

@interface HONEmotionVO : NSObject
+ (HONEmotionVO *)emotionWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic, retain) NSString *emotionID;
@property (nonatomic, retain) NSString *emotionName;
@property (nonatomic, retain) NSString *largeImageURL;
@property (nonatomic, retain) NSString *mediumImageURL;
@property (nonatomic, retain) NSString *smallImageURL;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic) CGFloat price;
@property (nonatomic) BOOL isFree;
@end
