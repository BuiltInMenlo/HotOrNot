//
//  HONSubjectsViewController.m
//  HotOrNot
//
//  Created by BIM  on 12/31/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+BuiltinMenlo.h"
#import "NSDictionary+BuiltinMenlo.h"

#import "HONSubjectsViewController.h"
#import "HONSubjectViewCell.h"

@interface HONSubjectsViewController () <HONSubjectViewCellDeleagte>
@end

@implementation HONSubjectsViewController

- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}

- (id)initWithSubmitParameters:(NSDictionary *)submitParams {
	if ((self = [self init])) {
		_submitParams = [submitParams mutableCopy];
	}
	
	return (self);
}

- (void)dealloc {
	[self destroy];
}

- (void)destroy {
	[[_tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONSubjectViewCell *cell = (HONSubjectViewCell *)obj;
		cell.delegate = nil;
	}];
	
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
	
	[super destroy];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	[self _goReloadContents];
}

- (void)_goReloadContents {
	if (![_refreshControl isRefreshing])
		[_refreshControl beginRefreshing];
	
	_subjects = [NSMutableArray array];
	[_tableView reloadData];
}

- (void)_didFinishDataRefresh {
	NSLog(@"%@._didFinishDataRefresh - [%d]", self.class, (int)[_subjects count]);
	
	[_tableView reloadData];
	[_refreshControl endRefreshing];
}

#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_subjects = [NSMutableArray array];
	
	_headerView = [[HONHeaderView alloc] init];
	[self.view addSubview:_headerView];
	
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - (kNavHeaderHeight))];
//	[_tableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 58.0, 0.0)];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	//	_panGestureRecognizer.enabled = YES;
}


#pragma mark - SubjectViewCell Delegates
- (void)subjectViewCell:(HONSubjectViewCell *)viewCell didSelectSubject:(HONSubjectVO *)subjectVO {
	NSLog(@"[*:*] subjectViewCell:didSelectSubject:[%@]", [subjectVO toString]);
	
	_selectedSubjectVO = subjectVO;
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_subjects count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONSubjectViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONSubjectViewCell alloc] init];
	
	[cell setSize:[tableView rectForRowAtIndexPath:indexPath].size];
	[cell setIndexPath:indexPath];
	cell.alpha = 0.0;
	
	cell.subjectVO = (HONSubjectVO *)[_subjects objectAtIndex:indexPath.row];
	cell.delegate = self;
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	if (!tableView.decelerating)
		[cell toggleImageLoading:YES];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (58.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	HONSubjectViewCell *cell = (HONSubjectViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	NSLog(@"[[- cell.subjectVO:[%@]", [cell.subjectVO toString]);
	
	_selectedSubjectVO = cell.subjectVO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	[UIView animateKeyframesWithDuration:0.125 delay:0.050 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
		cell.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	HONSubjectViewCell *viewCell = (HONSubjectViewCell *)cell;
	
	viewCell.alpha = 0.0;
	[viewCell toggleImageLoading:NO];
}


@end
