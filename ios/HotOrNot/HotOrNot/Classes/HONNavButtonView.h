//
//  HONNavButtonView.h
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HONNavButtonView : UIView {
	CGSize _size;
	UIButton *_button;
}

- (id)initWithTarget:(id)target action:(SEL)action;
@end
