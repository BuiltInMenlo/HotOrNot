//
//  HONCommentVO.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 02.20.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONClubPhotoVO.h"

@interface HONCommentVO : NSObject
+ (HONCommentVO *)commentWithDictionary:(NSDictionary *)dictionary;
+ (HONCommentVO *)commentWithClubPhoto:(HONClubPhotoVO *)clubPhotoVO;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic) int commentID;
@property (nonatomic) int parentID;
@property (nonatomic) int userID;
@property (nonatomic, retain) NSString *username;
@property (nonatomic) int score;
@property (nonatomic, retain) NSString *textContent;
@property (nonatomic, retain) NSDate *addedDate;
@end
