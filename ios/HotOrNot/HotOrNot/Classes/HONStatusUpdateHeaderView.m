//
//  HONStatusUpdateHeaderView.m
//  HotOrNot
//
//  Created by BIM  on 1/7/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+BuiltinMenlo.h"
#import "UIImageView+AFNetworking.h"
#import "UILabel+BuiltinMenlo.h"
#import "UIView+BuiltinMenlo.h"

#import "HONStatusUpdateHeaderView.h"
#import "HONButton.h"

@interface HONStatusUpdateHeaderView()
@property (nonatomic, strong) HONStatusUpdateVO *statusUpdateVO;
@property (nonatomic, strong) HONButton *backButton;
@property (nonatomic, strong) UILabel *backLabel;
@property (nonatomic, strong) UILabel *linkLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation HONStatusUpdateHeaderView
@synthesize delegate = _delegate;

- (id)initWithStatusUpdateVO:(HONStatusUpdateVO *)statusUpdateVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, [UIApplication sharedApplication].statusBarFrame.size.height, [UIScreen mainScreen].bounds.size.width, 46.0)])) {
		//self.backgroundColor = [UIColor colorWithRed:0.110 green:0.553 blue:0.984 alpha:1.00];
		_statusUpdateVO = statusUpdateVO;
		
		_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		_activityIndicatorView.frame = CGRectOffset(_activityIndicatorView.frame, 11.0, 13.0);
		_activityIndicatorView.alpha = 0.0;
		[self addSubview:_activityIndicatorView];
		
		_backButton = [HONButton buttonWithType:UIButtonTypeCustom];
		_backButton.frame = CGRectMake(12.0, 7.0, 99.0, 46.0);
		[_backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
		[_backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
		[_backButton addTarget:self action:@selector(_goBack:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_backButton];
		
		_backLabel = [[UILabel alloc] initWithFrame:CGRectMake(46.0, 10.0, 200.0, 24.0)];
		_backLabel.backgroundColor = [UIColor clearColor];
		_backLabel.textColor = [UIColor whiteColor];
		_backLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:20];
		_backLabel.text = @"Home";//[NSString stringWithFormat:@"pop.vlly.im/%d", _statusUpdateVO.statusUpdateID];
		[_backLabel resizeFrameForText];
		//[self addSubview:_backLabel];
		
		_linkLabel = [[UILabel alloc] initWithFrame:CGRectMake(_backLabel.frameEdges.right + 9.0, 10.0, 100.0, 18.0)];
		_linkLabel.backgroundColor = [UIColor blueColor];
		_linkLabel.textColor = [UIColor whiteColor];
		_linkLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15];
		_linkLabel.text = @"(share this)";
//		[self addSubview:_linkLabel];
		
		HONButton *linkButton = [HONButton buttonWithType:UIButtonTypeCustom];
		linkButton.frame = CGRectMake(self.frame.size.width - 54.0, 4.0, 52.0, 46.0);
//		linkButton.backgroundColor = [UIColor greenColor];
		[linkButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive"] forState:UIControlStateNormal];
		[linkButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active"] forState:UIControlStateHighlighted];
		[linkButton addTarget:self action:@selector(_goCopyLink) forControlEvents:UIControlEventTouchUpInside];
		//[self addSubview:linkButton];
		
		UIView *bannerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 52.0, self.frame.size.width, 38.0)];
		bannerView.backgroundColor = [UIColor colorWithRed:1.000 green:0.839 blue:0.000 alpha:1.00];
		//[self addSubview:bannerView];
		
		UILabel *bannerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, self.frame.size.width - 20.0, 38.0)];
		bannerLabel.backgroundColor = [UIColor clearColor];
		bannerLabel.textColor = [UIColor blackColor];
		bannerLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15];
		bannerLabel.textAlignment= NSTextAlignmentCenter;
		bannerLabel.text = [NSString stringWithFormat:@"popup.villy.im/%d has been copied to share", _statusUpdateVO.statusUpdateID];
		[bannerView addSubview:bannerLabel];
	}
	
	return (self);
}

- (void)changeTitle:(NSString *)title {
//	_backLabel.text = title;
//	_activityIndicatorView.hidden = NO;
}


#pragma mark - Public APIs
- (void)changeButton:(BOOL)isArrow {
	if (isArrow) {
		_backButton.frame = CGRectMake(12.0, 7.0, 99.0, 46.0);
		[_backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
		[_backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
		
	} else {
		_backButton.frame = CGRectMake(14.0, 9.0, 46.0, 46.0);
		[_backButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
		[_backButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
	}
}


#pragma mark - Navigation
- (void)_goBack:(id)sender {
	UIButton *button = (UIButton *)sender;
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"text"] isEqualToString:@"NO"]) {
		[button removeFromSuperview];
		[_activityIndicatorView startAnimating];
		_activityIndicatorView.alpha = 1.0;
	}
	
	_linkLabel.text = @"Deleting…";
	_backLabel.frame = CGRectResizeWidth(_backLabel.frame, 200.0);
	[_backLabel resizeFrameForText];
	
	if ([self.delegate respondsToSelector:@selector(statusUpdateHeaderViewGoBack:)])
		[self.delegate statusUpdateHeaderViewGoBack:self];
}

- (void)_goCopyLink {
	if ([self.delegate respondsToSelector:@selector(statusUpdateHeaderViewCopyLink:)])
		[self.delegate statusUpdateHeaderViewCopyLink:self];
}

- (void)_goFlipCamera {
	if ([self.delegate respondsToSelector:@selector(statusUpdateHeaderViewChangeCamera:)])
		[self.delegate statusUpdateHeaderViewChangeCamera:self];
}

- (void)_goFlag {
	if ([self.delegate respondsToSelector:@selector(statusUpdateHeaderViewFlag:)])
		[self.delegate statusUpdateHeaderViewFlag:self];
}

@end
