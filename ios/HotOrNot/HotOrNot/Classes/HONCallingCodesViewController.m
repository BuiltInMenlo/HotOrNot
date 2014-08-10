//
//  HONCallingCodesViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 05/02/2014 @ 10:08 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "CKRefreshControl.h"
#import "MBProgressHUD.h"

#import "HONCallingCodesViewController.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONTableView.h"
#import "HONCallingCodeViewCell.h"
#import "HONCountryVO.h"


@interface HONCallingCodesViewController () <HONCallingCodeViewCellDelegate>
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *countries;
@property (nonatomic, strong) HONCountryVO *countryVO;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSDictionary *segmentedCountries;
@property (nonatomic, strong) NSMutableArray *segmentedKeys;
@end


@implementation HONCallingCodesViewController
@synthesize delegate = _delegate;

- (id)init {
	if ((self = [super init])) {
		
	}
	
	return (self);
}


#pragma mark - Data Calls
- (void)_retreiveCountries {
	_countries = [NSMutableArray array];
	_cells = [NSMutableArray array];
	for (NSDictionary *dict in [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CountryCodes" ofType:@"plist"]])
		[_countries addObject:[HONCountryVO countryWithDictionary:dict]];

	
	_segmentedCountries = [self _populateSegmentedDictionary];
	[_tableView reloadData];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(CKRefreshControl *)sender {
	[self _retreiveCountries];
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	_segmentedCountries = [self _populateSegmentedDictionary];
	
	[_tableView reloadData];
	[_refreshControl endRefreshing];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_cells = [NSMutableArray array];
	self.view.backgroundColor = [UIColor whiteColor];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(227.0, 0.0, 93.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Select"];
	[headerView addButton:doneButton];
	[self.view addSubview:headerView];
	
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - kNavHeaderHeight)];
	[_tableView setContentInset:kOrthodoxTableViewEdgeInsets];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	
	[self _retreiveCountries];
}


#pragma mark - Navigation
- (void)_goDone {
	if (_countryVO != nil) {
		if ([self.delegate respondsToSelector:@selector(callingCodesViewController:didSelectCountry:)])
			[self.delegate callingCodesViewController:self didSelectCountry:_countryVO];
	}
	
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - CallingCodeViewCell Delegates
- (void)callingCodeViewCell:(HONCallingCodeViewCell *)viewCell didDeselectCountry:(HONCountryVO *)countryVO {
	NSLog(@"[*:*] callingCodeViewCell:didDeselectCountry:(%@ - %@)", countryVO.countryName, countryVO.callingCode);
	_countryVO = nil;
}

- (void)callingCodeViewCell:(HONCallingCodeViewCell *)viewCell didSelectCountry:(HONCountryVO *)countryVO {
	NSLog(@"[*:*] callingCodeViewCell:didSelectCountry:(%@ - %@)", countryVO.countryName, countryVO.callingCode);
	_countryVO = countryVO;
	
	for (HONCallingCodeViewCell *cell in _cells) {
		if (![cell isEqual:viewCell])
			[cell toggleSelected:NO];
	}
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ([_segmentedKeys count]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([[_segmentedCountries valueForKey:[_segmentedKeys objectAtIndex:section]] count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return ([[HONTableHeaderView alloc] initWithTitle:[_segmentedKeys objectAtIndex:section]]);
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return ([[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]);
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return ([[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONCallingCodeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONCallingCodeViewCell alloc] init];
	
	
	cell.countryVO = (HONCountryVO *)[[_segmentedCountries valueForKey:[_segmentedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	if (![_cells containsObject:cell])
		[_cells addObject:cell];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	HONCallingCodeViewCell *viewCell = (HONCallingCodeViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	[viewCell invertSelected];
	
	for (HONCallingCodeViewCell *cell in _cells) {
		if (![cell isEqual:viewCell])
			[cell toggleSelected:NO];
	}
	
	_countryVO = (viewCell.isSelected) ? viewCell.countryVO : nil;
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}


#pragma mark - Data Manip
-(NSDictionary *)_populateSegmentedDictionary {
	_segmentedKeys = [[NSMutableArray alloc] init];
	[_segmentedKeys removeAllObjects];
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	for (HONCountryVO *vo in _countries) {
		if ([vo.countryName length] > 0) {
			NSString *charKey = [[vo.countryName substringToIndex:1] lowercaseString];
			NSLog(@"Country name! %@", charKey);
			if (![_segmentedKeys containsObject:charKey]) {
				[_segmentedKeys addObject:charKey];
				
				NSMutableArray *newSegment = [[NSMutableArray alloc] initWithObjects:vo, nil];
				[dict setValue:newSegment forKey:charKey];
				
			} else {
				NSMutableArray *prevSegment = (NSMutableArray *)[dict valueForKey:charKey];
				[prevSegment addObject:vo];
				[dict setValue:prevSegment forKey:charKey];
			}
		}
	}
	
	return (dict);
}

@end
