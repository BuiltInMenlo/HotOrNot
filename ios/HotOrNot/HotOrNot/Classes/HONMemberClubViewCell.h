//
//  HONMemberClubViewCell.h
//  HotOrNot
//
//  Created by BIM  on 9/12/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"

typedef NS_ENUM(NSInteger, HONClubViewCellType) {
	HONClubViewCellTypeCreate = 0,
	HONClubViewCellTypeUserSignup,
	HONClubViewCellTypeOwner,
	HONClubViewCellTypeMember,
	HONClubViewCellTypeInvite
};

@interface HONMemberClubViewCell : HONTableViewCell

@end
