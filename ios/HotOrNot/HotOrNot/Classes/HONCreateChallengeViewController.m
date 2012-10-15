//
//  HONCreateChallengeViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "HONCreateChallengeViewController.h"
#import "HONImagePickerViewController.h"
#import "HONHeaderView.h"

@interface HONCreateChallengeViewController() <UITextFieldDelegate, FBFriendPickerDelegate>
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic) BOOL isPushView;
@property (nonatomic) int challengerID;
@end

@implementation HONCreateChallengeViewController

@synthesize subjectName = _subjectName;
@synthesize placeholderLabel = _placeholderLabel;
@synthesize isPushView = _isPushView;
@synthesize challengerID = _challengerID;

- (id)init {
	if ((self = [super init])) {
		self.tabBarItem.image = [UIImage imageNamed:@"tab03_nonActive"];
		self.subjectName = @"";
		_challengerID = 0;
		self.view.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	}
	
	return (self);
}

- (id)initWithUser:(int)userID {
	if ((self = [super init])) {
		_isPushView = YES;
		_challengerID = userID;
		NSLog(@"initAsPush:[%d]", _isPushView);
		
		self.tabBarItem.image = [UIImage imageNamed:@"tab03_nonActive"];
		self.subjectName = @"";
		
		self.view.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	if (_isPushView) {
		HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Create Challenge"];
		[self.view addSubview:headerView];
		
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		backButton.frame = CGRectMake(5.0, 5.0, 74.0, 44.0);
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
		[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		//backButton = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
		[backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[backButton setTitle:@"Back" forState:UIControlStateNormal];
		[headerView addSubview:backButton];
	}
	
	UITextField *subjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 70.0, 280.0, 20.0)];
	//[subjectTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[subjectTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[subjectTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[subjectTextField setBackgroundColor:[UIColor whiteColor]];
	subjectTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
	[subjectTextField setReturnKeyType:UIReturnKeyDone];
	[subjectTextField setTextColor:[UIColor colorWithWhite:0.482 alpha:1.0]];
	[subjectTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	//subjectTextField.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	subjectTextField.keyboardType = UIKeyboardTypeDefault;
	subjectTextField.text = @"";
	subjectTextField.delegate = self;
	[self.view addSubview:subjectTextField];
	
	self.placeholderLabel = [[UILabel alloc] initWithFrame:subjectTextField.frame];
	//self.placeholderLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	self.placeholderLabel.textColor = [UIColor colorWithWhite:0.620 alpha:1.0];
	self.placeholderLabel.backgroundColor = [UIColor clearColor];
	self.placeholderLabel.textAlignment = NSTextAlignmentCenter;
	self.placeholderLabel.text = @"Give your challenge a #hashtag";
	[self.view addSubview:self.placeholderLabel];
	
	if (_challengerID == 0) {
		UIButton *friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		friendsButton.frame = CGRectMake(20.0, 100.0, 280.0, 43.0);
		[friendsButton setBackgroundColor:[UIColor whiteColor]];
		[friendsButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_nonActive.png"] forState:UIControlStateNormal];
		[friendsButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_Active.png"] forState:UIControlStateHighlighted];
		[friendsButton addTarget:self action:@selector(_goChallengeFriends) forControlEvents:UIControlEventTouchUpInside];
		//friendsButton = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
		[friendsButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		[friendsButton setTitle:@"Challenge Friends" forState:UIControlStateNormal];
		[self.view addSubview:friendsButton];
	
		UIButton *randomButton = [UIButton buttonWithType:UIButtonTypeCustom];
		randomButton.frame = CGRectMake(20.0, 150.0, 280.0, 43.0);
		[randomButton setBackgroundColor:[UIColor whiteColor]];
		[randomButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_nonActive.png"] forState:UIControlStateNormal];
		[randomButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_Active.png"] forState:UIControlStateHighlighted];
		[randomButton addTarget:self action:@selector(_goRandomChallenge) forControlEvents:UIControlEventTouchUpInside];
		//randomButton = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
		[randomButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		[randomButton setTitle:@"Random Challenge" forState:UIControlStateNormal];
		[self.view addSubview:randomButton];
	
	} else {
		UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraButton.frame = CGRectMake(20.0, 150.0, 280.0, 43.0);
		[cameraButton setBackgroundColor:[UIColor whiteColor]];
		[cameraButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_nonActive.png"] forState:UIControlStateNormal];
		[cameraButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_Active.png"] forState:UIControlStateHighlighted];
		[cameraButton addTarget:self action:@selector(_goPhoto) forControlEvents:UIControlEventTouchUpInside];
		//cameraButton = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
		[cameraButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		[cameraButton setTitle:@"Choose Photo" forState:UIControlStateNormal];
		[self.view addSubview:cameraButton];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_goDone)];
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
- (void)_goBack {
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)_goDone {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goPhoto {
	//[self.navigationController pushViewController:[[HONImagePickerViewController alloc] initWithSubject:self.subjectName withUser:_challengerID] animated:YES];
}

- (void)_goChallengeFriends {
	[FBRequestConnection startWithGraphPath:@"me/friends" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
		for (NSDictionary *friend in [(NSDictionary *)result objectForKey:@"data"]) {
			//NSLog(@"FRIEND:[%@]", friend);
		}
	}];
	
	
	FBFriendPickerViewController *friendPickerController = [[FBFriendPickerViewController alloc] init];
	friendPickerController.title = @"Pick Friends";
	friendPickerController.allowsMultipleSelection = NO;
	friendPickerController.delegate = self;
	friendPickerController.sortOrdering = FBFriendDisplayByLastName;
	friendPickerController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
																				  initWithTitle:@"Cancel!"
																				  style:UIBarButtonItemStyleBordered
																				  target:self
																				  action:@selector(cancelButtonWasPressed:)];
	
	friendPickerController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
																					initWithTitle:@"Done!"
																					style:UIBarButtonItemStyleBordered
																					target:self
																					action:@selector(doneButtonWasPressed:)];
	[friendPickerController loadData];
	
	// Use the modal wrapper method to display the picker.
	[friendPickerController presentModallyFromViewController:self animated:YES handler:
	 ^(FBViewController *sender, BOOL donePressed) {
		 if (!donePressed)
			 return;
		 
		 if (friendPickerController.selection.count == 0) {
			 [[[UIAlertView alloc] initWithTitle:@"You Picked:"
												  message:@"<No Friends Selected>"
												 delegate:nil
									 cancelButtonTitle:@"OK"
									 otherButtonTitles:nil]
			  show];
		 
		 } else {
		 // submit
		 //[self.navigationController pushViewController:[[HONImagePickerViewController alloc] initWithSubject:self.subjectName withFriendID:[[friendPickerController.selection lastObject] objectForKey:@"id"]] animated:YES];
		 }
	 }];
}

- (void)_goRandomChallenge {
	NSLog(@"_goRandomChallenge");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (NO);//interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	self.placeholderLabel.hidden = YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	if ([textField.text length] > 0) {
		self.subjectName = textField.text;		
	
	} else
		self.placeholderLabel.hidden = NO;
}

#pragma mark - Friend Picker Delegates
- (void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker {
	[friendPicker dismissViewControllerAnimated:YES completion:^(void) {
		NSLog(@"%@", [[friendPicker.selection lastObject] objectForKey:@"id"]);
		//[self.navigationController pushViewController:[[HONImagePickerViewController alloc] initWithSubject:self.subjectName withFriendID:[[friendPicker.selection lastObject] objectForKey:@"id"]] animated:YES];
	}];
}
@end
