//
//  HONCameraPreviewSubscribersView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONCameraPreviewSubscribersView.h"
#import "HONUserVO.h"
#import "HONCameraSubjectViewCell.h"

@interface HONCameraPreviewSubscribersView () <HONCameraSubjectViewCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation HONCameraPreviewSubscribersView

@synthesize opponents = _opponents;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_opponents = [NSMutableArray array];
		
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 129.0, 320.0, [UIScreen mainScreen].bounds.size.height - 79.0) style:UITableViewStylePlain];
		[_tableView setBackgroundColor:[UIColor clearColor]];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.scrollsToTop = NO;
		_tableView.showsVerticalScrollIndicator = YES;
		[self addSubview:_tableView];
	}
	
	return (self);
}


- (void)setOpponents:(NSMutableArray *)opponents {
	_opponents = opponents;
	[_tableView reloadData];
}

#pragma mark - SubscriberViewCell Delegates
- (void)subjectViewCell:(HONCameraSubjectViewCell *)cell selectSubject:(NSString *)subject {
	int row = 0;
	for (HONUserVO *vo in _opponents) {
		if (vo.userID == userVO.userID)
			break;
		
		row++;
	}
	
	[_opponents removeObjectAtIndex:row];
	[_tableView reloadData];
	
	//[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
	[self.delegate subscriberView:self removeOpponent:userVO];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_opponents count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONCameraSubjectViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONCameraSubjectViewCell alloc] init];
	
	cell.delegate = self;
	[cell setUserVO:(HONUserVO *)[_opponents objectAtIndex:indexPath.row]];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight + 7.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}


@end
