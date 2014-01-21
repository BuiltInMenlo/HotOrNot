//
//  HONMessageDetailsViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 01/19/2014 @ 15:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONMessageVO.h"


@interface HONMessageDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
- (id)initWithMessage:(HONMessageVO *)messageVO;
@end
