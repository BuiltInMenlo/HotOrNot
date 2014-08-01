//
//  HONUserClubVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 02/24/2014 @ 14:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


typedef NS_ENUM(NSInteger, HONClubEnrollmentType) {
	HONClubEnrollmentTypeUndetermined = 0,
	HONClubEnrollmentTypeOwner,
	HONClubEnrollmentTypeMember,
	HONClubEnrollmentTypePending,
	HONClubEnrollmentTypeBanned,
	HONClubEnrollmentTypeCreate,
	HONClubEnrollmentTypeSuggested,
	HONClubEnrollmentTypeHighSchool,
	HONClubEnrollmentTypeThreshold,
	HONClubEnrollmentTypeUnknown,
	HONClubembershipType__TOTAL
};


@interface HONUserClubVO : NSObject
+ (HONUserClubVO *)clubWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic) int clubID;
@property (nonatomic, assign) HONClubEnrollmentType clubEnrollmentType;
@property (nonatomic, retain) NSString *clubName;
@property (nonatomic, retain) NSString *coverImagePrefix;
@property (nonatomic, retain) NSString *blurb;
@property (nonatomic, retain) NSDate *addedDate;
@property (nonatomic, retain) NSDate *updatedDate;

@property (nonatomic) int ownerID;
@property (nonatomic, retain) NSString *ownerName;
@property (nonatomic, retain) NSString *ownerImagePrefix;

@property (nonatomic, retain) NSArray *activeMembers;
@property (nonatomic, retain) NSArray *pendingMembers;
@property (nonatomic, retain) NSArray *bannedMembers;

@property (nonatomic, retain) NSArray *submissions;
@property (nonatomic) int totalScore;
@end
