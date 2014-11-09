//
//  HONClubPhotoViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 06/14/2014 @ 21:59 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"
#import "HONUserClubVO.h"
#import "HONClubPhotoVO.h"

@class HONClubPhotoViewCell;
@protocol HONClubPhotoViewCellDelegate <NSObject>
- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell showUserProfileForClubPhoto:(HONClubPhotoVO *)clubPhotoVO;
- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell replyToPhoto:(HONClubPhotoVO *)clubPhotoVO;
- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell upvotePhoto:(HONClubPhotoVO *)clubPhotoVO;
- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell downVotePhoto:(HONClubPhotoVO *)clubPhotoVO;
- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell advancePhoto:(HONClubPhotoVO *)clubPhotoVO;
@end

@interface HONClubPhotoViewCell : HONTableViewCell <UIScrollViewDelegate>
+ (NSString *)cellReuseIdentifier;

- (void)toggleImageLoading:(BOOL)isLoading;
- (void)destroy;

@property (nonatomic, retain) HONUserClubVO *clubVO;
@property (nonatomic, retain) HONClubPhotoVO *clubPhotoVO;
@property (nonatomic, assign) id <HONClubPhotoViewCellDelegate> delegate;
@end
