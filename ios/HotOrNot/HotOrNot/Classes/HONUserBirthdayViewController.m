//
//  HONUserBirthdayViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 7/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"

#import "HONUserBirthdayViewController.h"
#import "HONProfileRangeViewController.h"

@interface HONUserBirthdayViewController ()
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UILabel *birthdayLabel;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, retain) UIButton *submitButton;
@end

@implementation HONUserBirthdayViewController

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
- (void)_submitBirthday {
	[[Mixpanel sharedInstance] track:@"Register - Submit Birthday"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  _birthday, @"birthday", nil]];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 7], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							_birthday, @"birthday",
							nil];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_checkUsername", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
			
			if (![[userResult objectForKey:@"result"] isEqualToString:@"fail"]) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
				
				[HONAppDelegate writeUserInfo:userResult];
				
			} else {
				if (_progressHUD == nil)
					_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"hud_usernameTaken", nil);
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
			}
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
	
	UIImageView *bgImageView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"firstRunBackground-568h" : @"firstRunBackground"]];
	bgImageView.frame = [UIScreen mainScreen].bounds;
	[self.view addSubview:bgImageView];
	
	UIImageView *inputBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(38.0, ([HONAppDelegate isRetina5]) ? 192.0 : 163.0, 244.0, 44.0)];
	inputBGImageView.image = [UIImage imageNamed:@"firstRunInputBG"];
	[self.view addSubview:inputBGImageView];
	
	_birthdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0, 8.0, 230.0, 30.0)];
	[inputBGImageView addSubview:_birthdayLabel];
	
	_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 269.0, 320.0, 53.0);
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_Active"] forState:UIControlStateHighlighted];
	[_submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_submitButton];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	
	_datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 216.0, 320.0, 216.0)];
	_datePicker.date = [dateFormat dateFromString:@"2000-01-01"];
	_datePicker.datePickerMode = UIDatePickerModeDate;
	_datePicker.minimumDate = [dateFormat dateFromString:@"1900-01-01"];
	_datePicker.maximumDate = [dateFormat dateFromString:@"2000-01-01"];
	[_datePicker addTarget:self action:@selector(_pickerValueChanged)forControlEvents:UIControlEventValueChanged];
	
	[self.view addSubview:_datePicker];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_goSubmit {
	
}

- (void)_pickerValueChanged {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	
	_birthdayLabel.text = [dateFormat stringFromDate:_datePicker.date];
}

@end
