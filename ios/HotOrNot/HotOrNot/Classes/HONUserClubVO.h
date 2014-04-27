//
//  HONUserClubVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 02/24/2014 @ 14:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

typedef enum {
	HONUserClubStatusTypePending = 0,
	HONUserClubStatusTypeActive,
	HONUserClubStatusTypeBanned,
	HONUserClubStatusTypeRemoved
} HONUserClubStatusType;


typedef enum {
	HONUserClubExpoTypePublic = 0,
	HONUserClubExpoTypePrivate
} HONUserClubExpoType;

typedef enum {
	HONUserClubContentTypeSelfieclub = 0,
	HONUserClubContentTypeCommunity,
	HONUserClubContentTypeCampaign
} HONUserClubContentType;


@interface HONUserClubVO : NSObject
+ (HONUserClubVO *)clubWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic) int clubID;
@property (nonatomic, assign, readonly) HONUserClubStatusType userClubStatusType;
@property (nonatomic, assign, readonly) HONUserClubExpoType userClubExpoType;
@property (nonatomic, assign, readonly) HONUserClubContentType userClubConentType;
@property (nonatomic) int totalPendingMembers;
@property (nonatomic) int totalActiveMembers;
@property (nonatomic) int totalBannedMembers;
@property (nonatomic) int totalHistoricMembers;
@property (nonatomic) int totalAllMembers;
@property (nonatomic) int totalEntries;
@property (nonatomic) CGFloat actionsPerMinute;
@property (nonatomic, retain) NSString *clubName;
@property (nonatomic, retain) NSString *coverImagePrefix;
@property (nonatomic, retain) NSString *blurb;

@property (nonatomic) int ownerID;
@property (nonatomic, retain) NSString *ownerName;
@property (nonatomic, retain) NSString *ownerImagePrefix;
@property (nonatomic, retain) NSDate *ownerBirthdate;

@property (nonatomic, retain) NSDate *addedDate;
@property (nonatomic, retain) NSDate *updatedDate;

@end
