//
//  HONUserClubVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 02/24/2014 @ 14:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


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
@property (nonatomic) HONUserClubStatusType userClubStatusType;
@property (nonatomic) HONUserClubExpoType userClubExpoType;
@property (nonatomic) HONUserClubContentType userClubConentType;
@property (nonatomic) int totalPendingMembers;
@property (nonatomic) int totalActiveMembers;
@property (nonatomic) int totalBannedMembers;
@property (nonatomic) int totalHistoricMembers;
@property (nonatomic) int totalAllMembers;
@property (nonatomic) int totalEntries;
@property (nonatomic) CGFloat actionsPerMinute;
@property (nonatomic, retain) NSString *clubName;
@property (nonatomic, retain) NSString *coverImagePrefix;
@property (nonatomic, retain) NSString *emotionName;
@property (nonatomic, retain) NSString *hastagName;

@property (nonatomic) int creatorID;
@property (nonatomic, retain) NSString *creatorName;
@property (nonatomic, retain) NSString *creatorImagePrefix;
@property (nonatomic, retain) NSDate *creatorBirthdate;

@property (nonatomic, retain) NSDate *addedDate;
@property (nonatomic, retain) NSDate *startedDate;
@property (nonatomic, retain) NSDate *updatedDate;

@end
