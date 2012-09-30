//
//  HONChallengerPickerViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengerPickerViewController.h"

@interface HONChallengerPickerViewController ()
@property (nonatomic) int challengerID;
@end

@implementation HONChallengerPickerViewController

@synthesize challengerID = _challengerID;

- (id)init {
	if ((self = [super init])) {
		
	}
	
	return (self);
}

- (id)initWithUser:(int)userID {
	if ((self = [super init])) {
		
	}
	
	return (self);
}

#pragma mark - View lifecycle
- (void)loadView {
	NSLog(@"loadView");
	[super loadView];
	
	UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 45.0)];
	[headerImgView setImage:[UIImage imageNamed:@"basicHeader.png"]];
	headerImgView.userInteractionEnabled = YES;
	[self.view addSubview:headerImgView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(5.0, 5.0, 54.0, 34.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	//backButton = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
	[backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[backButton setTitle:@"Back" forState:UIControlStateNormal];
	[headerImgView addSubview:backButton];
	
	
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
}

- (void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end
