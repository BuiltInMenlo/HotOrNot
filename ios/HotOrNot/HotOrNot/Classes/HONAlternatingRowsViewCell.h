//
//  HONAlternatingRowsViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.06.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HONAlternatingRowsViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (id)initAsGreyCell:(BOOL)grey;
- (void)hideChevron;
- (void)didSelect;
@end
