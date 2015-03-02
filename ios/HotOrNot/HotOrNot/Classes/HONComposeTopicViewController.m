//
//  HONComposeViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/6/13 @ 12:01 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

#import "NSCharacterSet+BuiltinMenlo.h"
#import "NSDate+BuiltinMenlo.h"
#import "NSDictionary+BuiltinMenlo.h"
#import "NSString+BuiltinMenlo.h"
#import "UIImageView+AFNetworking.h"

#import "Flurry.h"

#import "HONComposeTopicViewController.h"
#import "HONRefreshControl.h"
#import "HONTableView.h"
#import "HONTopicViewCell.h"
#import "HONTopicVO.h"
#import "HONComposeSubjectViewController.h"
#import "HONCloseNavButtonView.h"

@interface HONComposeTopicViewController () <HONTopicViewCellDelegate>
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) HONRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *topics;
@property (nonatomic, strong) HONTopicVO *selectedTopicVO;
@property (nonatomic, strong) HONUserClubVO *userClubVO;
@end


@implementation HONComposeTopicViewController

- (id)init {
	if ((self = [super init])) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"COMPOSE - enter"];
		
		_totalType = HONStateMitigatorTotalTypeCompose;
		_viewStateType = HONStateMitigatorViewStateTypeCompose;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_refreshCompose:)
													 name:@"REFRESH_COMPOSE" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_tareCompose:)
													 name:@"TARE_COMPOSE" object:nil];
		
	}
	
	return (self);
}

-(void)dealloc {
	[[_tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONTopicViewCell *cell = (HONTopicViewCell *)obj;
		cell.delegate = nil;
	}];
	
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
	
	[super destroy];
}


- (id)initWithClub:(HONUserClubVO *)clubVO {
	NSLog(@"%@ - initWithClub:[%d] (%@)", [self description], clubVO.clubID, clubVO.clubName);
	
	if ((self = [self init])) {
		_userClubVO = clubVO;
	}
	
	return (self);
}


#pragma mark - Data Calls
- (void)_retrieveComposeTopics {
	[[[NSUserDefaults standardUserDefaults] objectForKey:@"compose_topics"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSDictionary *dict = (NSDictionary *)obj;
		
		if ([[dict objectForKey:@"parent_id"] intValue] == 0)
			[_topics addObject:[HONTopicVO topicWithDictionary:dict]];
	}];
	
	
	[self _didFinishDataRefresh];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Refresh"];
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeComposeRefresh];
	[self _goReloadContents];
}

- (void)_goReloadContents {
	if (![_refreshControl isRefreshing])
		[_refreshControl beginRefreshing];
	
	_topics = [NSMutableArray array];
	[_tableView reloadData];
	
	[self _retrieveComposeTopics];
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	[_tableView reloadData];
	[_refreshControl endRefreshing];
	
	NSLog(@"%@._didFinishDataRefresh - [%lu]", self.class, (unsigned long)[_topics count]);
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.view.frame.size.height) style:UITableViewStylePlain];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.backgroundColor = [UIColor clearColor];
	[_tableView setContentInset:UIEdgeInsetsMake(kNavHeaderHeight - 20.0, 0.0, 0.0, 0.0)];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.alwaysBounceVertical = YES;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.scrollsToTop = NO;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[HONRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	
	_headerView = [[HONHeaderView alloc] init];
	[self.view addSubview:_headerView];
	
	UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 31.0, 210.0, 22.0)];
	headerLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17];
	headerLabel.textColor = [UIColor blackColor];
	headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	headerLabel.textAlignment = NSTextAlignmentCenter;
	headerLabel.text = @"What's up?";
	[self.view addSubview:headerLabel];
	
	HONCloseNavButtonView *closeNavButtonView = [[HONCloseNavButtonView alloc] initWithTarget:self action:@selector(_goClose)];
	closeNavButtonView.frame = CGRectOffsetY(closeNavButtonView.frame, 20.0);
	[self.view addSubview:closeNavButtonView];
	
	[self _goReloadContents];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
//	self.modalPresentationStyle = UIModalPresentationCurrentContext;
//	self.modalPresentationStyle = UIModalPresentationFormSheet;
//
//	_panGestureRecognizer.enabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:animated:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewWillAppear:animated];
	
	_tableView.alpha = 1.0;
}


#pragma mark - Navigation
- (void)_goClose {
	NSLog(@"[*:*] _goClose");
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"COMPOSE - exit_button"];
	
	[self dismissViewControllerAnimated:NO completion:^(void) {
	}];
	
//	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kButtonSelectDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
//		[self dismissViewControllerAnimated:NO completion:^(void) {
//		}];
//	});
}

- (void)_goNext {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"COMPOSE - step_1_select"];
	
	NSError *error;
	NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@[_selectedTopicVO.topicName] options:0 error:&error]
												 encoding:NSUTF8StringEncoding];
	
	NSDictionary *submitParams = @{@"user_id"		: @([[HONUserAssistant sharedInstance] activeUserID]),
								   @"img_url"		: [NSString stringWithFormat:@"%@/%@", [HONAPICaller s3BucketForType:HONAmazonS3BucketTypeClubsSource], [[HONClubAssistant sharedInstance] defaultStatusUpdatePhotoURL]],
								   @"club_id"		: @(_userClubVO.clubID),
								   @"challenge_id"	: @(0),
								   @"topic_id"		: @(_selectedTopicVO.topicID),
								   @"topic_name"	: _selectedTopicVO.topicName,
								   @"subjects"		: jsonString};
	NSLog(@"|:|◊≈◊~~◊~~◊≈◊~~◊~~◊≈◊| SUBMIT PARAMS:[%@]", submitParams);
	
//	[self presentViewController:[[HONComposeSubjectViewController alloc] initWithSubmitParameters:submitParams] animated:YES completion:nil];
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:[[HONComposeSubjectViewController alloc] initWithSubmitParameters:submitParams] animated:YES];
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	[super _goPanGesture:gestureRecognizer];
	
	if ([gestureRecognizer velocityInView:self.view].y >= 2000 || [gestureRecognizer velocityInView:self.view].x >= 2000) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Dismiss SWIPE"];
		
		[self dismissViewControllerAnimated:NO completion:^(void) {
		}];
	}
	
	if ([gestureRecognizer velocityInView:self.view].x <= -2000 && !_isPushing) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Next SWIPE"];
//		[self _modifySubmitParamsAndSubmit:_subjectNames];
	}
}


#pragma mark - Notifications
- (void)_refreshCompose:(NSNotification *)notification {
	NSLog(@"::|> _refreshCompose <|::");
	[self _goReloadContents];
}

- (void)_tareCompose:(NSNotification *)notification {
	NSLog(@"::|> _tareCompose <|::");
	
	if ([_tableView.visibleCells count] > 0)
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - UI Presentation


#pragma mark - TopicViewCell Delegates
- (void)topicViewCell:(HONTopicViewCell *)viewCell didSelectTopic:(HONTopicVO *)topicVO {
	NSLog(@"[_] topicViewCell:didSelectTopic:[%@]", [topicVO toString]);
	_selectedTopicVO = viewCell.topicVO;
	NSLog(@"COMPOSE TOPIC:[%@]", [_selectedTopicVO toString]);
	[self _goNext];
	
	[UIView animateKeyframesWithDuration:0.125 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
		_tableView.alpha = 0.0;
	} completion:^(BOOL finished) {
	}];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_topics count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//	NSLog(@"[_] tableView:cellForRowAtIndexPath:%@)", NSStringFromNSIndexPath(indexPath));
	
	HONTopicViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	if (cell == nil)
		cell = [[HONTopicViewCell alloc] init];
	
	[cell setIndexPath:indexPath];
	[cell setSize:[tableView rectForRowAtIndexPath:indexPath].size];
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	cell.alpha = 0.0;
	
	HONTopicVO *vo = (HONTopicVO *)[_topics objectAtIndex:indexPath.row];
	cell.topicVO = vo;
	cell.delegate = self;
	
	if (!tableView.decelerating)
		[cell toggleImageLoading:YES];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (54.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"[_] tableView:didSelectRowAtIndexPath:[%@]", NSStringFromNSIndexPath(indexPath));
	
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	HONTopicViewCell *cell = (HONTopicViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	_selectedTopicVO = cell.topicVO;
	NSLog(@"COMPOSE TOPIC:[%@]", [_selectedTopicVO toString]);
	
	[self _goNext];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.alpha = 0.0;
	[UIView animateKeyframesWithDuration:0.125 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
		cell.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	HONTopicViewCell *viewCell = (HONTopicViewCell *)cell;
	[viewCell toggleImageLoading:NO];
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[[_tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONTopicViewCell *cell = (HONTopicViewCell *)obj;
		[cell toggleImageLoading:YES];
	}];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if (buttonIndex == 1) {
		}
	}
}

@end
