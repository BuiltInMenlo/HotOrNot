//
//  HONImagePickerViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.09.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import "HONImagePickerViewController.h"
#import "HONChallengeCameraViewController.h"

@interface HONImagePickerViewController ()
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic) BOOL isJoinChallenge;
@end

@implementation HONImagePickerViewController

- (id)init {
	if ((self = [super init])) {
		NSLog(@"%@ - init", [self description]);
		self.view.backgroundColor = [UIColor whiteColor];
		_isJoinChallenge = NO;
	}
	
	return (self);
}

- (id)initWithJoinChallenge:(HONChallengeVO *)vo {
	NSLog(@"%@ - initWithJoinChallenge:[%d] (%d/%d)", [self description], vo.challengeID, vo.creatorVO.userID, ((HONOpponentVO *)[vo.challengers lastObject]).userID);
	if ((self = [super init])) {
		_challengeVO = vo;
		_isJoinChallenge = YES;
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"PLCameraControllerPreviewStartedNotification" object:nil];
}

- (BOOL)shouldAutorotate {
	return (NO);
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (_isJoinChallenge)
		[self.navigationController pushViewController:[[HONChallengeCameraViewController alloc] initAsJoinChallenge:_challengeVO] animated:NO];
	
	else
		[self.navigationController pushViewController:[[HONChallengeCameraViewController alloc] initAsNewChallenge] animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


@end
