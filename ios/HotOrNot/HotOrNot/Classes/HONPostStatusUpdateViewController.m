//
//  HONPostStatusUpdateViewController.m
//  HotOrNot
//
//  Created by Anirudh Agarwala on 9/4/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONPostStatusUpdateViewController.h"
#import "HONTableView.h"
#import "HONPostStatusUpdateViewCell.h"
#import "CKRefreshControl.h"
#import "KeychainItemWrapper.h"
#import "MBProgressHUD.h"
#import "HONHeaderView.h"
#import "HONActivityHeaderButtonView.h"

#import "NSString+DataTypes.h"

@interface HONPostStatusUpdateViewController ()
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) NSArray *captions;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UITextView *emojiTextView;
@property (nonatomic, strong) HONHeaderView *headerView;
@end

@implementation HONPostStatusUpdateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		_captions = @[ @"Happy",
					   @"Sad",
					   @"In love",
					   @"Angry",
					   @"OMG",
					   @"Confused",
					   @"Excited"];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Compose"]; //@"Settings"];
	[self.view addSubview:_headerView];
	
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(3.0, 17.0, 44.0, 44.0);
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:cancelButton];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(self.view.frame.size.width - 45, 18.0, 44.0, 44.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"arrowButton_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"arrowButton_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:submitButton];
	
	//_activityHeaderView = [[HONActivityHeaderButtonView alloc] initWithTarget:self action:@selector(_goTimeline)];
	
	//	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	//	doneButton.frame = CGRectMake(228.0, 1.0, 93.0, 44.0);
	//	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_nonActive"] forState:UIControlStateNormal];
	//	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_Active"] forState:UIControlStateHighlighted];
	//	[doneButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	//	[headerView addButton:doneButton];
	
	//Go to Timeline
	
//	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, 64.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64.0)];
//	[_tableView setBackgroundColor:[UIColor clearColor]];
//	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//	_tableView.delegate = self;
//	_tableView.dataSource = self;
//	_tableView.alwaysBounceVertical = YES;
//	_tableView.showsVerticalScrollIndicator = YES;
//	_tableView.scrollsToTop = NO;
//	[self.view addSubview:_tableView];
	
	_emojiTextView = [[UITextView alloc] initWithFrame:CGRectMake(13.0, 72.0, 304.0, self.view.frame.size.height - 288)];
	[_emojiTextView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_emojiTextView setAutocorrectionType:UITextAutocorrectionTypeNo];
	_emojiTextView.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_emojiTextView setReturnKeyType:UIReturnKeyDone];
	[_emojiTextView setTextColor:[UIColor blackColor]];
	_emojiTextView.font = [UIFont systemFontOfSize:40.0f];
	_emojiTextView.keyboardType = UIKeyboardTypeDefault;
//	_emojiTextView.backgroundColor = [UIColor redColor];
	_emojiTextView.text = @"";
	[_emojiTextView setTag:0];
	_emojiTextView.delegate = self;
	[self.view addSubview:_emojiTextView];
	
	[_emojiTextView becomeFirstResponder];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Emoji_alert"] == nil) {
		[[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey:@"Emoji_alert"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This app will only accept emoji text so remember to turn your emoji keyboard on!"
															message:nil
														   delegate:nil
												  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
												  otherButtonTitles:nil];
		[alertView show];
	} //only shows alert once
}



#pragma mark - Navigation

- (void)_goCancel {
	[self dismissViewControllerAnimated:YES completion:^(void) {}];
}

- (void)_goSubmit {
	[self dismissViewControllerAnimated:YES completion:^(void) {}];
}

#define ACCEPTABLE_CHARACTERS @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.-/:;()$&@,?!\'\"[]{}#%^*+=\\|~<>€£¥•"

#pragma mark - TextView Delegates
-(BOOL)textViewShouldReturn:(UITextView *)textView {
	
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS];
	
	NSString *filtered = [[text componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
	
	return ([text isEqualToString:filtered] && ([textView.text length] < 200));
}

- (void)textViewDidChange:(UITextView *)textView {
	
	if ([textView.text length] > 0) {
		[_headerView setTitle: [textView.text substringFromIndex: [textView.text length]-2]];

	}
	
	else {
		[_headerView setTitle:@"Compose"];
	}
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	
}

- (void)textViewDidEndEditing:(UITextView *)textView {

}

- (void) animateTextView:(BOOL) up {
}

#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

}
@end
