//
//  HONTableViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 3/17/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


@interface HONTableViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;
- (void)hideChevron;

@property (nonatomic) CGSize size;
@end
