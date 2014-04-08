//
//  HONProfileHeaderButtonView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 9/1/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

@interface HONProfileHeaderButtonView : UIView
- (id)initWithTarget:(id)target action:(SEL)action;
- (void)toggleSelected:(BOOL)isSelected;
@end
