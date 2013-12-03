//
//  HONProfileContactUserViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.26.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONContactUserVO.h"

@interface HONProfileContactUserViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, retain) HONContactUserVO *contactUserVO;
@end
