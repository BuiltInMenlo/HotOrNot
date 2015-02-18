//
//  HONSubjectsViewController.h
//  HotOrNot
//
//  Created by BIM  on 12/31/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONViewController.h"
#import "HONRefreshControl.h"
#import "HONTableView.h"
#import "HONSubjectViewCell.h"
#import "HONSubjectVO.h"

@interface HONReplySubjectsViewController : HONViewController <UIAlertViewDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate> {
	HONTableView *_tableView;
	UIRefreshControl *_refreshControl;
	NSMutableArray *_subjects;
	HONSubjectVO *_selectedSubjectVO;
	NSMutableDictionary *_submitParams;
}

- (id)initWithSubmitParameters:(NSDictionary *)submitParams;
- (void)_goDataRefresh:(HONRefreshControl *)sender;
- (void)_goReloadContents;
- (void)_didFinishDataRefresh;
- (void)subjectViewCell:(HONSubjectViewCell *)viewCell didSelectSubject:(HONSubjectVO *)subjectVO;
@end
