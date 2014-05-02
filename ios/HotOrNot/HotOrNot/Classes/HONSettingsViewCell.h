//
//  HONSettingsViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"

@interface HONSettingsViewCell : HONTableViewCell
+ (NSString *)cellReuseIdentifier;

- (id)initWithCaption:(NSString *)caption;
@end
