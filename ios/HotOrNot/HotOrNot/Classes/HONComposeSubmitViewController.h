//
//  HONComposeSubmitViewController.h
//  HotOrNot
//
//  Created by BIM  on 9/13/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONContactsViewController.h"

@interface HONComposeSubmitViewController : HONContactsViewController <UIAlertViewDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>
- (id)initWithSubmitParameters:(NSDictionary *)submitParams;
@end
