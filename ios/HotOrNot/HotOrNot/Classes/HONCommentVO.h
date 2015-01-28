//
//  HONCommentVO.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 02.20.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <LayerKit/LayerKit.h>

#import "HONClubPhotoVO.h"


typedef NS_ENUM(NSUInteger, HONCommentStatusType) {
	HONCommentStatusTypeUnknown = 0,
	HONCommentStatusTypeSent,
	HONCommentStatusTypeDelivered,
	HONCommentStatusTypeSeen,
	HONCommentStatusTypeDeleted
};


@interface HONCommentVO : NSObject
+ (HONCommentVO *)commentWithDictionary:(NSDictionary *)dictionary;
+ (HONCommentVO *)commentWithClubPhoto:(HONClubPhotoVO *)clubPhotoVO;
+ (HONCommentVO *)commentWithMessage:(LYRMessage *)message;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic) int commentID;
@property (nonatomic) HONCommentStatusType commentStatusType;
@property (nonatomic, retain) NSString *messageID;
@property (nonatomic) int parentID;
@property (nonatomic) int clubID;
@property (nonatomic) int userID;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *avatarPrefix;
@property (nonatomic) int score;
@property (nonatomic, retain) NSString *textContent;
@property (nonatomic, retain) UIImage *imageContent;
@property (nonatomic, retain) NSDate *addedDate;
@end
