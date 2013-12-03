//
//  HONSettingsViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONGenericRowViewCell.h"

@interface HONSettingsViewCell : HONGenericRowViewCell
+ (NSString *)cellReuseIdentifier;

- (id)initWithCaption:(NSString *)caption;
@end
