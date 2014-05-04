//
//  HONImagePickerViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.09.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import "HONImagePickerViewController.h"
#import "HONSelfieCameraViewController.h"
#import "HONTrivialUserVO.h"

@interface HONImagePickerViewController ()
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONMessageVO *messageVO;
@property (nonatomic, strong) NSArray *recipients;
@property (nonatomic, assign, readonly) HONPhotoSubmitType photoSubmitType;
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
		_photoSubmitType = HONPhotoSubmitTypeCreateChallenge;
	}
	
	return (self);
}

- (id)initAsNewChallengeForClub:(int)clubID {
	if ((self = [self init])) {
		_photoSubmitType = HONPhotoSubmitTypeCreateClub;
	}
	
	return (self);
}

- (id)initAsMessageToRecipients:(NSArray *)recipients {
	if ((self = [self init])) {
		_photoSubmitType = HONPhotoSubmitTypeCreateMessage;
		_recipients = recipients;
	}
	
	return (self);
}

- (id)initWithJoinChallenge:(HONChallengeVO *)vo {
	if ((self = [self init])) {
		_photoSubmitType = HONPhotoSubmitTypeReplyChallenge;
		_challengeVO = vo;
	}
	
	return (self);
}

- (id)initAsMessageReply:(HONMessageVO *)messageVO withRecipients:(NSArray *)recipients {
	if ((self= [self init])) {
		_photoSubmitType = HONPhotoSubmitTypeReplyMessage;
		_messageVO = messageVO;
		_recipients = recipients;
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
	
	if (_photoSubmitType == HONPhotoSubmitTypeCreateChallenge)
		[self.navigationController pushViewController:[[HONSelfieCameraViewController alloc] initAsNewChallenge] animated:NO];
	
	else if (_photoSubmitType == HONPhotoSubmitTypeReplyChallenge)
		[self.navigationController pushViewController:[[HONSelfieCameraViewController alloc] initAsJoinChallenge:_challengeVO] animated:NO];
	
	else if (_photoSubmitType == HONPhotoSubmitTypeCreateClub)
		[self.navigationController pushViewController:[[HONSelfieCameraViewController alloc] initAsNewChallenge] animated:NO];
	
	else if (_photoSubmitType == HONPhotoSubmitTypeReplyClub)
		[self.navigationController pushViewController:[[HONSelfieCameraViewController alloc] initAsJoinChallenge:_challengeVO] animated:NO];
	
	else if (_photoSubmitType == HONPhotoSubmitTypeCreateMessage)
		[self.navigationController pushViewController:[[HONSelfieCameraViewController alloc] initAsNewMessageWithRecipients:_recipients] animated:NO];
	
	else if (_photoSubmitType == HONPhotoSubmitTypeReplyMessage)
		[self.navigationController pushViewController:[[HONSelfieCameraViewController alloc] initAsMessageReply:_messageVO withRecipients:_recipients] animated:NO];
	
	else
		[self.navigationController pushViewController:[[HONSelfieCameraViewController alloc] initAsNewChallenge] animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


@end
