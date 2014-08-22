//
//  HONClubSettingsViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/01/2014 @ 14:06 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONClubSettingsViewController.h"
#import "HONHeaderView.h"
#import "HONClubCoverCameraViewController.h"
#import "HONInviteContactsViewController.h"


@interface HONClubSettingsViewController () <HONClubCoverCameraViewControllerDelegate>
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONUserClubVO *userClubVO;
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


@implementation HONClubSettingsViewController

- (id)initWithClub:(HONUserClubVO *)userClubVO {
	if ((self = [super init])) {
		_userClubVO = userClubVO;
		_clubName = _userClubVO.clubName;
		_clubBlurb = _userClubVO.blurb;
		_clubImagePrefix = _userClubVO.coverImagePrefix;
	}
	
	return (self);
}


#pragma mark - Data Calls
- (void)_updateClub {
	[[HONAPICaller sharedInstance] editClubWithClubID:_userClubVO.clubID withTitle:_clubName withDescription:_clubBlurb withImagePrefix:_clubImagePrefix completion:^(NSDictionary *result) {
		if ([[result objectForKey:@"result"] intValue] == 1) {
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			[self.navigationController pushViewController:[[HONInviteContactsViewController alloc] initWithClub:_userClubVO viewControllerPushed:YES] animated:YES];
			
		} else {
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			
			[_progressHUD setYOffset:-80.0];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = @"Error!";
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
		}
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_formHolderView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	[self.view addSubview:_formHolderView];
	
	_clubNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_clubNameButton.frame = CGRectMake(0.0, kNavHeaderHeight, 320.0, 64.0);
	[_clubNameButton setBackgroundImage:[UIImage imageNamed:@"viewCellBG_normal"] forState:UIControlStateNormal];
	[_clubNameButton setBackgroundImage:[UIImage imageNamed:@"viewCellBG_selected"] forState:UIControlStateHighlighted];
	[_clubNameButton setBackgroundImage:[UIImage imageNamed:@"viewCellBG_selected"] forState:UIControlStateSelected];
	[_clubNameButton addTarget:self action:@selector(_goClubName) forControlEvents:UIControlEventTouchUpInside];
	[_formHolderView addSubview:_clubNameButton];
	
	_clubCoverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatarPlaceholder"]];
	_clubCoverImageView.frame = CGRectOffset(_clubCoverImageView.frame, 8.0, 85.0);
	[_formHolderView addSubview:_clubCoverImageView];
	
	[[HONImageBroker sharedInstance] maskView:_clubCoverImageView withMask:[UIImage imageNamed:@"avatarMask"]];
	
	if ([_clubImagePrefix length] > 0) {
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			_clubCoverImageView.image = image;
			[UIView animateWithDuration:0.25 animations:^(void) {
				_clubCoverImageView.alpha = 1.0;
			} completion:nil];
		};
		
		void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONAPICaller sharedInstance] normalizePrefixForImageURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeClubs completion:nil];
			
			_clubCoverImageView.image = [UIImage imageNamed:@"defaultClubCover"];
			[UIView animateWithDuration:0.25 animations:^(void) {
				_clubCoverImageView.alpha = 1.0;
			} completion:nil];
		};
		
		[_clubCoverImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_clubImagePrefix stringByAppendingString:kSnapThumbSuffix]]
																	 cachePolicy:kURLRequestCachePolicy
																 timeoutInterval:[HONAppDelegate timeoutInterval]]
								   placeholderImage:[UIImage imageNamed:@"avatarPlaceholder"]
											success:imageSuccessBlock
											failure:imageFailureBlock];
	}
	
	
	UIButton *addImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	addImageButton.frame = _clubCoverImageView.frame;
	[addImageButton addTarget:self action:@selector(_goCamera) forControlEvents:UIControlEventTouchDown];
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
	_clubNameTextField.placeholder = @"";
	_clubNameTextField.text = _clubName;
	[_clubNameTextField setTag:0];
	_clubNameTextField.delegate = self;
	[_formHolderView addSubview:_clubNameTextField];
	
	_clubNameCheckImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkIcon"]];
	_clubNameCheckImageView.frame = CGRectOffset(_clubNameCheckImageView.frame, 257.0, 77.0);
	_clubNameCheckImageView.alpha = 0.0;
	[_formHolderView addSubview:_clubNameCheckImageView];
	
	_blurbButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_blurbButton.frame = CGRectMake(0.0, 141.0, 320.0, 128.0);
	[_blurbButton setBackgroundImage:[UIImage imageNamed:@"viewCellBG_normal"] forState:UIControlStateNormal];
	[_blurbButton setBackgroundImage:[UIImage imageNamed:@"viewCellBG_selected"] forState:UIControlStateHighlighted];
	[_blurbButton setBackgroundImage:[UIImage imageNamed:@"viewCellBG_selected"] forState:UIControlStateSelected];
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
	_blurbTextField.text = _clubBlurb;
	[_blurbTextField setTag:1];
	_blurbTextField.delegate = self;
	[_formHolderView addSubview:_blurbTextField];
	
	_blurbCheckImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkIcon"]];
	_blurbCheckImageView.frame = CGRectOffset(_blurbCheckImageView.frame, 257.0, 141.0);
	_blurbCheckImageView.alpha = 0.0;
	[_formHolderView addSubview:_blurbCheckImageView];
	
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Edit Club"];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 1.0, 93.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:backButton];
	
	UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextButton.frame = CGRectMake(222.0, 0.0, 93.0, 44.0);
	[nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_nonActive"] forState:UIControlStateNormal];
	[nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_Active"] forState:UIControlStateHighlighted];
	[nextButton addTarget:self action:@selector(_goNext) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:nextButton];
}


#pragma mark - Navigation
- (void)_goBack {

	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goNext {

	
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
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
		
	} else
		[self _updateClub];
}


- (void)_goClubName {

	
	[_clubNameButton setSelected:YES];
	[_blurbButton setSelected:NO];
}

- (void)_goCamera {
	
	HONClubCoverCameraViewController *clubCoverCameraViewController = [[HONClubCoverCameraViewController alloc] init];
	clubCoverCameraViewController.delegate = self;
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:clubCoverCameraViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goBlurb {
	
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
	
	UIImage *thumbImage = [[HONImageBroker sharedInstance] scaleImage:[[HONImageBroker sharedInstance] cropImage:image toRect:CGRectMake(0.0, (image.size.height - image.size.width) * 0.5, image.size.width, image.size.width)] toSize:CGSizeMake(kSnapThumbSize.width * 2.0, kSnapThumbSize.height * 2.0)];
	_clubCoverImageView.image = thumbImage;
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
