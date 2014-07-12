//
//  HONCountryVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 07/09/2014 @ 15:55 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

@interface HONCountryVO : NSObject
+ (HONCountryVO *)countryWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic, retain) NSString *countryName;
@property (nonatomic, retain) NSString *countryCode;
@property (nonatomic, retain) NSString *callingCode;
@end
