//
//  HONChallengerPickerViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.23.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONChallengerPickerViewController.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"
#import "HONChallengerViewCell.h"
#import "HONImagingDepictor.h"

@interface HONChallengerPickerViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *challengers;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) NSString *imagePrefix;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) HONUserVO *challengerVO;
@property (nonatomic, strong) HONUserVO *userVO;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic) BOOL isPrivate;
@end

@implementation HONChallengerPickerViewController

- (id)initWithSubject:(NSString *)subject imagePrefix:(NSString *)imgPrefix previewImage:(UIImage *)image {
	if ((self = [super init])) {
		_subjectName = subject;
		_imagePrefix = imgPrefix;
		_username = @"";
		
		_previewImage = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(107.0 * 2.0, 143.0 * 2.0)];
	}
	
	return (self);
}

- (id)initWithSubject:(NSString *)subject imagePrefix:(NSString *)imgPrefix previewImage:(UIImage *)image userVO:(HONUserVO *)userVO challengeVO:(HONChallengeVO *)challengeVO {
	if ((self = [super init])) {
		_subjectName = subject;
		_imagePrefix = imgPrefix;
		_username = @"";
		
		_previewImage = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(107.0 * 2.0, 143.0 * 2.0)];
		
		_userVO = userVO;
		_challengeVO = challengeVO;
		
		if (_userVO != nil)
			_username = _userVO.username;
		
		if (_challengeVO != nil)
			_username = _challengeVO.creatorName;
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (NO);
}


#pragma mark - Data Calls
- (void)_retrievePastUsers {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 4], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									nil];
	
	[httpClient postPath:kAPISearch parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"HONChallengerPickerViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
		} else {
			NSArray *unsortedUsers = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//NSArray *parsedUsers = [NSMutableArray arrayWithArray:[unsortedUsers sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
			//NSLog(@"HONChallengerPickerViewController AFNetworking: %@", parsedUsers);
			
			
			int cnt = 0;
			for (NSDictionary *serverList in unsortedUsers) {
				HONUserVO *vo = [HONUserVO userWithDictionary:serverList];
				
				if (vo != nil)
					[_challengers addObject:vo];
				
				cnt++;
				if (cnt == 3)
					break;
			}
			
			[_challengers addObject:[HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
																					  [NSString stringWithFormat:@"%d", 0], @"id",
																					  [NSString stringWithFormat:@"%d", 0], @"points",
																					  [NSString stringWithFormat:@"%d", 0], @"votes",
																					  [NSString stringWithFormat:@"%d", 0], @"pokes",
																					  [NSString stringWithFormat:@"%d", 0], @"pics",
																					  @"Send a random match", @"username",
																					  @"", @"fb_id",
																					  @"https://hotornot-avatars.s3.amazonaws.com/waitingAvatar.png", @"avatar_url", nil]]];
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			[_tableView reloadData];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"HONChallengerPickerViewController AFNetworking %@", [error localizedDescription]);
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}

- (void)_submitChallenge {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_submit", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[params setObject:[NSString stringWithFormat:@"https://hotornot-challenges.s3.amazonaws.com/%@", _imagePrefix] forKey:@"imgURL"];
	[params setObject:_subjectName forKey:@"subject"];
	[params setObject:(_isPrivate) ? @"Y" : @"N" forKey:@"isPrivate"];
	[params setObject:[NSString stringWithFormat:@"%d", (_challengeVO != nil) ? 4 : ([_username isEqualToString:NSLocalizedString(@"userPlaceholder", nil)] || [_challengerVO.username isEqualToString:@"Send a random match"]) ? 1 : 7] forKey:@"action"];
	
	if (_challengeVO != nil)
		[params setObject:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
		
	if (_challengerVO != nil)
		[params setObject:_challengerVO.username forKey:@"username"];
	
	if (![_username isEqualToString:NSLocalizedString(@"userPlaceholder", nil)] && [_username length] > 0)
		[params setObject:([[_username substringToIndex:1] isEqualToString:@"@"]) ? [_username substringFromIndex:1] : _username forKey:@"username"];
		
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"HONChallengerPickerViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_dlFailed", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
			
		} else {
			NSDictionary *challengeResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSLog(@"HONChallengerPickerViewController AFNetworking %@", challengeResult);
			
			[_progressHUD hide:YES];
			_progressHUD = nil;
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			
			if ([[challengeResult objectForKey:@"result"] isEqualToString:@"fail"]) {
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"hud_usernameNotFound", nil);
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
				
			} else {
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkIcon"]];
				_progressHUD.labelText = NSLocalizedString(@"hud_sent", nil);
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
				
				[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:nil];
				
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
				[TestFlight passCheckpoint:@"CREATED A SNAP"];
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"HONChallengerPickerViewController AFNetworking %@", [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	_isPrivate = NO;
	
	_challengers = [NSMutableArray array];
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h@2x" : @"mainBG"];
	[self.view addSubview:bgImgView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:_subjectName];
	[_headerView hideRefreshing];
	[self.view addSubview:_headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(3.0, 0.0, 64.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:backButton];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(254.0, 0.0, 64.0, 44.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:submitButton];
	
	UIView *challengeImgHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, kNavBarHeaderHeight, 107.0, 107.0)];
	challengeImgHolderView.clipsToBounds = YES;
	[self.view addSubview:challengeImgHolderView];
	
	UIImageView *challengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -18.0, 107.0, 143.0)];
	challengeImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	challengeImageView.image = _previewImage;
	[challengeImgHolderView addSubview:challengeImageView];
	
	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(112.0, 55.0, 320.0, 24.0)];
	//[_usernameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_usernameTextField setReturnKeyType:UIReturnKeyDone];
	[_usernameTextField setTextColor:[HONAppDelegate honGrey635Color]];
	//[_usernameTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_usernameTextField.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:15];
	_usernameTextField.keyboardType = UIKeyboardTypeDefault;
	_usernameTextField.text = ([_username length] == 0) ? NSLocalizedString(@"userPlaceholder", nil) : [NSString stringWithFormat:@"@%@", _username];
	_usernameTextField.delegate = self;
	[self.view addSubview:_usernameTextField];
	
	UIButton *privateToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	privateToggleButton.frame = CGRectMake(274.0, 110.0, 34.0, 34.0);
	[privateToggleButton setBackgroundImage:[UIImage imageNamed:@"submitButton_nonActive"] forState:UIControlStateNormal];
	[privateToggleButton setBackgroundImage:[UIImage imageNamed:@"submitButton_Active"] forState:UIControlStateHighlighted];
	[privateToggleButton addTarget:self action:@selector(_goPrivateToggle) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:privateToggleButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavBarHeaderHeight + 94.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (kNavBarHeaderHeight + 114.0)) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 70.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	[self _retrievePastUsers];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goBack {
	[[Mixpanel sharedInstance] track:@"Challenger Picker - Back"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.navigationController popViewControllerAnimated:NO];
}

- (void)_goSubmit {
	if ([_usernameTextField isFirstResponder])
		[_usernameTextField resignFirstResponder];
	
	[self _submitChallenge];
}

- (void)_goPrivateToggle {
	_isPrivate = !_isPrivate;
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_challengers count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 31.0)];
	headerView.image = [UIImage imageNamed:@"tableHeaderBackground"];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 4.0, 310.0, 31.0)];
	label.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:13];
	label.textColor = [HONAppDelegate honBlueTxtColor];
	label.backgroundColor = [UIColor clearColor];
	label.text = @"Recent";
	[headerView addSubview:label];
	
	return (headerView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONChallengerViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		cell = [[HONChallengerViewCell alloc] initAsRandomUser:(indexPath.row == [_challengers count] - 1)];
		cell.userVO = (HONUserVO *)[_challengers objectAtIndex:indexPath.row];
	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kDefaultCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (40.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	HONChallengerViewCell *cell = (HONChallengerViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	[cell didSelect];
	
	_challengerVO = (HONUserVO *)[_challengers objectAtIndex:indexPath.row];		
	[[Mixpanel sharedInstance] track:@"Challenger Picker - Past User"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 (_challengerVO != nil) ? _challengerVO.username : @"RANDOM", @"challenger", nil]];

	
	[self _submitChallenge];
}


#pragma mark - TextField Delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	if (textField.tag == 0) {
		textField.text = @"@";
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (textField.tag == 0) {
		if ([textField.text isEqualToString:@""])
			textField.text = @"@";
	}
	
	return (YES);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	if (textField.tag == 0) {
		if ([textField.text length] == 0 || [textField.text isEqualToString:@"@"])
			textField.text = NSLocalizedString(@"userPlaceholder", nil);
		
		_username = ([textField.text isEqualToString:NSLocalizedString(@"userPlaceholder", nil)]) ? NSLocalizedString(@"userPlaceholder", nil) : textField.text;
		[[Mixpanel sharedInstance] track:@"Challenger Picker - Enter Username"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
													 _username, @"username", nil]];
		
		if ([_username isEqualToString:[[HONAppDelegate infoForUser] objectForKey:@"name"]]) {
			[[[UIAlertView alloc] initWithTitle:@"Snap Problem!"
												 message:@"You cannot snap at yourself!"
												delegate:nil
									cancelButtonTitle:@"OK"
									otherButtonTitles:nil] show];
		}
	}
}

@end
