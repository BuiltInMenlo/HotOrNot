//
//  HONStatusUpdateViewController.h
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONViewController.h"
#import "HONClubPhotoVO.h"

@interface HONStatusUpdateViewController : HONViewController <UIActionSheetDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>
- (id)initWithStatusUpdate:(HONClubPhotoVO *)statusUpdateVO;
@end
