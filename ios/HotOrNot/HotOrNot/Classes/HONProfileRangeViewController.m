//
//  HONProfileRangeViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 7/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"

#import "HONProfileRangeViewController.h"

@interface HONProfileRangeViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UILabel *birthdayLabel;
@property (nonatomic) int ageRangeType;
@property (nonatomic, retain) UIButton *submitButton;
@property (nonatomic, retain) NSArray *ranges;
@end

@implementation HONProfileRangeViewController

- (id)init {
	if ((self = [super init])) {
		
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


- (void)dealloc {
	
}

- (BOOL)shouldAutorotate {
	return (NO);
}


#pragma mark - Data Calls
- (void)_submitAgeRange {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", _ageRangeType], @"age",
							nil];
	
	NSLog(@"PARMS:[%@]", params);
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_checkUsername", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPISetUserAgeGroup);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPISetUserAgeGroup parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_updateFail", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			[_progressHUD hide:YES];
			_progressHUD = nil;
			
			[[Mixpanel sharedInstance] track:@"Register - Submit"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			NSMutableArray *userInfo = [[HONAppDelegate infoForUser] mutableCopy];
			[userInfo setValue:[NSString stringWithFormat:@"%d", _ageRangeType] forKey:@"age"];
			[HONAppDelegate writeUserInfo:[userInfo copy]];
			
			[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"passed_registration"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
			}];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description],[HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	_ageRangeType = 1;
	_ranges = [NSArray arrayWithObjects:@"13-17", @"18-25", @"26-35", @"36+", nil];
	
	UIImageView *bgImageView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina4Inch]) ? @"firstRunBackground-568h" : @"firstRunBackground"]];
	bgImageView.frame = [UIScreen mainScreen].bounds;
	[self.view addSubview:bgImageView];
	
	UIImageView *captionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(33.0, 15.0, 254.0, ([HONAppDelegate isRetina4Inch]) ? 144.0 : 124.0)];
	captionImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina4Inch]) ? @"firstRunAgeRangeCopy-568h@2x" : @"firstRunAgeRangeCopy"];
	[self.view addSubview:captionImageView];
	
	UIImageView *inputBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(38.0, ([HONAppDelegate isRetina4Inch]) ? 192.0 : 147.0, 244.0, 44.0)];
	inputBGImageView.image = [UIImage imageNamed:@"firstRunInputBG"];
	inputBGImageView.userInteractionEnabled = YES;
	[self.view addSubview:inputBGImageView];
	
	_birthdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0, 8.0, 230.0, 30.0)];
	_birthdayLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:20];
	_birthdayLabel.textColor = [HONAppDelegate honGrey710Color];
	_birthdayLabel.text = [_ranges objectAtIndex:0];
	[inputBGImageView addSubview:_birthdayLabel];
	
	_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 269.0, 320.0, 53.0);
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_Active"] forState:UIControlStateHighlighted];
	[_submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_submitButton];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	
	_pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 216.0, 320.0, 216.0)];
	_pickerView.dataSource = self;
	_pickerView.delegate = self;
	_pickerView.showsSelectionIndicator = YES;
	[self.view addSubview:_pickerView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_goSubmit {
	[[Mixpanel sharedInstance] track:@"Register - Submit Range"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d", _ageRangeType], @"range", nil]];
	
	[self _submitAgeRange];
}


#pragma mark - PickerView DataSource
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return ([_ranges count]);
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return (1);
}

#pragma mark - PickerView Delegates
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	return (320.0);
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return ([_ranges objectAtIndex:row]);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	_ageRangeType = row + 1;
	
	[[Mixpanel sharedInstance] track:@"Register - Change Range"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d", _ageRangeType], @"range", nil]];
	
	_birthdayLabel.text = [_ranges objectAtIndex:row];
}

@end
