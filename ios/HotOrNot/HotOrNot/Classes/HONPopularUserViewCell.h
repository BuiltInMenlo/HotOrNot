//
//  HONPopularUserViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 7/8/13 @ 5:03 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONCelebVO.h"

@protocol HONPopularUserViewCellDelegate;
@interface HONPopularUserViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, retain) HONCelebVO *celebVO;
@property (nonatomic, assign) id <HONPopularUserViewCellDelegate> delegate;
@end


@protocol HONPopularUserViewCellDelegate
- (void)popularUserViewCell:(HONPopularUserViewCell *)cell celeb:(HONCelebVO *)celebVO toggleSelected:(BOOL)isSelected;
@end