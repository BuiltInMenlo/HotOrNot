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
@optional
- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell replyToPhoto:(HONClubPhotoVO *)clubPhotoVO withComment:(NSString *)comment;
- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell upVotePhoto:(HONClubPhotoVO *)clubPhotoVO;
- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell downVotePhoto:(HONClubPhotoVO *)clubPhotoVO;
- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell hideCommentsForPhoto:(HONClubPhotoVO *)clubPhotoVO;
- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell showCommentsForPhoto:(HONClubPhotoVO *)clubPhotoVO;
@end

@interface HONClubPhotoViewCell : HONTableViewCell <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, retain) HONUserClubVO *clubVO;
@property (nonatomic, retain) HONClubPhotoVO *clubPhotoVO;
@property (nonatomic, assign) id <HONClubPhotoViewCellDelegate> delegate;
@end
