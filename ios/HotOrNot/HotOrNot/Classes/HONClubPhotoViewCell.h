//
//  HONClubPhotoViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 06/14/2014 @ 21:59 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONClubPhotoVO.h"

@class HONClubPhotoViewCell;
@protocol HONClubPhotoViewCellDelegate <NSObject>
- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell showUserProfileForClubPhoto:(HONClubPhotoVO *)clubPhotoVO;
- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell replyToPhoto:(HONClubPhotoVO *)clubPhotoVO;
- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell upvotePhoto:(HONClubPhotoVO *)clubPhotoVO;
- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell advancePhoto:(HONClubPhotoVO *)clubPhotoVO;
@end

@interface HONClubPhotoViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, retain) HONClubPhotoVO *clubPhotoVO;
@property (nonatomic, retain) NSString *clubName;
@property (nonatomic, assign) id <HONClubPhotoViewCellDelegate> delegate;
@end
