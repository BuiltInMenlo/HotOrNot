//
//  HONResultsViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.21.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONResultsViewController.h"

@interface HONResultsViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (id)initAsTopCell;
- (id)initAsResultCell:(HONChallengeResultsState)state;
- (id)initAsStatCell:(NSString *)caption;
- (id)initAsBottomCell;

@end
