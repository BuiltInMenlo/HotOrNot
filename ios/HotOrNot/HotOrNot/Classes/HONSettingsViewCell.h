//
//  HONSettingsViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONBaseRowViewCell.h"

@interface HONSettingsViewCell : HONBaseRowViewCell
+ (NSString *)cellReuseIdentifier;

- (id)initWithCaption:(NSString *)caption;
@end
