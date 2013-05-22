//
//  HONWebCTAViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.26.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "KikAPI.h"
#import "MBProgressHUD.h"

#import "HONShareViewController.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"
#import "HONImagingDepictor.h"

@interface HONShareViewController () <UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@end

@implementation HONShareViewController

- (id)init {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Share Modal - Open"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (NO);
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h@2x" : @"mainBG"];
	[self.view addSubview:bgImgView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Share Volley"];
	[self.view addSubview:headerView];
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(253.0, 0.0, 64.0, 44.0);
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:cancelButton];
	
	
	UIButton *instagramButton = [UIButton buttonWithType:UIButtonTypeCustom];
	instagramButton.frame = CGRectMake(37.0, 100.0, 245.0, 36.0);
	[instagramButton setBackgroundImage:[UIImage imageNamed:@"tapToShareButton_nonActive"] forState:UIControlStateNormal];
	[instagramButton setBackgroundImage:[UIImage imageNamed:@"tapToShareButton_Active"] forState:UIControlStateHighlighted];
	[instagramButton addTarget:self action:@selector(_goInstagram) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:instagramButton];
	
	UIButton *kikButton = [UIButton buttonWithType:UIButtonTypeCustom];
	kikButton.frame = CGRectMake(37.0, 150.0, 245.0, 36.0);
	[kikButton setBackgroundImage:[UIImage imageNamed:@"tapToShareButton_nonActive"] forState:UIControlStateNormal];
	[kikButton setBackgroundImage:[UIImage imageNamed:@"tapToShareButton_Active"] forState:UIControlStateHighlighted];
	[kikButton addTarget:self action:@selector(_goKik) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:kikButton];
	
	UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
	facebookButton.frame = CGRectMake(37.0, 200.0, 245.0, 36.0);
	[facebookButton setBackgroundImage:[UIImage imageNamed:@"tapToShareButton_nonActive"] forState:UIControlStateNormal];
	[facebookButton setBackgroundImage:[UIImage imageNamed:@"tapToShareButton_Active"] forState:UIControlStateHighlighted];
	[facebookButton addTarget:self action:@selector(_goFacebook) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:facebookButton];
	
	UIButton *contactsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	contactsButton.frame = CGRectMake(37.0, 300.0, 245.0, 36.0);
	[contactsButton setBackgroundImage:[UIImage imageNamed:@"tapToShareButton_nonActive"] forState:UIControlStateNormal];
	[contactsButton setBackgroundImage:[UIImage imageNamed:@"tapToShareButton_Active"] forState:UIControlStateHighlighted];
	[contactsButton addTarget:self action:@selector(_goContacts) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:contactsButton];	
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

#pragma mark - Navigation
- (void)_goCancel {
	[[Mixpanel sharedInstance] track:@"Share Modal - Cancel"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goInstagram {
	[[Mixpanel sharedInstance] track:@"Share Modal - Instagram"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
}

- (void)_goKik {
	[[Mixpanel sharedInstance] track:@"Share Modal - Kik"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UIImage *shareImage = [UIImage imageNamed:@"instagram_template-0000"];
	NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/volley_test.jpg"];
	[UIImageJPEGRepresentation(shareImage, 1.0f) writeToFile:savePath atomically:YES];
	
	KikAPIMessage *myMessage = [KikAPIMessage message];
	myMessage.title = [NSString stringWithFormat:@"@%@", [[HONAppDelegate infoForUser] objectForKey:@"name"]];
	myMessage.description = @"";
	myMessage.previewImage = UIImageJPEGRepresentation(shareImage, 1.0f);
	myMessage.filePath = savePath;
	myMessage.iphoneURIs = [NSArray arrayWithObjects:@"my iphone URI", nil];
	myMessage.genericURIs = [NSArray arrayWithObjects:@"my generic URI", nil];
	
	[KikAPIClient sendMessage:myMessage];

}

- (void)_goFacebook {
	[[Mixpanel sharedInstance] track:@"Share Modal - Facebook"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
}

- (void)_goContacts {
	[[Mixpanel sharedInstance] track:@"Share Modal - Contacts"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
}


@end
