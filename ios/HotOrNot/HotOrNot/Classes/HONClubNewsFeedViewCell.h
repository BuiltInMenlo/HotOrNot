//
//  HONClubTimelineViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/25/2014 @ 11:00 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONClubPhotoVO.h"
#import "HONUserClubVO.h"


typedef NS_ENUM(NSInteger, HONClubNewsFeedCellType) {
	HONClubNewsFeedCellTypePhotoSubmission = 0,
	HONClubNewsFeedCellTypeNonMember
};

@class HONClubNewsFeedViewCell;
@protocol HONClubNewsFeedViewCellDelegate <NSObject>
- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell createClubWithProtoVO:(HONUserClubVO *)userClubVO;
@optional
- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell joinThresholdClub:(HONUserClubVO *)userClubVO;
- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell enterTimelineForClub:(HONUserClubVO *)userClubVO;
- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell joinClub:(HONUserClubVO *)userClubVO;
- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell replyToClubPhoto:(HONUserClubVO *)userClubVO;
- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell upvoteClubPhoto:(HONClubPhotoVO *)clubPhotoVO;
- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell showUserProfileForClubPhoto:(HONClubPhotoVO *)clubPhotoVO;
@end

@interface HONClubNewsFeedViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)toggleImageLoading:(BOOL)isLoading;

@property (nonatomic, retain) HONUserClubVO *clubVO;
@property (nonatomic, retain) HONClubPhotoVO *clubPhotoVO;
@property (nonatomic) int clubPhotoIndex;
@property (nonatomic, assign) id <HONClubNewsFeedViewCellDelegate> delegate;
@end
