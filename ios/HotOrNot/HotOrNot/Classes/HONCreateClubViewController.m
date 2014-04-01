//
//  HONCreateClubViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/28/2014 @ 19:51 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "MBProgressHUD.h"

#import "HONCreateClubViewController.h"
#import "HONAnalyticsParams.h"
#import "HONAPICaller.h"
#import "HONColorAuthority.h"
#import "HONFontAllocator.h"
#import "HONImagingDepictor.h"
#import "HONHeaderView.h"
#import "HONClubCoverCameraViewController.h"
#import "HONUserClubInviteViewController.h"

@interface HONCreateClubViewController () <HONClubCoverCameraViewControllerDelegate>
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIView *formHolderView;
@property (nonatomic, strong) UIImageView *clubCoverImageView;
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
		if ([[(NSDictionary *)result objectForKey:@"result"] intValue] == 1) {
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			[self.navigationController pushViewController:[[HONUserClubInviteViewController alloc] initAsModal:NO] animated:YES];
			
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
	
	_formHolderView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	[self.view addSubview:_formHolderView];
	
	_clubNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_clubNameButton.frame = CGRectMake(0.0, kNavHeaderHeight, 320.0, 64.0);
	[_clubNameButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBackround_nonActive"] forState:UIControlStateNormal];
	[_clubNameButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBackround_Active"] forState:UIControlStateHighlighted];
	[_clubNameButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBackround_Active"] forState:UIControlStateSelected];
	[_clubNameButton addTarget:self action:@selector(_goClubName) forControlEvents:UIControlEventTouchUpInside];
	[_formHolderView addSubview:_clubNameButton];
	
	_clubCoverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstRunPhotoButton_nonActive"] highlightedImage:[UIImage imageNamed:@"firstRunPhotoButton_Active"]];
	_clubCoverImageView.frame = CGRectOffset(_clubCoverImageView.frame, 8.0, 85.0);
	[_formHolderView addSubview:_clubCoverImageView];
	
	[HONImagingDepictor maskImageView:_clubCoverImageView withMask:[UIImage imageNamed:@"maskAvatarBlack.png"]];
	
	UIButton *addImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	addImageButton.frame = _clubCoverImageView.frame;//CGRectMake(8.0, 85.0, 48.0, 48.0);
//	[addImageButton setBackgroundImage:[UIImage imageNamed:@"firstRunPhotoButton_nonActive"] forState:UIControlStateNormal];
//	[addImageButton setBackgroundImage:[UIImage imageNamed:@"firstRunPhotoButton_Active"] forState:UIControlStateHighlighted];
	[addImageButton addTarget:self action:@selector(_goCamera) forControlEvents:UIControlEventTouchDown];
//	[addImageButton addTarget:self action:@selector(_buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
//	[addImageButton addTarget:self action:@selector(_buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
	[_formHolderView addSubview:addImageButton];
	
	_clubNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(68.0, 92.0, 308.0, 30.0)];
	//[_clubNameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_clubNameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_clubNameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_clubNameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_clubNameTextField setReturnKeyType:UIReturnKeyDone];
	[_clubNameTextField setTextColor:[[HONColorAuthority sharedInstance] honBlueTextColor]];
	[_clubNameTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_clubNameTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_clubNameTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
	_clubNameTextField.keyboardType = UIKeyboardTypeAlphabet;
	_clubNameTextField.placeholder = @"Enter club name";
	_clubNameTextField.text = @"";
	[_clubNameTextField setTag:0];
	_clubNameTextField.delegate = self;
	[_formHolderView addSubview:_clubNameTextField];
	
	_clubNameCheckImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkButton_nonActive"]];
	_clubNameCheckImageView.frame = CGRectOffset(_clubNameCheckImageView.frame, 257.0, 77.0);
	_clubNameCheckImageView.alpha = 0.0;
	[_formHolderView addSubview:_clubNameCheckImageView];
	
	_blurbButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_blurbButton.frame = CGRectMake(0.0, 141.0, 320.0, 128.0);
	[_blurbButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBackround_nonActive"] forState:UIControlStateNormal];
	[_blurbButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBackround_Active"] forState:UIControlStateHighlighted];
	[_blurbButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBackround_Active"] forState:UIControlStateSelected];
	[_blurbButton addTarget:self action:@selector(_goBlurb) forControlEvents:UIControlEventTouchUpInside];
	[_formHolderView addSubview:_blurbButton];
	
	_blurbTextField = [[UITextField alloc] initWithFrame:CGRectMake(17.0, 157.0, 250.0, 90.0)];
	[_blurbTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_blurbTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_blurbTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_blurbTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_blurbTextField setReturnKeyType:UIReturnKeyDone];
	[_blurbTextField setTextColor:[[HONColorAuthority sharedInstance] honLightGreyTextColor]];
	[_blurbTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_blurbTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_blurbTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
	_blurbTextField.keyboardType = UIKeyboardTypeEmailAddress;
	_blurbTextField.placeholder = @"Enter club caption";
	_blurbTextField.text = @"";
	[_blurbTextField setTag:1];
	_blurbTextField.delegate = self;
	[_formHolderView addSubview:_blurbTextField];
	
	_blurbCheckImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkButton_nonActive"]];
	_blurbCheckImageView.frame = CGRectOffset(_blurbCheckImageView.frame, 257.0, 141.0);
	_blurbCheckImageView.alpha = 0.0;
	[_formHolderView addSubview:_blurbCheckImageView];
	
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Create Club"];
	[self.view addSubview:headerView];
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeButton.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
	[closeButton setBackgroundImage:[UIImage imageNamed:@"xButton_nonActive"] forState:UIControlStateNormal];
	[closeButton setBackgroundImage:[UIImage imageNamed:@"xButton_Active"] forState:UIControlStateHighlighted];
	[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:closeButton];
	
	UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_nonActive"] forState:UIControlStateNormal];
	[nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_Active"] forState:UIControlStateHighlighted];
	[nextButton addTarget:self action:@selector(_goNext) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:nextButton];
}

- (void)viewDidLoad {
//	[_blurbTextField addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
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
	[[Mixpanel sharedInstance] track:@"Create Club - Close" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goNext {
	[[Mixpanel sharedInstance] track:@"Create Club - Next" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
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
		_clubNameCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
		
		[[[UIAlertView alloc] initWithTitle:@"No Club Name!"
									message:@"You need to enter a name for your club!"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	
	} else
		[self _submitClub];
}


- (void)_buttonTouchDown:(id)sender {
	UIButton *button = (UIButton *)sender;
}

- (void)_buttonTouchUpInside:(id)sender {
	UIButton *button = (UIButton *)sender;
}



- (void)_goClubName {
	[[Mixpanel sharedInstance] track:@"Create Club - Enter Name" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
}

- (void)_goCamera {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Club - Choose Image"
									 withProperties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	HONClubCoverCameraViewController *clubCoverCameraViewController = [[HONClubCoverCameraViewController alloc] init];
	clubCoverCameraViewController.delegate = self;
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_STATUS_BAR_TINT" object:@"NO"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:clubCoverCameraViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goBlurb {
	[[Mixpanel sharedInstance] track:@"Create Club - Enter Description" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
}


#pragma mark - Notifications
//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//	UITextView *tv = object;
//	CGFloat topCorrect = MAX(0.0, ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale]) * 0.5);
//	//CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale]) * 0.5;
//	//topCorrect = (topCorrect < 0.0) ? 0.0 : topCorrect;
//	tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
//}

- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
	//	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	
	if ([_clubNameTextField isFirstResponder]) {
		_clubNameCheckImageView.alpha = 1.0;
		_clubNameCheckImageView.image = [UIImage imageNamed:@"checkButton_nonActive"];
	
	} else if ([_blurbTextField isFirstResponder]) {
		_blurbCheckImageView.alpha = 1.0;
		_blurbCheckImageView.image = [UIImage imageNamed:@"checkButton_nonActive"];
	}
}


#pragma mark - ClubCoverCameraViewController Delegates
- (void)clubCoverCameraViewController:(HONClubCoverCameraViewController *)viewController didFinishProcessingImage:(UIImage *)image withPrefix:(NSString *)imagePrefix {
	NSLog(@"\n**_[clubCoverCameraViewController:didFinishProcessingImage:(%@)withPrefix:(%@)]_**\n", NSStringFromCGSize(image.size), imagePrefix);
	
	UIImage *thumbImage = [HONImagingDepictor scaleImage:[HONImagingDepictor cropImage:image toRect:CGRectMake(0.0, (image.size.height - image.size.width) * 0.5, image.size.width, image.size.width)] toSize:CGSizeMake(kSnapThumbSize.width * 2.0, kSnapThumbSize.height * 2.0)];
	_clubCoverImageView.image = thumbImage;
//	_clubCoverImageView.hi
	
	_clubImagePrefix = imagePrefix;
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
