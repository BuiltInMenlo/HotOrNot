//
//  HONCommentsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 02.20.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "AFNetworking.h"
#import "MBProgressHUD.h"

#import "HONCommentsViewController.h"
#import "HONTableViewCell.h"
#import "HONCommentViewCell.h"
#import "HONCommentVO.h"

@interface HONCommentsViewController () <UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIImageView *bgTextImageView;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic) BOOL isGoingBack;
@end

@implementation HONCommentsViewController

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_challengeVO = vo;
		_isGoingBack = NO;
		
		self.comments = [NSMutableArray new];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotate {
	return (NO);
}


#pragma mark - Data Calls
- (void)_retrieveComments {
//	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//									[@"" stringFromInt:1], @"action",
//									[@"" stringFromInt:_challengeVO.challengeID], @"challengeID",
//									nil];
//	
//	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIComments, params);
	/*
	 AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIComments parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			//SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			_comments = [NSMutableArray new];
			for (NSDictionary *dict in result) {
				HONCommentVO *vo = [HONCommentVO commentWithDictionary:dict];
				
				if (vo != nil)
					[_comments addObject:vo];
			}
			
			if ([_comments count] > 0) {
				[_tableView reloadData];
				[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_comments count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
			}
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:nil];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIComments, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
	 */
}

- (void)_submitComment {
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_submitComment", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	_progressHUD.yOffset = -75.0;
	
	/*
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[@"" stringFromInt:2], @"action",
									[@"" stringFromInt:_challengeVO.challengeID], @"challengeID",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									_commentTextField.text, @"text",
									nil];
	
	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIComments, params);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIComments parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_dlFailed", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			//SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			[_progressHUD hide:YES];
			_progressHUD = nil;
			
			[self _retrieveComments];
			result = nil;
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIComments, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
	 */
}

- (void)_deleteComment:(int)commentID {
//	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//							[@"" stringFromInt:8], @"action",
//							[@"" stringFromInt:commentID], @"commentID",
//							nil];
//	
//	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIComments, params);
	
	/*
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIComments parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			//SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			[self _retrieveComments];
			result = nil;
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIComments, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
	 */
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	self.navigationController.navigationBar.topItem.title = @"Comments";
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (236.0 + 53.0)) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 70.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	_bgTextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 73.0, 320.0, 53.0)];
	_bgTextImageView.image = [UIImage imageNamed:@"commentsInput"];
	_bgTextImageView.userInteractionEnabled = YES;
	[self.view addSubview:_bgTextImageView];
	
	_commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(14.0, 11.0, 300.0, 32.0)];
	[_commentTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_commentTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_commentTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_commentTextField setReturnKeyType:UIReturnKeySend];
	[_commentTextField setTextColor:[[HONColorAuthority sharedInstance] honPercentGreyscaleColor:0.455]];
	[_commentTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_commentTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:23];
	_commentTextField.keyboardType = UIKeyboardTypeDefault;
	_commentTextField.text = @"";
	_commentTextField.delegate = self;
	[_commentTextField setTag:0];
	[_bgTextImageView addSubview:_commentTextField];
	
	UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
	sendButton.frame = CGRectMake(248.0, 3.0, 64.0, 44.0);
	[sendButton setBackgroundImage:[UIImage imageNamed:@"sendButtonComments_nonActive"] forState:UIControlStateNormal];
	[sendButton setBackgroundImage:[UIImage imageNamed:@"sendButtonComments_Active"] forState:UIControlStateHighlighted];
	[sendButton addTarget:self action:@selector(_goSend) forControlEvents:UIControlEventTouchUpInside];
	[_bgTextImageView addSubview:sendButton];
	
	[self _retrieveComments];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.0];
	[UIView setAnimationDelay:0.0];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[_commentTextField becomeFirstResponder];
	[UIView commitAnimations];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"USER_CHALLENGE" object:nil];
	
	_isGoingBack = YES;
	//[_commentTextField resignFirstResponder];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.0];
	[UIView setAnimationDelay:0.0];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[_commentTextField resignFirstResponder];
	[UIView commitAnimations];
	
	_commentTextField.text = @"";
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}


#pragma mark - Navigation
- (void)_goBack {
	
	_isGoingBack = YES;
	//[_commentTextField resignFirstResponder];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.0];
	[UIView setAnimationDelay:0.0];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[_commentTextField resignFirstResponder];
	[UIView commitAnimations];
	
	_commentTextField.text = @"";
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goSend {
	
	if ([_commentTextField.text length] > 0) {
		[self _submitComment];
		_commentTextField.text = @"";
	}
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_comments count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONCommentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONCommentViewCell alloc] init];
	
	cell.commentVO = [_comments objectAtIndex:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	HONCommentVO *vo = (HONCommentVO *)[_comments objectAtIndex:indexPath.row];
	return ((vo.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? nil : indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//[(HONVoterViewCell *)[tableView cellForRowAtIndexPath:indexPath] didSelect];
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	
//	HONCommentVO *vo = (HONCommentVO *)[_comments objectAtIndex:indexPath.row];
	
//	HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
//													   [@"" stringFromInt:vo.userID], @"id",
//													   [@"" stringFromInt:0], @"points",
//													   [@"" stringFromInt:0], @"total_votes",
//													   [@"" stringFromInt:0], @"pokes",
//													   [@"" stringFromInt:0], @"pics",
//													   [@"" stringFromInt:0], @"age",
//													   vo.username, @"username",
//													   vo.fbID, @"fb_id",
//													   vo.avatarURL, @"avatar_url", nil]];
//	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initWithUser:userVO withSubject:_challengeVO.subjectName]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	HONCommentVO *vo = (HONCommentVO *)[_comments objectAtIndex:indexPath.row];
	return (vo.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Comment"
															message:@"Do you want to remove this comment?"
														   delegate:self
												  cancelButtonTitle:@"Yes"
												  otherButtonTitles:@"No", nil];
		[alertView setTag:0];
		[alertView show];
		
		_indexPath = indexPath;
	}
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	//_bgTextImageView.frame = CGRectMake(_bgTextImageView.frame.origin.x, [UIScreen mainScreen].bounds.size.height - (236.0 + 53.0), _bgTextImageView.frame.size.width, _bgTextImageView.frame.size.height);
	_bgTextImageView.frame = CGRectOffset(_bgTextImageView.frame, 0.0, -216.0);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([textField.text length] > 35 && ![string isEqualToString:@""]) {
		textField.text = [textField.text substringToIndex:35];
		
		return (NO);
	}
	
	return (YES);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	return (YES);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	
	if (!_isGoingBack) {
		//[textField becomeFirstResponder];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.0];
		[UIView setAnimationDelay:0.0];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[textField becomeFirstResponder];  // <---- Only edit this line
		[UIView commitAnimations];
	}
}

- (void)_onTxtDoneEditing:(id)sender {
	//[_commentTextField becomeFirstResponder];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.0];
	[UIView setAnimationDelay:0.0];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[_commentTextField becomeFirstResponder];  // <---- Only edit this line
	[UIView commitAnimations];
	
	[self _goSend];
}

#pragma mark - AlerView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch(buttonIndex) {
		case 0: {
			HONCommentVO *vo = (HONCommentVO *)[_comments objectAtIndex:_indexPath.row];			
			
			[_comments removeObjectAtIndex:_indexPath.row];
			[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_indexPath] withRowAnimation:UITableViewRowAnimationFade];
			
			[self _deleteComment:vo.commentID];
			break;}
			
		case 1:
			break;
	}
}


@end
