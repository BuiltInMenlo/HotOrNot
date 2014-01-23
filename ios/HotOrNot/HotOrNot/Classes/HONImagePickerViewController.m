//
//  HONImagePickerViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.09.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import "HONImagePickerViewController.h"
#import "HONChallengeCameraViewController.h"
#import "HONMessageRecipientVO.h"

@interface HONImagePickerViewController ()
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONMessageVO *messageVO;
@property (nonatomic, strong) NSString *recipients;
@property (nonatomic) BOOL isJoinChallenge;
@property (nonatomic) BOOL isMessage;
@end

@implementation HONImagePickerViewController

- (id)init {
	if ((self = [super init])) {
		NSLog(@"%@ - init", [self description]);
		self.view.backgroundColor = [UIColor whiteColor];
	}
	
	return (self);
}

- (id)initAsNewChallenge {
	NSLog(@"%@ - initAsNewChallenge", [self description]);
	if ((self = [self init])) {
		_isJoinChallenge = NO;
		_isMessage = NO;
	}
	
	return (self);
}

- (id)initAsMessageToRecipients:(NSArray *)recipients {
	NSLog(@"%@ - initAsMessageToRecipients:[%d]", [self description], [recipients count]);
	if ((self = [self init])) {
		_isJoinChallenge = NO;
		_isMessage = YES;
		
		_recipients = @"";
		for (HONMessageRecipientVO *vo in recipients)
			_recipients = [[_recipients stringByAppendingString:[NSString stringWithFormat:@"%d", vo.userID]] stringByAppendingString:@","];
		
		_recipients = [_recipients substringToIndex:[_recipients length] - 1];
	}
	
	return (self);
}

- (id)initWithJoinChallenge:(HONChallengeVO *)vo {
	NSLog(@"%@ - initWithJoinChallenge:[%d] (%d/%d)", [self description], vo.challengeID, vo.creatorVO.userID, ((HONOpponentVO *)[vo.challengers lastObject]).userID);
	if ((self = [self init])) {
		_isJoinChallenge = YES;
		_isMessage = NO;
		_challengeVO = vo;
	}
	
	return (self);
}

- (id)initAsMessageReply:(HONMessageVO *)messageVO {
	NSLog(@"%@ - initAsMessageReply:[%@]", [self description], messageVO.dictionary);
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
