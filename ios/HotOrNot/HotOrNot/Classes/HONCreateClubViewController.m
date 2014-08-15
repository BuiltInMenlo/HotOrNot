//
//  HONCreateClubViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/28/2014 @ 19:51 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

#import "NSString+DataTypes.h"
#import "UIImage+fixOrientation.h"
#import "UIImageView+AFNetworking.h"

#import "MBProgressHUD.h"

#import "HONCreateClubViewController.h"
#import "HONHeaderView.h"
#import "HONClubCoverCameraViewController.h"
#import "HONInviteContactsViewController.h"

@interface HONCreateClubViewController () //<HONClubCoverCameraViewControllerDelegate>
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIImageView *clubCoverImageView;
@property (nonatomic, strong) UIButton *addImageButton;
@property (nonatomic, strong) NSString *clubName;
@property (nonatomic, strong) NSString *clubImagePrefix;
@property (nonatomic, strong) UITextField *clubNameTextField;
@property (nonatomic, strong) UIButton *clubNameButton;
@property (nonatomic, strong) UIImageView *clubNameCheckImageView;
@property (nonatomic, strong) NSString *clubBlurb;
//@property (nonatomic, strong) UITextField *blurbTextField;
//@property (nonatomic, strong) UIButton *blurbButton;
//@property (nonatomic, strong) UIImageView *blurbCheckImageView;
@property (nonatomic, strong) ALAssetsLibrary *library;
@property (nonatomic) BOOL isAlbumFound;

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic) BOOL isFirstAppearance;
@property (nonatomic) int totaAlbumAssets;
@end


@implementation HONCreateClubViewController

- (id)init {
	if ((self = [super init])) {
		_clubName = @"";
		_isFirstAppearance = YES;
		
		_totaAlbumAssets = 0;
		_library = [[ALAssetsLibrary alloc] init];
		[self _searchForAlbum];
	}
	
	return (self);
}

- (id)initWithClubTitle:(NSString *)title {
	if ((self = [self init])) {
		_clubName = title;
	}
	
	return (self);
}


#pragma mark - Data Calls
- (void)_uploadPhotos:(UIImage *)image {
	NSString *filename = [NSString stringWithFormat:@"%@_%d", [[[HONDeviceIntrinsics sharedInstance] identifierForVendorWithoutSeperators:YES] lowercaseString], (int)[[NSDate date] timeIntervalSince1970]];
	_clubImagePrefix = [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], filename];
	
	NSLog(@"FILE PREFIX: %@", _clubImagePrefix);
	
	UIImage *largeImage = [[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:image toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)];
	UIImage *tabImage = [[HONImageBroker sharedInstance] cropImage:largeImage toRect:CGRectMake(0.0, 0.0, kSnapTabSize.width * 2.0, kSnapTabSize.height * 2.0)];
	
	UIImage *thumbImage = [[HONImageBroker sharedInstance] cropImage:tabImage toRect:CGRectMake(0.0, (image.size.height - image.size.width) * 0.5, image.size.width, image.size.width)];
	_clubCoverImageView.image = thumbImage;
	
	[_addImageButton setBackgroundImage:nil forState:UIControlStateNormal];
	[_addImageButton setBackgroundImage:nil forState:UIControlStateHighlighted];
	
	[[HONAPICaller sharedInstance] uploadPhotosToS3:@[UIImageJPEGRepresentation(largeImage, [HONAppDelegate compressJPEGPercentage]), UIImageJPEGRepresentation(tabImage, [HONAppDelegate compressJPEGPercentage] * 0.85)] intoBucketType:HONS3BucketTypeClubs withFilename:filename completion:^(NSObject *result) {
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		[self _validateClubNameWithAlerts:NO];
	}];
}


- (void)_submitClub {
	[[HONClubAssistant sharedInstance] writePreClubWithTitle:_clubName andBlurb:@"" andCoverPrefixURL:_clubImagePrefix];
	[self.navigationController pushViewController:[[HONInviteContactsViewController alloc] initAsViewControllerPushed:YES] animated:YES];
	
//	[[HONAPICaller sharedInstance] createClubWithTitle:_clubName withDescription:@"" withImagePrefix:_clubImagePrefix completion:^(NSDictionary *result) {
//		if (result != nil) {
//			if (_progressHUD != nil) {
//				[_progressHUD hide:YES];
//				_progressHUD = nil;
//			}
//			
//#if SC_ACCT_BUILD == 0
//			if ([self.delegate respondsToSelector:@selector(createClubViewController:didCreateClub:)])
//				[self.delegate createClubViewController:self didCreateClub:[HONUserClubVO clubWithDictionary:result]];
//			
//			[self.navigationController pushViewController:[[HONInviteContactsViewController alloc] initWithClub:[HONUserClubVO clubWithDictionary:result] viewControllerPushed:YES] animated:YES];
//#else
//	[[[UIAlertView alloc] initWithTitle:@"WRITE THIS DOWN!"
//										message:[@"Club ID = " stringByAppendingString:[result objectForKey:@"id"]]
//									   delegate:nil
//							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
//							  otherButtonTitles:nil] show];
//			
//			[self.navigationController dismissViewControllerAnimated:YES completion:^(void) {
//				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_NEWS_TAB" object:@"Y"];
//				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUBS_TAB" object:@"Y"];
//			}];
//#endif
//		} else {
//			if (_progressHUD == nil)
//				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
//			[_progressHUD setYOffset:-80.0];
//			_progressHUD.minShowTime = kHUDTime;
//			_progressHUD.mode = MBProgressHUDModeCustomView;
//			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
//			_progressHUD.labelText = @"Error!";
//			[_progressHUD show:NO];
//			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
//			_progressHUD = nil;
//		}
//	}];
}


#pragma mark - Data Manip
- (void)_validateClubNameWithAlerts:(BOOL)showAlerts {
	if ([_clubNameTextField isFirstResponder])
		[_clubNameTextField resignFirstResponder];
	
//	if ([_blurbTextField isFirstResponder])
//		[_blurbTextField resignFirstResponder];
	
	
	[_clubNameButton setSelected:NO];
//	[_blurbButton setSelected:NO];
	
	
	if ([_clubName length] == 0) {
		if (showAlerts) {
			_clubNameCheckImageView.alpha = 1.0;
			_clubNameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
			
			[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_club", @"No Club Name!")
										message:NSLocalizedString(@"no_club_msg", @"You need to enter a name for your club!")
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
		}
		[self _goClubName];
		
	} else {
		if (showAlerts) {
			if ([_clubName rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/'"]].location != NSNotFound) {
				_clubNameCheckImageView.alpha = 1.0;
				_clubNameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
				
				[[[UIAlertView alloc] initWithTitle:@"Invalid club name!"
											message: NSLocalizedString(@"invalid_msg", @"You cannot have / or ' in your club's name")
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
				[self _goClubName];
			
			} else
				[self _submitClub];
			
		} else
			[self _submitClub];
	}
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_clubBlurb = @"";
	_clubImagePrefix = [[HONClubAssistant sharedInstance] defaultCoverImageURL];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"header_addclub", nil)];
	[self.view addSubview:headerView];
	
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeButton.frame = CGRectMake(1.0, 1.0, 93.0, 44.0);
	[closeButton setBackgroundImage:[UIImage imageNamed:@"closeButtonBlue_nonActive"] forState:UIControlStateNormal];
	[closeButton setBackgroundImage:[UIImage imageNamed:@"closeButtonBlue_Active"] forState:UIControlStateHighlighted];
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
	[_clubNameButton setBackgroundImage:[UIImage imageNamed:@"viewCellBG_normal"] forState:UIControlStateNormal];
	[_clubNameButton setBackgroundImage:[UIImage imageNamed:@"viewCellBG_selected"] forState:UIControlStateHighlighted];
	[_clubNameButton setBackgroundImage:[UIImage imageNamed:@"viewCellBG_selected"] forState:UIControlStateSelected];
	[_clubNameButton addTarget:self action:@selector(_goClubName) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_clubNameButton];
	
	_clubCoverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, 72.0, 48.0, 48.0)];
	[self.view addSubview:_clubCoverImageView];
	
	[[HONImageBroker sharedInstance] maskView:_clubCoverImageView withMask:[UIImage imageNamed:@"avatarMask"]];
	
	_addImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_addImageButton.frame = _clubCoverImageView.frame;
	[_addImageButton setBackgroundImage:[UIImage imageNamed:@"clubCoverButton_nonActive"] forState:UIControlStateNormal];
	[_addImageButton setBackgroundImage:[UIImage imageNamed:@"clubCoverButton_Active"] forState:UIControlStateHighlighted];
	[_addImageButton addTarget:self action:@selector(_goCamera) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_addImageButton];
	
	_clubNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(72.0, 87.0, 220.0, 22.0)];
	[_clubNameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_clubNameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_clubNameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_clubNameTextField setReturnKeyType:UIReturnKeyDone];
	[_clubNameTextField setTextColor:[UIColor blackColor]];
	[_clubNameTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_clubNameTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_clubNameTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:16];
	_clubNameTextField.keyboardType = UIKeyboardTypeAlphabet;
	_clubNameTextField.placeholder = NSLocalizedString(@"club_name", nil); //@"Club Name";
	_clubNameTextField.text = _clubName;
	[_clubNameTextField setTag:0];
	_clubNameTextField.delegate = self;
	[self.view addSubview:_clubNameTextField];
	
	_clubNameCheckImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkIcon"]];
	_clubNameCheckImageView.frame = CGRectOffset(_clubNameCheckImageView.frame, 258.0, 65.0);
	_clubNameCheckImageView.alpha = 0.0;
	[self.view addSubview:_clubNameCheckImageView];
	
//	_blurbButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	_blurbButton.frame = CGRectMake(0.0, 128.0, 320.0, 135.0);
//	[_blurbButton setBackgroundImage:[UIImage imageNamed:@"clubDescription_normal"] forState:UIControlStateNormal];
//	[_blurbButton setBackgroundImage:[UIImage imageNamed:@"clubDescription_selected"] forState:UIControlStateHighlighted];
//	[_blurbButton setBackgroundImage:[UIImage imageNamed:@"clubDescription_selected"] forState:UIControlStateSelected];
//	[_blurbButton addTarget:self action:@selector(_goBlurb) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:_blurbButton];
//	
//	_blurbTextField = [[UITextField alloc] initWithFrame:CGRectMake(14.0, 141.0, 250.0, 22.0)];
//	[_blurbTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
//	[_blurbTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
//	[_blurbTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
//	_blurbTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
//	[_blurbTextField setReturnKeyType:UIReturnKeyDone];
//	[_blurbTextField setTextColor:[[HONColorAuthority sharedInstance] honLightGreyTextColor]];
//	[_blurbTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
//	[_blurbTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
//	_blurbTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
//	_blurbTextField.keyboardType = UIKeyboardTypeEmailAddress;
//	_blurbTextField.placeholder = @"Club description";
//	_blurbTextField.text = @"";
//	[_blurbTextField setTag:1];
//	_blurbTextField.delegate = self;
//	[self.view addSubview:_blurbTextField];
//	
//	_blurbCheckImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkIcon"]];
//	_blurbCheckImageView.frame = CGRectOffset(_blurbCheckImageView.frame, 258.0, 123.0);
//	_blurbCheckImageView.alpha = 0.0;
//	[self.view addSubview:_blurbCheckImageView];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewWillAppear:animated];
	
	[_clubNameTextField becomeFirstResponder];
}


#pragma mark - Navigation
- (void)_goClose {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CLOSED_CREATE_CLUB" object:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goNext {
	NSLog(@"_clubName:[%@] _clubImagePrefix:[%@]", _clubName, _clubImagePrefix);
	
	if ([_clubName length] == 0){
		//[self _goCamera];
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"please_enter_club", nil)
									message:@""
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
	}
	
	else{
		if ( ([_clubImagePrefix length] == 0) || [_clubImagePrefix isEqualToString: [[HONClubAssistant sharedInstance] defaultCoverImageURL]] ) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:NSLocalizedString(@"are_you_sure_create_club", nil)
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_yes", nil)
													  otherButtonTitles:NSLocalizedString(@"select_cover", nil), nil];
			[alertView setTag:0];
			[alertView show];

		}
		else{
			[self _validateClubNameWithAlerts:YES];
			_clubImagePrefix = @"";
		}
	}
		
}

- (void)_goCamera {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		_imagePicker = [[UIImagePickerController alloc] init];
		_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		_imagePicker.delegate = self;
		_imagePicker.allowsEditing = NO;
		_imagePicker.navigationBarHidden = YES;
		_imagePicker.toolbarHidden = YES;
		_imagePicker.navigationBar.barStyle = UIBarStyleDefault;
		_imagePicker.view.backgroundColor = [UIColor whiteColor];
		_imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
		
		self.modalPresentationStyle = UIModalPresentationCurrentContext;
		[self.navigationController presentViewController:_imagePicker animated:YES completion:^(void) {
		}];
	}
	
//	HONClubCoverCameraViewController *clubCoverCameraViewController = [[HONClubCoverCameraViewController alloc] init];
//	clubCoverCameraViewController.delegate = self;
//	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:clubCoverCameraViewController];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:NO completion:nil];
}


- (void)_goClubName {
	[_clubNameButton setSelected:YES];
	[_clubNameTextField becomeFirstResponder];
//	[_blurbButton setSelected:NO];
}

- (void)_goBlurb {
//	[_blurbButton setSelected:YES];
//	[__blurbTextField becomeFirstResponder];
	[_clubNameButton setSelected:NO];
}


#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
//	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	
	if ([_clubNameTextField isFirstResponder]) {
		_clubNameCheckImageView.alpha = (int)([_clubNameTextField.text length] > 1);
		_clubNameCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
		
		_clubName = _clubNameTextField.text;
	
//	} else if ([_blurbTextField isFirstResponder]) {
//		_blurbCheckImageView.alpha = 1.0;
//		_blurbCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
	}
}


//#pragma mark - ClubCoverCameraViewController Delegates
//- (void)clubCoverCameraViewController:(HONClubCoverCameraViewController *)viewController didFinishProcessingImage:(UIImage *)image withPrefix:(NSString *)imagePrefix {
//	NSLog(@"\n**_[clubCoverCameraViewController:didFinishProcessingImage:(%@)withPrefix:(%@)]_**\n", NSStringFromCGSize(image.size), imagePrefix);
//	
//	UIImage *thumbImage = [[HONImageBroker sharedInstance] scaleImage:[[HONImageBroker sharedInstance] cropImage:image toRect:CGRectMake(0.0, (image.size.height - image.size.width) * 0.5, image.size.width, image.size.width)] toSize:CGSizeMake(kSnapThumbSize.width * 2.0, kSnapThumbSize.height * 2.0)];
//	_clubCoverImageView.image = thumbImage;
//	_clubImagePrefix = imagePrefix;
//	
//	[_addImageButton setBackgroundImage:nil forState:UIControlStateNormal];
//	[_addImageButton setBackgroundImage:nil forState:UIControlStateHighlighted];
//}


#pragma mark - ImagePickerViewController Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *processedImage = [[HONImageBroker sharedInstance] prepForUploading:[info objectForKey:UIImagePickerControllerOriginalImage]];
	
	NSLog(@"PROCESSED IMAGE:[%@]", NSStringFromCGSize(processedImage.size));
	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, processedImage.size.width, processedImage.size.height)];
	[canvasView addSubview:[[UIImageView alloc] initWithImage:processedImage]];
	
	processedImage = [[HONImageBroker sharedInstance] createImageFromView:canvasView];
	[self _uploadPhotos:processedImage];
	
	[_imagePicker dismissViewControllerAnimated:YES completion:^(void) {
		if ([_clubName length] == 0)
			[self _goClubName];
	}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[_imagePicker dismissViewControllerAnimated:YES completion:^(void){
//		[self.navigationController dismissViewControllerAnimated:NO completion:^(void){}];
		
		if ([_clubName length] == 0)
			[self _goClubName];
	}];
}


#pragma mark - NavigationController Delegates
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	navigationController.navigationBar.barStyle = UIBarStyleDefault;
	[viewController.navigationItem setTitle:NSLocalizedString(@"add_photo", nil)];
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	if (textField.tag == 0) {
		_clubNameCheckImageView.alpha = 0.0;
		[_clubNameButton setSelected:YES];
//		[_blurbButton setSelected:NO];
		
	} else if (textField.tag == 1) {
//		_blurbCheckImageView.alpha = 0.0;
		[_clubNameButton setSelected:NO];
//		[_blurbButton setSelected:YES];
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
//	_clubBlurb = _blurbTextField.text;

	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UITextFieldTextDidChangeNotification"
												  object:textField];
}

- (void)_onTextEditingDidEnd:(id)sender {
	_clubName = _clubNameTextField.text;
//	_clubBlurb = _blurbTextField.text;
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
}


#pragma mark - Device Functions
- (void)_searchForAlbum {
	__weak HONCreateClubViewController *weakSelf = self;
	__block ALAssetsGroup *assetsGroup;
	
	_isAlbumFound = NO;
	[_library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
		NSLog(@"Album -- SEARCH:[%@]", [group valueForProperty:ALAssetsGroupPropertyName]);
		
		if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:NSLocalizedString(@"club_covers", nil)]) { NSLog(@"Found Album"); // @"Selfieclub Club Covers"])
			assetsGroup = group;
			*stop = YES;
			
			_totaAlbumAssets = group.numberOfAssets;
			weakSelf.isAlbumFound = YES;
		}
		
	} failureBlock:^(NSError* error) {
		NSLog(@"--ALBUM ENUMBERATE FAILURE--\nError: %@", [error localizedDescription]);
	}];
	
	[self performSelector:@selector(_delayedAlbumEnumeration:)
			   withObject:[assetsGroup valueForProperty:ALAssetsGroupPropertyName]
			   afterDelay:0.50];
}

- (void)_createAlbum {
	__weak HONCreateClubViewController *weakSelf = self;
	
	[_library addAssetsGroupAlbumWithName:NSLocalizedString(@"club_covers", nil) resultBlock:^(ALAssetsGroup *group) {
		NSLog(@"ALBUM -- ADDED: %@", NSLocalizedString(@"club_covers", nil));
		[weakSelf _searchForAlbum];
		
	} failureBlock:^(NSError *error) {
		NSLog(@"--ALBUM ADD FAILURE--");
	}];
}

- (void)_addImageToAlbum:(UIImage *)image withIdentifier:(NSString *)identifier {
	__block ALAssetsGroup *assetsGroup;
	[_library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
		if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:NSLocalizedString(@"club_covers", nil)]) {
			NSLog(@"Found Album -- ADDING");
			assetsGroup = group;
			
			__block NSMutableDictionary *metadata;
			__block BOOL isFound = NO;
			[group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop){
				ALAssetRepresentation *representation = [result defaultRepresentation];
				metadata = [[representation metadata] mutableCopy];
				NSMutableDictionary *exif = [[metadata objectForKey:@"{Exif}"] mutableCopy];
				[exif setValue:identifier forKey:@"ImageUniqueID"];
				[metadata setValue:exif forKey:@"{Exif}"];
				
				
//				NSLog(@"ID:[%@]=-\n[%@]", [[[[[[[result valueForProperty:ALAssetPropertyAssetURL] absoluteString] componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"?"] lastObject] substringWithRange:NSMakeRange(3, 36)], metadata);
				if ([[[metadata objectForKey:@"{Exif}"] objectForKey:@"ImageUniqueID"] isEqualToString:identifier])
					metadata = [NSMutableDictionary dictionaryWithObject:@"0000" forKey:@"PCID"];//isFound = YES;
				
//				*stop = isFound;
			}];
			
			NSLog(@"FOUND:[%@]", [@"" stringFromBOOL:isFound]);
			if (!isFound) {
				[_library writeImageToSavedPhotosAlbum:[image CGImage] metadata:[metadata copy] completionBlock:^(NSURL* assetURL, NSError* error) {
					if (error.code == 0) {
						NSLog(@"Save Image -- COMPLETE:[%@]", assetURL);
						
						[_library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
							[assetsGroup addAsset:asset];
							NSLog(@"Image -- ADDED:[%@] =-=\n%@", asset.defaultRepresentation.filename, asset.defaultRepresentation.metadata);
						} failureBlock:^(NSError* error) {
							NSLog(@"--ASSET FAILURE--\nError: %@ ", [error localizedDescription]);
						}];
						
					} else
						NSLog(@"--SAVE FAILURE--\nerror code %i\n%@", error.code, [error localizedDescription]);
				}];
			}
		}
		
	} failureBlock:^(NSError* error) {
		NSLog(@"--ALBUM ENUMBERATE FAILURE--\nError: %@", [error localizedDescription]);
	}];
}

- (void)_delayedAlbumEnumeration:(id)sender {
	if (!_isAlbumFound)
		[self _createAlbum];
	
	else {
		if (_totaAlbumAssets < [[[HONClubAssistant sharedInstance] clubCoverPhotoAlbumPrefixes] count]) {
			__weak HONCreateClubViewController *weakSelf = self;
			
			[[[HONClubAssistant sharedInstance] clubCoverPhotoAlbumPrefixes] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSString *prefix = (NSString *)obj;
				
				UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
				void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
					NSLog(@"LOADED:[%@] -- EXISTING ALBUM ADD", request.URL.absoluteString);
					
					const char *cKey  = [[NSBundle mainBundle].bundleIdentifier cStringUsingEncoding:NSASCIIStringEncoding];
					const char *cData = [[[[request.URL.absoluteString componentsSeparatedByString:@"/"] lastObject] substringToIndex:6] cStringUsingEncoding:NSUTF8StringEncoding];
					unsigned char cHMAC[CC_MD5_DIGEST_LENGTH];
					CCHmac(kCCHmacAlgMD5, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
					
					NSMutableString *md5 = [NSMutableString string];
					for (int i=0; i<sizeof cHMAC; i++)
						[md5 appendFormat:@"%02hhxc", cHMAC[i]];
					
					NSLog(@"MD5:[%@]", md5);
					
					imageView.image = image;
					[weakSelf _addImageToAlbum:image withIdentifier:md5];
				};
				
				void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
					NSLog(@"--IMAGE LOAD ERROR[%@]--\n[%@]", request.URL.absoluteString, error.description);
				};
				
				NSLog(@"Image -- REMOTE LOAD:[%@]", [prefix stringByAppendingString:kSnapMediumSuffix]);
				[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[prefix stringByAppendingString:kSnapMediumSuffix]]
																   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
															   timeoutInterval:[HONAppDelegate timeoutInterval]]
								 placeholderImage:nil
										  success:imageSuccessBlock
										  failure:imageFailureBlock];
			}];
		}
	}
}
#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if(buttonIndex ==0)
			[self _validateClubNameWithAlerts:YES];
		else if(buttonIndex == 1)
			[self _goCamera];
	}
}

@end
