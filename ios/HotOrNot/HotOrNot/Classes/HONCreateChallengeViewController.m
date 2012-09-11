//
//  HONCreateChallengeViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo. All rights reserved.
//

#import "HONCreateChallengeViewController.h"
#import "HONImagePickerViewController.h"

@interface HONCreateChallengeViewController() <UITextFieldDelegate>
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) UILabel *placeholderLabel;
@end

@implementation HONCreateChallengeViewController

@synthesize subjectName = _subjectName;
@synthesize placeholderLabel = _placeholderLabel;

- (id)init {
	if ((self = [super init])) {
		self.title = NSLocalizedString(@"Create Challenge", @"Create Challenge");
		self.tabBarItem.image = [UIImage imageNamed:@"second"];
		
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
	self.placeholderLabel.textAlignment = UITextAlignmentCenter;
	self.placeholderLabel.text = @"Give your challenge a #hashtag";
	[self.view addSubview:self.placeholderLabel];
	
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
}
- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)];
	toolbar.frame = CGRectMake(0, 0, 320.0, 50.0);
	toolbar.barStyle = UIBarStyleDefault;
	[toolbar sizeToFit];        
	[self.view addSubview:toolbar]; 
	
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_goDone)];
	NSArray *items = [[NSArray alloc] initWithObjects:flexibleSpace, doneButton, nil];
	[toolbar setItems:items];
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
- (void)_goDone {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goChallengeFriends {
	
}

- (void)_goRandomChallenge {
	NSLog(@"_goRandomChallenge");
	[self.navigationController pushViewController:[[HONImagePickerViewController alloc] initWithSubject:self.subjectName] animated:YES];
	//[self.parentViewController.navigationController pushViewController:[[HONImagePickerViewController alloc] init] animated:YES];
	
	//UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
	//[self.navigationController pushViewController:navigationController animated:YES];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
		return YES;
	}
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

@end
