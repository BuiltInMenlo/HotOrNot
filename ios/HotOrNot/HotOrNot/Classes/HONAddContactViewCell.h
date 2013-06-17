//
//  HONAddContactViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.10.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONContactUserVO.h"

@interface HONAddContactViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)toggleSelected:(BOOL)isSelected;
@property (nonatomic, retain) HONContactUserVO *userVO;
@end
