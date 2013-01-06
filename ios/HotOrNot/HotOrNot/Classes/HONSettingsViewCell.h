//
//  HONSettingsViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HONSettingsViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (id)initAsTopCell;
- (id)initAsMidCell:(NSString *)caption;
- (void)updateCaption:(NSString *)caption;

- (void)didSelect;
@end
