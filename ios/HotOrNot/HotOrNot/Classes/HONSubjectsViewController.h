//
//  HONTopicsViewController.h
//  HotOrNot
//
//  Created by BIM  on 1/11/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "HONViewController.h"
#import "HONRefreshControl.h"
#import "HONTableView.h"
#import "HONTopicViewCell.h"
#import "HONTopicVO.h"


@interface HONSubjectsViewController : HONViewController <UIAlertViewDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate> {
	HONTableView *_tableView;
	UIRefreshControl *_refreshControl;
	NSMutableArray *_topics;
	HONTopicVO *_selectedTopicVO;
	NSMutableDictionary *_submitParams;
}

- (id)initWithSubmitParameters:(NSDictionary *)submitParams;
- (void)_goDataRefresh:(HONRefreshControl *)sender;
- (void)_goReloadContents;
- (void)_didFinishDataRefresh;
- (void)topicViewCell:(HONTopicViewCell *)viewCell didSelectTopic:(HONTopicVO *)topicVO;
@end
