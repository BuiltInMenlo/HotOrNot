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
@property (nonatomic, strong) UITextField *emojiTextField;
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
	
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Enter update"]; //@"Settings"];
	[self.view addSubview:headerView];
	
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(3.0, 17.0, 44.0, 44.0);
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:cancelButton];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(self.view.frame.size.width - 45, 18.0, 44.0, 44.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"statusUpdateButton_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"statusUpdateButton_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:submitButton];
	
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
	
	_emojiTextField = [[UITextField alloc] initWithFrame:CGRectMake(13.0, 76.0, 294.0, 22.0)];
	[_emojiTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_emojiTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_emojiTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_emojiTextField setReturnKeyType:UIReturnKeyDone];
	[_emojiTextField setTextColor:[UIColor blackColor]];
	[_emojiTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_emojiTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
//	_emojiTextField.font = textFont;
	_emojiTextField.keyboardType = UIKeyboardTypeAlphabet;
	_emojiTextField.placeholder = @"Add Emoji...";
	_emojiTextField.text = @"";
	[_emojiTextField setTag:0];
	_emojiTextField.delegate = self;
	[self.view addSubview:_emojiTextField];
	
	[_emojiTextField becomeFirstResponder];
	
}



#pragma mark - Navigation

- (void)_goCancel {
	[self dismissViewControllerAnimated:YES completion:^(void) {}];
}

- (void)_goSubmit {
	[self dismissViewControllerAnimated:YES completion:^(void) {}];
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	
}

- (void)_onTextEditingDidEnd:(id)sender {
	
}

- (void)_onTextEditingDidEndOnExit:(id)sender {

}


@end
