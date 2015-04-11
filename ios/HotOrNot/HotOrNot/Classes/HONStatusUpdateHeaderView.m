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
@property (nonatomic, strong) UILabel *backLabel;
@property (nonatomic, strong) UILabel *linkLabel;
@property (nonatomic, strong) UIImageView *backImageView;
@end

@implementation HONStatusUpdateHeaderView
@synthesize delegate = _delegate;

- (id)initWithStatusUpdateVO:(HONStatusUpdateVO *)statusUpdateVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, [UIApplication sharedApplication].statusBarFrame.size.height, [UIScreen mainScreen].bounds.size.width, 90.0)])) {
		self.backgroundColor = [UIColor colorWithRed:0.110 green:0.553 blue:0.984 alpha:1.00];
		_statusUpdateVO = statusUpdateVO;
		
		UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, -20.0, self.frame.size.width, 20.0)];
		statusBarView.backgroundColor = [UIColor colorWithRed:0.110 green:0.553 blue:0.984 alpha:1.00];
		[self addSubview:statusBarView];
		
		_backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backButton_nonActive"]];
		[self addSubview:_backImageView];
		
		HONButton *backButton = [HONButton buttonWithType:UIButtonTypeCustom];
		backButton.frame = CGRectMake(0.0, 0.0, 99.0, 46.0);
		[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:backButton];
		
		_backLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 9.0, 120.0, 18.0)];
		_backLabel.backgroundColor = [UIColor clearColor];
		_backLabel.textColor = [UIColor whiteColor];
		_backLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
		_backLabel.text = [NSString stringWithFormat:@"pop.rx/%d", _statusUpdateVO.statusUpdateID];
		[_backLabel resizeFrameForText];
		[self addSubview:_backLabel];
		
		_linkLabel = [[UILabel alloc] initWithFrame:CGRectMake(_backLabel.frameEdges.right + 5.0, 15.0, 100.0, 18.0)];
		_linkLabel.backgroundColor = [UIColor clearColor];
		_linkLabel.textColor = [UIColor whiteColor];
		_linkLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
		_linkLabel.text = @"(share this)";
//		[self addSubview:_linkLabel];
		
		HONButton *linkButton = [HONButton buttonWithType:UIButtonTypeCustom];
		linkButton.frame = CGRectMake(self.frame.size.width - 100.0, -6.0, 52.0, 46.0);
		[linkButton setBackgroundImage:[UIImage imageNamed:@"shareButton_nonActive"] forState:UIControlStateNormal];
		[linkButton setBackgroundImage:[UIImage imageNamed:@"shareButton_nonActive"] forState:UIControlStateHighlighted];
		[linkButton addTarget:self action:@selector(_goCopyLink) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:linkButton];

		HONButton *cameraFlipButton = [HONButton buttonWithType:UIButtonTypeCustom];
		cameraFlipButton.frame = CGRectMake(self.frame.size.width - 52.0, 0.0, 52.0, 46.0);
		[cameraFlipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_nonActive"] forState:UIControlStateNormal];
		[cameraFlipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_Active"] forState:UIControlStateHighlighted];
		[cameraFlipButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:cameraFlipButton];
		
		
		UIView *bannerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 52.0, self.frame.size.width, 38.0)];
		bannerView.backgroundColor = [UIColor colorWithRed:1.000 green:0.839 blue:0.000 alpha:1.00];
		[self addSubview:bannerView];
		
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


#pragma mark - Public APIs
#pragma mark - Navigation
- (void)_goBack {
	_backImageView.image = nil;
	
	_linkLabel.text = @"";
	_backLabel.text = @"Cleaning up…";
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

@end
