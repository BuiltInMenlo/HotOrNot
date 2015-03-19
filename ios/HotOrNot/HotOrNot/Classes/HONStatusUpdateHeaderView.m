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
#import "HONRefreshingLabel.h"

@interface HONStatusUpdateHeaderView()
@property (nonatomic, strong) HONStatusUpdateVO *statusUpdateVO;
@end

@implementation HONStatusUpdateHeaderView
@synthesize delegate = _delegate;

- (id)initWithStatusUpdateVO:(HONStatusUpdateVO *)statusUpdateVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, 84.0)])) {
		_statusUpdateVO = statusUpdateVO;
		
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		backButton.frame = CGRectMake(10.0, 30.0, 35.0, 35.0);
		[backButton setBackgroundImage:[UIImage imageNamed:@"composeButton_nonActive"] forState:UIControlStateNormal];
		[backButton setBackgroundImage:[UIImage imageNamed:@"composeButton_Active"] forState:UIControlStateHighlighted];
		[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:backButton];
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 60.0, 280.0, 20.0)];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.textColor = [UIColor whiteColor];
		subjectLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:16];
		subjectLabel.text = _statusUpdateVO.topicName;
		[self addSubview:subjectLabel];
		
		UILabel *linkLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 85.0, 220.0, 18.0)];
		linkLabel.backgroundColor = [UIColor clearColor];
		linkLabel.textColor = [UIColor whiteColor];
		linkLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
		linkLabel.text = [NSString stringWithFormat:@"doodch.at/%d", _statusUpdateVO.statusUpdateID];
		[linkLabel resizeFrameForText];
		[self addSubview:linkLabel];
		
		UIButton *linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		linkButton.frame = CGRectMake(linkLabel.frameEdges.right + 10.0, 85.0, 18.0, 18.0);
		[linkButton setBackgroundImage:[UIImage imageNamed:@"composeButton_nonActive"] forState:UIControlStateNormal];
		[linkButton setBackgroundImage:[UIImage imageNamed:@"composeButton_Active"] forState:UIControlStateHighlighted];
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
	if ([self.delegate respondsToSelector:@selector(statusUpdateHeaderView:copyLinkForStatusUpdate:)])
		[self.delegate statusUpdateHeaderView:self copyLinkForStatusUpdate:_statusUpdateVO];
}

@end
