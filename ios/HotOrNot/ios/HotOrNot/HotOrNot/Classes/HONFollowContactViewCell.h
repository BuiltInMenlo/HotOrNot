//
//  HONFollowContactViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.10.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONTrivialUserVO.h"

@class HONFollowContactViewCell;
@protocol HONFollowContactViewCellDelegate <NSObject>
- (void)followContactUserViewCell:(HONFollowContactViewCell *)viewCell followUser:(HONTrivialUserVO *)userVO toggleSelected:(BOOL)isSelected;
@end

@interface HONFollowContactViewCell : UITableViewCell {
	UILabel *_nameLabel;
}

+ (NSString *)cellReuseIdentifier;
- (void)toggleSelected:(BOOL)isSelected;

@property (nonatomic, assign) id<HONFollowContactViewCellDelegate> delegate;
@property (nonatomic, retain) HONTrivialUserVO *userVO;

@end
