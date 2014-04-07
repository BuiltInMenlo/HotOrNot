//
//  HONCameraSubjectsView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONVolleyEmotionsPickerView.h"
#import "HONColorAuthority.h"
#import "HONFontAllocator.h"
#import "HONUserVO.h"
#import "HONEmotionVO.h"
#import "HONCreateEmotionViewCell.h"

@interface HONVolleyEmotionsPickerView ()
@property (nonatomic, strong) NSArray *emotions;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation HONVolleyEmotionsPickerView

@synthesize delegate = _delegate;
@synthesize isJoinVolley = _isJoinVolley;

- (id)initWithFrame:(CGRect)frame AsComposeSubjects:(BOOL)isCompose {
	if ((self = [super initWithFrame:frame])) {
		_isJoinVolley = !isCompose;
		_emotions = (_isJoinVolley) ? [HONAppDelegate replyEmotions] : [HONAppDelegate composeEmotions];
		
		_tableView = [[UITableView alloc] initWithFrame:CGRectOffset(frame, 0.0, -frame.origin.y) style:UITableViewStylePlain];
		[_tableView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.scrollsToTop = NO;
		_tableView.showsVerticalScrollIndicator = YES;
		[self addSubview:_tableView];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setIsJoinVolley:(BOOL)isJoinVolley {
	_isJoinVolley = isJoinVolley;
	
	_emotions = (_isJoinVolley) ? [HONAppDelegate replyEmotions] : [HONAppDelegate composeEmotions];
	[_tableView reloadData];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_emotions count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONCreateEmotionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONCreateEmotionViewCell alloc] initWithEmotion:(HONEmotionVO *)[_emotions objectAtIndex:indexPath.row] AsEvenRow:(indexPath.row % 2 == 0)];
	
//	[cell setSubject:[_subjects objectAtIndex:indexPath.row]];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.row == [_emotions count] - 1) ? kOrthodoxTableCellHeight + 44.0 : kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (kOrthodoxTableHeaderHeight);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableHeaderBG"]];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 4.0, 200.0, 16.0)];
	label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:11];
	label.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	label.backgroundColor = [UIColor clearColor];
	label.text = (_isJoinVolley) ? @"TOP EMOTIONS" : @"TOP EMOTIONS";
	[imageView addSubview:label];
	
	return (imageView);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	[(HONCreateEmotionViewCell *)[tableView cellForRowAtIndexPath:indexPath] showTapOverlay];
	
	//[self.delegate subjectsView:self selectSubject:[[_subjects objectAtIndex:indexPath.row] objectForKey:@"text"]];
	
	HONEmotionVO *vo = (HONEmotionVO *)[_emotions objectAtIndex:indexPath.row];
	[self.delegate emotionsPickerView:self selectEmotion:vo];
}


@end
