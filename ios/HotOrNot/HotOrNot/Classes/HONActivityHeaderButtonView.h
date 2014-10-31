//
//  HONActivityHeaderButtonView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 9/1/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONNavButtonView.h"

@interface HONActivityHeaderButtonView : HONNavButtonView
- (id)initWithTarget:(id)target action:(SEL)action;
- (void)updateActivityBadge;
@end
