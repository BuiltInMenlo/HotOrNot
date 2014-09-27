//
//  HONClubViewCell.h
//  HotOrNot
//
//  Created by BIM  on 8/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

//#import "HONTableViewCell.h"
#import "HONToggleViewCell.h"
#import "HONUserClubVO.h"

typedef NS_ENUM(NSInteger, HONClubViewCellType) {
	HONClubViewCellTypeBlank = 0,
	HONClubViewCellTypeDeviceContact,
	HONClubViewCellTypeInAppUser,
	HONClubViewCellTypeCreate,
	HONClubViewCellTypeUserSignup,
	HONClubViewCellTypeOwner,
	HONClubViewCellTypeMember,
	HONClubViewCellTypeInvite
};

@class HONClubViewCell;
@protocol HONClubViewCellDelegate <HONToggleViewCellDelegate>
@optional
- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectClub:(HONUserClubVO *)clubVO;
- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectContactUser:(HONContactUserVO *)contactUserVO;
- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectTrivialUser:(HONTrivialUserVO *)trivialUserVO;
@end

@interface HONClubViewCell : HONToggleViewCell
+ (NSString *)cellReuseIdentifier;
- (id)initAsCellType:(HONClubViewCellType)cellType;
- (void)toggleUI:(BOOL)isEnabled;
- (void)toggleImageLoading:(BOOL)isLoading;
- (void)hideTimeStat;

@property (nonatomic, retain) HONContactUserVO *contactUserVO;
@property (nonatomic, retain) HONTrivialUserVO *trivialUserVO;
@property (nonatomic, retain) HONUserClubVO *clubVO;
@property (nonatomic, assign) HONClubViewCellType cellType;
@property (nonatomic, assign) id <HONClubViewCellDelegate> delegate;
@end
