//
//  HONBaseAvatarViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 11/5/13 @ 9:56 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONBaseRowViewCell.h"
#import "HONTrivialUserVO.h"

@class HONBaseAvatarViewCell;
@protocol HONBaseAvatarViewCellDelegate <NSObject>
- (void)avatarViewCell:(HONBaseAvatarViewCell *)viewCell showProfileForUser:(HONTrivialUserVO *)vo;
@end

@interface HONBaseAvatarViewCell : HONBaseRowViewCell {
	UIImageView *_avatarImageView;
	UILabel *_nameLabel;
}

@property (nonatomic, retain) HONTrivialUserVO *userVO;
@property (nonatomic, assign) id<HONBaseAvatarViewCellDelegate> delegate;
@end
