//
//  ViewController.m
//  FriendPickerPrototype
//
//  Created by Andrew Vergara on 12/25/12.
//  Copyright (c) 2012 Super. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController () <FBFriendPickerDelegate, UISearchBarDelegate>
{
    CGFloat fbHeaderHeight;
}

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (retain, nonatomic) UIView *headerView;
@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) NSString *searchText;

@end


@implementation ViewController

@synthesize friendPickerController = _friendPickerController;
@synthesize searchBar = _searchBar;
@synthesize searchText = _searchText;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStateChanged:) name:FBSessionStateChangedNotification object:nil];
    
    self.selectFriendsButton.hidden = YES;
}

- (void)viewDidUnload
{
    self.friendPickerController = nil;
    self.searchBar = nil;
}

#pragma mark - User Interaction Methods
- (IBAction)loginAction:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate openSessionWithAllowLoginUI:YES];
}

- (IBAction)selectFriendsAction:(id)sender
{
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Select Friends";
        self.friendPickerController.delegate = self;
        [self addCustomHeaderToFriendPickerView];        
    }
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection]; 

    // This message will only work on iOS 5+. The completion handler is not implemented on iOS 4 and below.
    [self presentViewController:self.friendPickerController animated:YES completion:^(void){[self addSearchBarToFriendPickerView];}];
}

- (void)handlePickerDone
{
    [self dismissModalViewControllerAnimated:YES];
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
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, headerBarHeight)];
    self.headerView.autoresizingMask = self.headerView.autoresizingMask | UIViewAutoresizingFlexibleWidth;
    UIImageView *headerBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header"]];
    [self.headerView addSubview:headerBG];

    // Header Title
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44.0)];
    headerTitle.textAlignment =  UITextAlignmentCenter;
    headerTitle.textColor = [UIColor whiteColor];
    headerTitle.backgroundColor = [UIColor clearColor];
    headerTitle.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(18.0)];
    headerTitle.text = @"Select Friends";
    [self.headerView addSubview:headerTitle];
    
    // Cancel Button
    UIButton *customCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customCancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
    [customCancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
    [customCancelButton addTarget:self action:@selector(facebookViewControllerCancelWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    customCancelButton.frame = CGRectMake(0, 0, 74.0, 44.0);
    [self.headerView addSubview:customCancelButton];
    
    // Done Button
    UIButton *customDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customDoneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
    [customDoneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];    
    [customDoneButton addTarget:self action:@selector(facebookViewControllerDoneWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    customDoneButton.frame = CGRectMake(self.view.bounds.size.width - 59.0, 5.0, 54.0, 34.0);
    [self.headerView addSubview:customDoneButton];
    
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

        [self.friendPickerController.canvasView addSubview:self.headerView];
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

#pragma mark - UISearchBarDelegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [self handleSearch:searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    self.searchText = nil;
    [searchBar resignFirstResponder];
}

#pragma mark - Facebook Session State Notification Methods
- (void)sessionStateChanged:(NSNotification*)notification
{
    if (FBSession.activeSession.isOpen) {
        self.selectFriendsButton.hidden = NO;
        [self.loginButton setTitle:@"Logout" forState:UIControlStateNormal];
    } else {
        self.selectFriendsButton.hidden = YES;
        [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    }
}

#pragma mark - Facebook FBFriendPickerDelegate Methods
- (void)facebookViewControllerCancelWasPressed:(id)sender
{
    NSLog(@"Friend selection cancelled.");
    [self handlePickerDone];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender
{
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        NSLog(@"Friend selected: %@", user.name);
    }
    [self handlePickerDone];
}

#pragma mark - Memory Warnings
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end