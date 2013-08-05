//
//  HONSnapPreviewViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 7/22/13 @ 5:33 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONSnapPreviewViewController.h"
#import "HONImageLoadingView.h"


@interface HONSnapPreviewViewController ()
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) UIImageView *imageView;
@end


@implementation HONSnapPreviewViewController

- (id)initWithImageURL:(NSString *)url {
	if ((self = [super init])) {
		_url = url;
	}
	
	return (self);
}

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_challengeVO = vo;
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


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	//NSLog(@"VERSION:[%d][%@]", [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] intValue], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]);
	
	self.view.backgroundColor = [UIColor blackColor];
	self.view.frame = CGRectOffset(self.view.frame, 0.0, -(20.0));
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSTimeInterval diff = [_challengeVO.addedDate timeIntervalSinceDate:[dateFormat dateFromString:@"2013-08-03 00:00:00"]];
	
	BOOL isCreator = _challengeVO.creatorID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue];
	BOOL isOriginalImageAvailable = ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] intValue] >= 10500 && diff > 0);
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 5.0, 200.0, 20.0)];
	subjectLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:16];
	subjectLabel.textColor = [HONAppDelegate honBlueTextColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _challengeVO.subjectName;
	[self.view addSubview:subjectLabel];
	
	
	NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
	NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	
	NSTimeInterval gmtInterval = [currentTimeZone secondsFromGMTForDate:_challengeVO.updatedDate] - [utcTimeZone secondsFromGMTForDate:_challengeVO.updatedDate];
	NSDate *localDate = [[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:_challengeVO.updatedDate];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
	[dateFormatter setDateFormat:@"h:mma"];
	
	//UILabel *subjectTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 31.0, 200.0, 18.0)];
	UILabel *opponentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 23.0, 180.0, 18.0)];
	opponentsLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:15];
	opponentsLabel.textColor = [HONAppDelegate honGrey455Color];
	opponentsLabel.backgroundColor = [UIColor clearColor];
	opponentsLabel.text = [NSString stringWithFormat:@"%@ at %@", ([_challengeVO.status isEqualToString:@"Created"]) ? @"You snapped…" : [NSString stringWithFormat:@"@%@", (isCreator) ? _challengeVO.challengerName : _challengeVO.creatorName], [[dateFormatter stringFromDate:localDate] lowercaseString]];
	[self.view addSubview:opponentsLabel];

	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initAtPos:CGPointMake(128.0, ([UIScreen mainScreen].bounds.size.height - 64.0) * 0.5)];
	[self.view addSubview:imageLoadingView];
	
	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake((320.0 - kSnapLargeDim) * 0.5, ([UIScreen mainScreen].bounds.size.height - kSnapLargeDim) * 0.5, kSnapLargeDim, kSnapLargeDim)];
	[_imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_%@.jpg", (isCreator && _challengeVO.statusID == 4) ? _challengeVO.challengerImgPrefix : _challengeVO.creatorImgPrefix, (isOriginalImageAvailable) ? @"o" : @"l"]] placeholderImage:nil];
	
	[self.view addSubview:_imageView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


@end
