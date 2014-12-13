//
//  HONBaseVO.h
//  HotOrNot
//
//  Created by BIM  on 12/12/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


@interface HONBaseVO : NSObject
- (NSString *)toString;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic, retain) NSString *formattedProperties;
@end
