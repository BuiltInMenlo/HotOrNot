//
//  HONPhotoViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.04.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONPhotoViewController.h"
#import "UIImageView+WebCache.h"
#import "HONAppDelegate.h"

@interface HONPhotoViewController ()
@property (nonatomic, strong) NSString *imgURL;
@end

@implementation HONPhotoViewController

@synthesize imgURL = _imgURL;

- (id)initWithImagePath:(NSString *)imageURL {
	if ((self = [super init])) {
		_imgURL = imageURL;
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 45.0, 320.0, self.view.frame.size.height - 45.0)];
	[imgView setImageWithURL:[NSURL URLWithString:_imgURL] placeholderImage:nil];
	[self.view addSubview:imgView];
	
//	UIImageView *tmpView = [[UIImageView alloc] initWithFrame:CGRectMake(50.0, 100.0, 100.0, 100.0)];
//	tmpView.image = [HONAppDelegate cropImage:[UIImage imageNamed:@"firstRun_image01.png"] toRect:CGRectMake(30.0, 30.0, 100.0, 100.0)];
//	[self.view addSubview:tmpView];
	
	UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 45.0)];
	headerImgView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	[headerImgView setImage:[UIImage imageNamed:@"headerTitleBackground.png"]];
	headerImgView.userInteractionEnabled = YES;
	[self.view addSubview:headerImgView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(5.0, 5.0, 54.0, 34.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	//backButton = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
	[backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[backButton setTitle:@"Done" forState:UIControlStateNormal];
	[headerImgView addSubview:backButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_goDone {
	[self dismissViewControllerAnimated:YES completion:nil];
}



@end
