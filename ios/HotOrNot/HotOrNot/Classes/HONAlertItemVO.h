//
//  HONAlertItemVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 12/02/2013 @ 20:41 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

@interface HONAlertItemVO : NSObject
+ (HONAlertItemVO *)alertWithDictionary:(NSDictionary *)dictionary;
@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic, retain) NSString *alertID;
@property (nonatomic) int userID;
@property (nonatomic) int challengeID;
@property (nonatomic) HONPushTriggerType triggerType;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *avatarPrefix;
@property (nonatomic, retain) NSDate *sentDate;

@end
