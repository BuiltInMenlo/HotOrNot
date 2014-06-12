//
//  HONUserClubVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 02/24/2014 @ 14:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

typedef NS_ENUM(NSInteger, HONClubType) {
	HONClubTypeOwner = 0,
	HONClubTypeMember,
	HONClubTypePending,
	HONClubTypeOther,
	HONClubTypeUnknown
};


@interface HONUserClubVO : NSObject
+ (HONUserClubVO *)clubWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic) int clubID;
@property (nonatomic, assign, readonly) HONClubType clubType;
@property (nonatomic) int totalPendingMembers;
@property (nonatomic) int totalActiveMembers;
@property (nonatomic) int totalBannedMembers;
@property (nonatomic, retain) NSString *clubName;
@property (nonatomic, retain) NSString *coverImagePrefix;
@property (nonatomic, retain) NSString *blurb;
@property (nonatomic, retain) NSDate *addedDate;
@property (nonatomic, retain) NSDate *updatedDate;

@property (nonatomic) int ownerID;
@property (nonatomic, retain) NSString *ownerName;
@property (nonatomic, retain) NSString *ownerImagePrefix;

@property (nonatomic, retain) NSArray *submissions;
@property (nonatomic) int totalSubmissions;
@end
