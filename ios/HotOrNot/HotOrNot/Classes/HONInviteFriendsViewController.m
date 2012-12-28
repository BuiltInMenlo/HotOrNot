//
//  HONInviteFriendsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.26.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "Facebook.h"
#import "Mixpanel.h"
#import "MBProgressHUD.h"

#import "HONInviteFriendsViewController.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"
#import "HONFacebookCaller.h"

@interface HONInviteFriendsViewController () <UISearchBarDelegate, FBFriendPickerDelegate> {
	CGFloat fbHeaderHeight;
}

@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSMutableArray *friends;

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) NSString *searchText;
@property (nonatomic, retain) HONHeaderView *friendPickerHeaderView;
@end

@implementation HONInviteFriendsViewController

@synthesize friendPickerController = _friendPickerController;
@synthesize searchBar = _searchBar;
@synthesize searchText = _searchText;

- (id)init {
	if ((self = [super init])) {
		_friends = [NSMutableArray array];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"Y"];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h.png" : @"mainBG.png"];
	[self.view addSubview:bgImgView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Invite Friends"];
	[self.view addSubview:headerView];
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(247.0, 0.0, 74.0, 44.0);
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive.png"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active.png"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:cancelButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	self.friendPickerController = [[FBFriendPickerViewController alloc] init];
	self.friendPickerController.title = @"Pick Friends";
	self.friendPickerController.allowsMultipleSelection = NO;
	self.friendPickerController.delegate = self;
	self.friendPickerController.sortOrdering = FBFriendDisplayByLastName;
	[self addCustomHeaderToFriendPickerView];
	[self.friendPickerController loadData];
	[self.friendPickerController clearSelection];
	
	// Use the modal wrapper method to display the picker.
	[self presentViewController:self.friendPickerController animated:NO completion:^(void){[self addSearchBarToFriendPickerView];}];
}

#pragma mark - Navigation
- (void)_goCancel {
	//[self.navigationController popToRootViewControllerAnimated:YES];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Custom Facebook Select Friends Header Methods
// Method to that adds a custom header bar to the built-in Friend Selector View.
// We add this to the canvasView of the FBFriendPickerViewController.
// We have to set cancelButton and doneButton to nil so that default header is removed.
// We then add a UIView as a header.
- (void)addCustomHeaderToFriendPickerView
{
	self.friendPickerController.cancelButton = nil;
	self.friendPickerController.doneButton = nil;
	
	CGFloat headerBarHeight = 45.0;
	fbHeaderHeight = headerBarHeight;
	
	self.friendPickerHeaderView = [[HONHeaderView alloc] initWithTitle:@"Select Friends"];
	self.friendPickerHeaderView.autoresizingMask = self.friendPickerHeaderView.autoresizingMask | UIViewAutoresizingFlexibleWidth;
	
	// Cancel Button
	UIButton *customCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[customCancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[customCancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	[customCancelButton addTarget:self action:@selector(facebookViewControllerCancelWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	customCancelButton.frame = CGRectMake(0, 0, 74.0, 44.0);
	[self.friendPickerHeaderView addSubview:customCancelButton];
	
	// Done Button
	UIButton *customDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[customDoneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[customDoneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[customDoneButton addTarget:self action:@selector(facebookViewControllerDoneWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	customDoneButton.frame = CGRectMake(self.view.bounds.size.width - 59.0, 5.0, 54.0, 34.0);
	[self.friendPickerHeaderView addSubview:customDoneButton];
	
}

#pragma mark - Custom Facebook Select Friends Search Methods
// Method to that adds a search bar to the built-in Friend Selector View.
// We add this search bar to the canvasView of the FBFriendPickerViewController.
- (void)addSearchBarToFriendPickerView
{
	if (self.searchBar == nil) {
		CGFloat searchBarHeight = 44.0;
		self.searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(0, 45.0, self.view.bounds.size.width, searchBarHeight)];
		self.searchBar.autoresizingMask = self.searchBar.autoresizingMask | UIViewAutoresizingFlexibleWidth;
		self.searchBar.tintColor = [UIColor colorWithRed:0.2863 green:0.2706 blue:0.7098 alpha:1.0];
		self.searchBar.delegate = self;
		self.searchBar.showsCancelButton = NO;
		
		[self.friendPickerController.canvasView addSubview:self.friendPickerHeaderView];
		[self.friendPickerController.canvasView addSubview:self.searchBar];
		CGRect updatedFrame = self.friendPickerController.view.bounds;
		updatedFrame.size.height -= (fbHeaderHeight + searchBarHeight);
		updatedFrame.origin.y = fbHeaderHeight + searchBarHeight;
		self.friendPickerController.tableView.frame = updatedFrame;
		
		self.friendPickerController.parentViewController.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.3137 green:0.6431 blue:0.9333 alpha:1.0];
		//setBackgroundImage:[UIImage imageNamed:@"header"] forBarMetrics:UIBarMetricsDefault];
	}
	
	UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchBarSearchTextDidChange:)name:UITextFieldTextDidChangeNotification object:searchField];
}

// There is no delegate UISearchBarDelegate method for when text changes.
// This is a custom method using NSNotificationCenter
- (void)searchBarSearchTextDidChange:(NSNotification*)notification
{
	UITextField *searchField = notification.object;
	self.searchText = searchField.text;
	[self.friendPickerController updateView];
}

// Private Method that handles the search functionality
- (void)handleSearch:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	self.searchText = searchBar.text;
	[self.friendPickerController updateView];
}

// Method that actually does the sorting.
// This filters the data without having to call the server.
- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker shouldIncludeUser:(id<FBGraphUser>)user
{
	if (self.searchText && ![self.searchText isEqualToString:@""]) {
		NSRange result = [user.name rangeOfString:self.searchText options:NSCaseInsensitiveSearch];
		if (result.location != NSNotFound) {
			return YES;
		} else {
			return NO;
		}
	} else {
		return YES;
	}
	return YES;
}


#pragma mark - Facebook FBFriendPickerDelegate Methods
- (void)facebookViewControllerCancelWasPressed:(id)sender
{
	NSLog(@"Friend selection cancelled.");
	//[self handlePickerDone];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender
{
	if (self.friendPickerController.selection.count == 0) {
		[[[UIAlertView alloc] initWithTitle:@"No Friend Selected"
											 message:@"You need to pick a friend."
											delegate:nil
								cancelButtonTitle:@"OK"
								otherButtonTitles:nil]
		 show];
		//[self handlePickerDone];
	
	} else {
		_friends = [NSMutableArray array];
		for (id<FBGraphUser> user in self.friendPickerController.selection) {
			NSLog(@"Friend selected: %@", user.name);
			[_friends addObject:[user objectForKey:@"id"]];
		}
		
		[HONFacebookCaller sendAppRequestBroadcastWithIDs:[_friends copy]];
		//[self handlePickerDone];
	}
}

- (void)handlePickerDone
{
	self.searchBar = nil;
	[self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - UISearchBarDelegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
	[self handleSearch:searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
	self.searchText = nil;
	[searchBar resignFirstResponder];
}

@end
