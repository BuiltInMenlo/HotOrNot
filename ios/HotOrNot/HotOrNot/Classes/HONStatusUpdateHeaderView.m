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
@end

@implementation HONStatusUpdateHeaderView
@synthesize delegate = _delegate;

- (id)initWithStatusUpdateVO:(HONStatusUpdateVO *)statusUpdateVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, [UIApplication sharedApplication].statusBarFrame.size.height, [UIScreen mainScreen].bounds.size.width, 105.0)])) {
//		self.backgroundColor = [[HONColorAuthority sharedInstance] honDebugDefaultColor];
		_statusUpdateVO = statusUpdateVO;
		
		HONButton *backButton = [HONButton buttonWithType:UIButtonTypeCustom];
		backButton.frame = CGRectMake(0.0, 0.0, 99.0, 46.0);
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
		[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:backButton];
		
		HONButton *cameraFlipButton = [HONButton buttonWithType:UIButtonTypeCustom];
		cameraFlipButton.frame = CGRectMake(self.frame.size.width - 52.0, 0.0, 52.0, 46.0);
		[cameraFlipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_nonActive"] forState:UIControlStateNormal];
		[cameraFlipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_Active"] forState:UIControlStateHighlighted];
		[cameraFlipButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:cameraFlipButton];
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 51.0, 280.0, 20.0)];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.textColor = [UIColor whiteColor];
		subjectLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:18];
		subjectLabel.text = _statusUpdateVO.subjectName;
		[self addSubview:subjectLabel];
		
		UILabel *linkLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 80.0, 220.0, 18.0)];
		linkLabel.backgroundColor = [UIColor clearColor];
		linkLabel.textColor = [UIColor whiteColor];
		linkLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
		linkLabel.text = [NSString stringWithFormat:@"doodch.at/%d", _statusUpdateVO.statusUpdateID];
		[linkLabel resizeFrameForText];
		[self addSubview:linkLabel];
		
		UIImageView *linkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"linkIcon"]];
		linkImageView.frame = CGRectOffset(linkImageView.frame, linkLabel.frameEdges.right + 5.0, 81.0);
		[self addSubview:linkImageView];
		
		HONButton *linkButton = [HONButton buttonWithType:UIButtonTypeCustom];
		linkButton.frame = linkImageView.frame;
		[linkButton addTarget:self action:@selector(_goCopyLink) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:linkButton];
	}
	
	return (self);
}


#pragma mark - Public APIs
#pragma mark - Navigation
- (void)_goBack {
	if ([self.delegate respondsToSelector:@selector(statusUpdateHeaderViewGoBack:)])
		[self.delegate statusUpdateHeaderViewGoBack:self];
}

- (void)_goCopyLink {
	
}

- (void)_goFlipCamera {
	if ([self.delegate respondsToSelector:@selector(statusUpdateHeaderViewChangeCamera:)])
		[self.delegate statusUpdateHeaderViewChangeCamera:self];
}

@end
