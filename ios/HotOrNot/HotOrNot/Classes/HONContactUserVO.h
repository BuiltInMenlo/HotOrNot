//
//  HONContactUserVO.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.26.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

@interface HONContactUserVO : NSObject
+ (HONContactUserVO *)contactWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *fullName;
@property (nonatomic, retain) NSString *rawNumber;
@property (nonatomic, retain) NSString *mobileNumber;
@property (nonatomic, retain) NSString *email;

@property (nonatomic) BOOL isSMSAvailable;
@end
