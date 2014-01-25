//
//  HONImagePickerViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.09.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import "HONImagePickerViewController.h"
#import "HONChallengeCameraViewController.h"
#import "HONTrivialUserVO.h"

@interface HONImagePickerViewController ()
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONMessageVO *messageVO;
@property (nonatomic, strong) NSArray *recipients;
@property (nonatomic) BOOL isJoinChallenge;
@property (nonatomic) BOOL isMessage;
@end

@implementation HONImagePickerViewController

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor whiteColor];
	}
	
	return (self);
}

- (id)initAsNewChallenge {
	if ((self = [self init])) {
		_isJoinChallenge = NO;
		_isMessage = NO;
	}
	
	return (self);
}

- (id)initAsMessageToRecipients:(NSArray *)recipients {
	if ((self = [self init])) {
		_isJoinChallenge = NO;
		_isMessage = YES;
		_recipients = recipients;
	}
	
	return (self);
}

- (id)initWithJoinChallenge:(HONChallengeVO *)vo {
	if ((self = [self init])) {
		_isJoinChallenge = YES;
		_isMessage = NO;
		_challengeVO = vo;
	}
	
	return (self);
}

- (id)initAsMessageReply:(HONMessageVO *)messageVO {
	if ((self= [self init])) {
		_isJoinChallenge = YES;
		_isMessage = YES;
		_messageVO = messageVO;
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
	
	if (_isMessage) {
		if (_isJoinChallenge)
			[self.navigationController pushViewController:[[HONChallengeCameraViewController alloc] initAsMessageReply:_messageVO] animated:NO];
		
		else
			[self.navigationController pushViewController:[[HONChallengeCameraViewController alloc] initAsNewMessageWithRecipients:_recipients] animated:NO];
			
	} else {
		if (_isJoinChallenge)
			[self.navigationController pushViewController:[[HONChallengeCameraViewController alloc] initAsJoinChallenge:_challengeVO] animated:NO];
		
		else
			[self.navigationController pushViewController:[[HONChallengeCameraViewController alloc] initAsNewChallenge] animated:NO];
	
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


@end
