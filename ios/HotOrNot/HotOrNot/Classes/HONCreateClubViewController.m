//
//  HONCreateClubViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/28/2014 @ 19:51 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "MBProgressHUD.h"

#import "HONCreateClubViewController.h"
#import "HONHeaderView.h"
#import "HONClubCoverCameraViewController.h"
#import "HONUserClubInviteViewController.h"

@interface HONCreateClubViewController () <HONClubCoverCameraViewControllerDelegate>
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIImageView *clubCoverImageView;
@property (nonatomic, strong) UIButton *addImageButton;
@property (nonatomic, strong) UIButton *clubNameButton;
@property (nonatomic, strong) UIButton *blurbButton;
@property (nonatomic, strong) UITextField *clubNameTextField;
@property (nonatomic, strong) UITextField *blurbTextField;
@property (nonatomic, strong) UIImageView *clubNameCheckImageView;
@property (nonatomic, strong) UIImageView *blurbCheckImageView;
@property (nonatomic, strong) NSString *clubName;
@property (nonatomic, strong) NSString *clubBlurb;
@property (nonatomic, strong) NSString *clubImagePrefix;
@end


@implementation HONCreateClubViewController

- (id)init {
	if ((self = [super init])) {
		_clubName = @"";
		_clubBlurb = @"";
		_clubImagePrefix = @"";
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
- (void)_submitClub {
	[[HONAPICaller sharedInstance] createClubWithTitle:_clubName withDescription:_clubBlurb withImagePrefix:_clubImagePrefix completion:^(NSObject *result) {
		if ((NSDictionary *)result != nil) {
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			[self.navigationController pushViewController:[[HONUserClubInviteViewController alloc] initWithClub:[HONUserClubVO clubWithDictionary:(NSDictionary *)result]] animated:YES];
			
		} else {
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			
			[_progressHUD setYOffset:-80.0];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = @"Error!";
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
		}
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Add Club"];
	[self.view addSubview:headerView];
	
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeButton.frame = CGRectMake(1.0, 1.0, 93.0, 44.0);
	[closeButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
	[closeButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
	[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:closeButton];
	
	UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextButton.frame = CGRectMake(227.0, 1.0, 93.0, 44.0);
	[nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_nonActive"] forState:UIControlStateNormal];
	[nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_Active"] forState:UIControlStateHighlighted];
	[nextButton addTarget:self action:@selector(_goNext) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:nextButton];
	
	_clubNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_clubNameButton.frame = CGRectMake(0.0, kNavHeaderHeight, 320.0, 64.0);
	[_clubNameButton setBackgroundImage:[UIImage imageNamed:@"viewCellBG"] forState:UIControlStateNormal];
	[_clubNameButton setBackgroundImage:[UIImage imageNamed:@"viewCellSelectedBG"] forState:UIControlStateHighlighted];
	[_clubNameButton setBackgroundImage:[UIImage imageNamed:@"viewCellSelectedBG"] forState:UIControlStateSelected];
	[_clubNameButton addTarget:self action:@selector(_goClubName) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_clubNameButton];
	
	_clubCoverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, 72.0, 48.0, 48.0)];
	[self.view addSubview:_clubCoverImageView];
	
	[HONImagingDepictor maskImageView:_clubCoverImageView withMask:[UIImage imageNamed:@"maskAvatarBlack.png"]];
	
	_addImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_addImageButton.frame = _clubCoverImageView.frame;
	[_addImageButton setBackgroundImage:[UIImage imageNamed:@"defaultAvatarBackground"] forState:UIControlStateNormal];
	[_addImageButton setBackgroundImage:[UIImage imageNamed:@"defaultAvatarBackground"] forState:UIControlStateHighlighted];
	[_addImageButton addTarget:self action:@selector(_goCamera) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:_addImageButton];
	
	_clubNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(64.0, 87.0, 220.0, 22.0)];
	//[_clubNameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_clubNameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_clubNameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_clubNameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_clubNameTextField setReturnKeyType:UIReturnKeyDone];
	[_clubNameTextField setTextColor:[UIColor blackColor]];
	[_clubNameTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_clubNameTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_clubNameTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
	_clubNameTextField.keyboardType = UIKeyboardTypeAlphabet;
	_clubNameTextField.placeholder = @"Club Name";
	_clubNameTextField.text = @"";
	[_clubNameTextField setTag:0];
	_clubNameTextField.delegate = self;
	[self.view addSubview:_clubNameTextField];
	
	_clubNameCheckImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkIcon"]];
	_clubNameCheckImageView.frame = CGRectOffset(_clubNameCheckImageView.frame, 258.0, 65.0);
	_clubNameCheckImageView.alpha = 0.0;
	[self.view addSubview:_clubNameCheckImageView];
	
	_blurbButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_blurbButton.frame = CGRectMake(0.0, 128.0, 320.0, 128.0);
	[_blurbButton setBackgroundImage:[UIImage imageNamed:@"viewCellBG"] forState:UIControlStateNormal];
	[_blurbButton setBackgroundImage:[UIImage imageNamed:@"viewCellSelectedBG"] forState:UIControlStateHighlighted];
	[_blurbButton setBackgroundImage:[UIImage imageNamed:@"viewCellSelectedBG"] forState:UIControlStateSelected];
	[_blurbButton addTarget:self action:@selector(_goBlurb) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_blurbButton];
	
	_blurbTextField = [[UITextField alloc] initWithFrame:CGRectMake(14.0, 141.0, 250.0, 22.0)];
	[_blurbTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_blurbTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_blurbTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_blurbTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_blurbTextField setReturnKeyType:UIReturnKeyDone];
	[_blurbTextField setTextColor:[[HONColorAuthority sharedInstance] honLightGreyTextColor]];
	[_blurbTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_blurbTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_blurbTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
	_blurbTextField.keyboardType = UIKeyboardTypeEmailAddress;
	_blurbTextField.placeholder = @"Club description";
	_blurbTextField.text = @"";
	[_blurbTextField setTag:1];
	_blurbTextField.delegate = self;
	[self.view addSubview:_blurbTextField];
	
	_blurbCheckImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkIcon"]];
	_blurbCheckImageView.frame = CGRectOffset(_blurbCheckImageView.frame, 258.0, 123.0);
	_blurbCheckImageView.alpha = 0.0;
	[self.view addSubview:_blurbCheckImageView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goClose {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Club - Close"];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goNext {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Club - Next"];
	
	if ([_clubNameTextField isFirstResponder])
		[_clubNameTextField resignFirstResponder];
	
	if ([_blurbTextField isFirstResponder])
		[_blurbTextField resignFirstResponder];
	
	
	[_clubNameButton setSelected:NO];
	[_blurbButton setSelected:NO];
	
	if ([_clubName length] == 0) {
		[_clubNameButton setSelected:YES];
		[_clubNameTextField becomeFirstResponder];
		
		_clubNameCheckImageView.alpha = 1.0;
		_clubNameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		
		[[[UIAlertView alloc] initWithTitle:@"No Club Name!"
									message:@"You need to enter a name for your club!"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	
	} else
		[self _submitClub];
//		[self.navigationController pushViewController:[[HONUserClubInviteViewController alloc] initWithClub:nil] animated:YES];
}


- (void)_goClubName {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Club - Enter Name"];
	
	[_clubNameButton setSelected:YES];
	[_blurbButton setSelected:NO];
}

- (void)_goCamera {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Club - Choose Image"];
	
	HONClubCoverCameraViewController *clubCoverCameraViewController = [[HONClubCoverCameraViewController alloc] init];
	clubCoverCameraViewController.delegate = self;
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:clubCoverCameraViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goBlurb {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Club - Enter Description"];
	
	[_blurbButton setSelected:YES];
	[_clubNameButton setSelected:NO];
}


#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
//	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	
	if ([_clubNameTextField isFirstResponder]) {
		_clubNameCheckImageView.alpha = 1.0;
		_clubNameCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
	
	} else if ([_blurbTextField isFirstResponder]) {
		_blurbCheckImageView.alpha = 1.0;
		_blurbCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
	}
}


#pragma mark - ClubCoverCameraViewController Delegates
- (void)clubCoverCameraViewController:(HONClubCoverCameraViewController *)viewController didFinishProcessingImage:(UIImage *)image withPrefix:(NSString *)imagePrefix {
	NSLog(@"\n**_[clubCoverCameraViewController:didFinishProcessingImage:(%@)withPrefix:(%@)]_**\n", NSStringFromCGSize(image.size), imagePrefix);
	
	UIImage *thumbImage = [HONImagingDepictor scaleImage:[HONImagingDepictor cropImage:image toRect:CGRectMake(0.0, (image.size.height - image.size.width) * 0.5, image.size.width, image.size.width)] toSize:CGSizeMake(kSnapThumbSize.width * 2.0, kSnapThumbSize.height * 2.0)];
	_clubCoverImageView.image = thumbImage;
	_clubImagePrefix = imagePrefix;
	
	[_addImageButton setBackgroundImage:nil forState:UIControlStateNormal];
	[_addImageButton setBackgroundImage:nil forState:UIControlStateHighlighted];
}

#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	if (textField.tag == 0) {
		_clubNameCheckImageView.alpha = 0.0;
		[_clubNameButton setSelected:YES];
		[_blurbButton setSelected:NO];
		
	} else if (textField.tag == 1) {
		_blurbCheckImageView.alpha = 0.0;
		[_clubNameButton setSelected:NO];
		[_blurbButton setSelected:YES];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_textFieldTextDidChangeChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:textField];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return (YES);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	_clubName = _clubNameTextField.text;
	_clubBlurb = _blurbTextField.text;

	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UITextFieldTextDidChangeNotification"
												  object:textField];
}

- (void)_onTextEditingDidEnd:(id)sender {
	_clubName = _clubNameTextField.text;
	_clubBlurb = _blurbTextField.text;
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
}

@end
