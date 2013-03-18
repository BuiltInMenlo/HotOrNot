//
//  HONGenericRowViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 3/17/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HONGenericRowViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)hideChevron;
- (void)didSelect;
@end
