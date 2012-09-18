//
//  HONVoteViewController
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HONVoteViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithSubject:(int)subjectID;
@end
