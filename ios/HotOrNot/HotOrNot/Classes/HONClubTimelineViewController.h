//
//  HONClubTimelineViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 06/14/2014 @ 21:39 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserClubVO.h"
#import "HONViewController.h"

@interface HONClubTimelineViewController : HONViewController <UITableViewDataSource, UITableViewDelegate>
- (id)initWithClub:(HONUserClubVO *)clubVO atPhotoIndex:(int)index;
@end
