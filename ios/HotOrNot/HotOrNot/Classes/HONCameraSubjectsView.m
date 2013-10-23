//
//  HONCameraSubjectsView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONCameraSubjectsView.h"
#import "HONUserVO.h"
#import "HONCameraSubjectViewCell.h"

@interface HONCameraSubjectsView ()
@property (nonatomic, strong) NSArray *subjects;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation HONCameraSubjectsView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_subjects = [HONAppDelegate defaultSubjects];
		
		_tableView = [[UITableView alloc] initWithFrame:CGRectOffset(frame, 0.0, -frame.origin.y) style:UITableViewStylePlain];
		[_tableView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.65]];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.scrollsToTop = NO;
		_tableView.showsVerticalScrollIndicator = YES;
		[self addSubview:_tableView];
	}
	
	return (self);
}


#pragma mark - SubscriberViewCell Delegates
- (void)subjectViewCell:(HONCameraSubjectViewCell *)cell selectSubject:(NSString *)subject {
	[self.delegate subjectsView:self selectSubject:subject];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_subjects count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONCameraSubjectViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONCameraSubjectViewCell alloc] initAsEvenRow:(indexPath.row % 2 == 0)];
	
	[cell setSubject:[_subjects objectAtIndex:indexPath.row]];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.row == [_subjects count] - 1) ? kOrthodoxTableCellHeight + 44.0 : kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (kOrthodoxTableHeaderHeight);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kOrthodoxTableHeaderHeight)];
	headerView.backgroundColor = [UIColor colorWithWhite:0.090 alpha:1.0];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0, -1.0, 320.0, kOrthodoxTableHeaderHeight)];
	label.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:10];
	label.textColor = [HONAppDelegate honGrey318Color];
	label.backgroundColor = [UIColor clearColor];
	label.text = @"TRENDING";
	[headerView addSubview:label];
	
	return (headerView);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	[(HONCameraSubjectViewCell *)[tableView cellForRowAtIndexPath:indexPath] showTapOverlay];
	
	[self.delegate subjectsView:self selectSubject:[[_subjects objectAtIndex:indexPath.row] objectForKey:@"text"]];
}


@end
