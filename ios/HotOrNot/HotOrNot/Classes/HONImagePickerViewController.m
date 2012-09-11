//
//  HONImagePickerViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.09.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONAppDelegate.h"
#import "ASIFormDataRequest.h"

#import "HONImagePickerViewController.h"
#import "HONImageTypeViewCell.h"

@interface HONImagePickerViewController () <ASIHTTPRequestDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *imageSources;
@property(nonatomic, strong) NSString *subjectName;
@end

@implementation HONImagePickerViewController

@synthesize tableView = _tableView;
@synthesize imageSources = _imageSources;
@synthesize subjectName = _subjectName;

- (id)initWithSubject:(NSString *)subject {
	if ((self = [super init])) {
		self.title = NSLocalizedString(@"Select Image", @"Select Image");
		self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		
		self.subjectName = subject;
		
		self.imageSources = [NSMutableArray new];
		[self.imageSources addObject:@"Camera"];
		[self.imageSources addObject:@"Camera Roll"];
		[self.imageSources addObject:@"Photo Stream"];
		[self.imageSources addObject:@"Facebook"];
	}
	
	return (self);
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.rowHeight = 56.0;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.userInteractionEnabled = YES;
	self.tableView.scrollsToTop = NO;
	self.tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([self.imageSources count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONImageTypeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		cell = [[HONImageTypeViewCell alloc] init];
	}
	
	[cell setCaption:[self.imageSources objectAtIndex:indexPath.row]];
	[cell setTotal:arc4random() % 100];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (56.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	ASIFormDataRequest *submitChallengeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kChallengesAPI]]];
	
	switch (indexPath.row) {
		case 0:
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SOURCE_CAMERA" object:nil];
				
				UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
				imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
				imagePicker.delegate = self;
				imagePicker.allowsEditing = YES;
				
				[self.navigationController presentViewController:imagePicker animated:YES completion:nil];
				
			} else {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Camera not aviable." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alertView show];
			}
			break;
			
		case 1:
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SOURCE_CAMERAROLL" object:nil];
				
				UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
				imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
				imagePicker.delegate = self;
				imagePicker.allowsEditing = YES;
				//imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
				
				[self.navigationController presentViewController:imagePicker animated:YES completion:nil];
				
			} else {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Photo roll not available." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alertView show];
			}
			break;
			
		case 2:
			break;
			
		case 3:
			[submitChallengeRequest setDelegate:self];
			[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
			[submitChallengeRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
			[submitChallengeRequest setPostValue:self.subjectName forKey:@"subject"];
			[submitChallengeRequest setPostValue:@"" forKey:@"imgURL"];
			[submitChallengeRequest startAsynchronous];
			break;
	}
}

#pragma mark - ImagePicker Delegates
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	//UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	[self dismissViewControllerAnimated:YES completion:nil];
	
	ASIFormDataRequest *submitChallengeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kChallengesAPI]]];
	[submitChallengeRequest setDelegate:self];
	[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
	[submitChallengeRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[submitChallengeRequest setPostValue:self.subjectName forKey:@"subject"];
	[submitChallengeRequest setPostValue:@"" forKey:@"imgURL"];
	[submitChallengeRequest startAsynchronous];
}

#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"HONImagePickerViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSDictionary *challengeResult = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			[self.navigationController popToRootViewControllerAnimated:YES];
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}


@end
