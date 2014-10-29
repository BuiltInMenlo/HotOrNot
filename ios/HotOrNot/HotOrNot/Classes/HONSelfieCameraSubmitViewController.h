//
//  HONCameraSubmitViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 07:11 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONSelectClubsViewController.h"

@class HONComposeViewController;
@interface HONSelfieCameraSubmitViewController : HONSelectClubsViewController <UITableViewDataSource, UITableViewDelegate>
- (id)initWithSubmitParameters:(NSDictionary *)submitParams;
@end
