//
//  HONVerifyOverlayView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/16/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONVerifyOverlayView.h"

@interface HONVerifyOverlayView()
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@end

@implementation HONVerifyOverlayView

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super initWithFrame:[UIScreen mainScreen].bounds])) {
		_challengeVO = vo;
		
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = self.frame;
		[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchDown];
		[self addSubview:closeButton];
		
		UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 210.0) * 0.5, 320.0, 90.0)];
		[self addSubview:holderView];
		
		UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 30.0)];
		captionLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:18];
		captionLabel.textColor = [HONAppDelegate honGrey365Color];
		captionLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.75];
		captionLabel.textAlignment = NSTextAlignmentCenter;
		captionLabel.text = [NSString stringWithFormat:@"Does @%@ look real to you?", _challengeVO.creatorVO.username];
		[holderView addSubview:captionLabel];
		
		UIButton *yayButton = [UIButton buttonWithType:UIButtonTypeCustom];
		yayButton.frame = CGRectMake(0.0, 28.0, 159.0, 64.0);
		[yayButton setBackgroundImage:[UIImage imageNamed:@"approveButton_nonActive"] forState:UIControlStateNormal];
		[yayButton setBackgroundImage:[UIImage imageNamed:@"approveButton_Active"] forState:UIControlStateHighlighted];
		[yayButton addTarget:self action:@selector(_goYay) forControlEvents:UIControlEventTouchUpInside];
		[holderView addSubview:yayButton];
		
		UIButton *nayButton = [UIButton buttonWithType:UIButtonTypeCustom];
		nayButton.frame = CGRectMake(161.0, 28.0, 159.0, 64.0);
		[nayButton setBackgroundImage:[UIImage imageNamed:@"rejectButton_nonActive"] forState:UIControlStateNormal];
		[nayButton setBackgroundImage:[UIImage imageNamed:@"rejectButton_Active"] forState:UIControlStateHighlighted];
		[nayButton addTarget:self action:@selector(_goNay) forControlEvents:UIControlEventTouchUpInside];
		[holderView addSubview:nayButton];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goClose {
	[self.delegate verifyOverlayViewClose:self];
}

- (void)_goYay {
	[self.delegate verifyOverlayView:self approve:YES forChallenge:_challengeVO];
}

- (void)_goNay {
	[self.delegate verifyOverlayView:self approve:NO forChallenge:_challengeVO];
}

@end
