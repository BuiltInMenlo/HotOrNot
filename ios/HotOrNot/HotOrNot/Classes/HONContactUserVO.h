//
//  HONContactUserVO.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.26.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


typedef NS_ENUM(NSUInteger, HONContactType) {
	HONContactTypeUnmatched = 0,
	HONContactTypeMatched
};

@interface HONContactUserVO : NSObject
+ (HONContactUserVO *)contactWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *fullName;
@property (nonatomic, retain) NSString *rawNumber;
@property (nonatomic, retain) NSString *mobileNumber;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSData *avatarData;
@property (nonatomic, retain) UIImage *avatarImage;
@property (nonatomic) BOOL isSMSAvailable;
@property (nonatomic, assign) HONContactType contactType;

@property (nonatomic) int userID;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *avatarPrefix;
@property (nonatomic, retain) NSDate *invitedDate;

@end
