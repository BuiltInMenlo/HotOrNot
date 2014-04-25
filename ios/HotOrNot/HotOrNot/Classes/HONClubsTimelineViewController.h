//
//  HONClubsTimelineViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/25/2014 @ 10:58 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


typedef enum {
	HONClubTimelineRowTypeCTA = 0,
	HONClubTimelineRowTypeSelfie
} HONClubTimelineRowType;


@interface HONClubsTimelineViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@end
