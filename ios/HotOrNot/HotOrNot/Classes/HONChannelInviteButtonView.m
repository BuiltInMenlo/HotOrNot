//
//  HONChannelInviteButtonView.m
//  HotOrNot
//
//  Created by BIM  on 3/15/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//


#import "HONChannelInviteButtonView.h"

@interface HONChannelInviteButtonView()
@end

@implementation HONChannelInviteButtonView
@synthesize buttonType = _buttonType;

- (id)initWithFrame:(CGRect)frame asButtonType:(HONChannelInviteButtonType)buttonType {
	if ((self = [super initWithFrame:frame])) {
		[self setButtonType:buttonType];
		
		NSString *caption = @"";
		if (self.buttonType == HONChannelInviteButtonTypeClipboard) {
			caption = @"Copy Chat Link to Clipboard";
			
		} else if (self.buttonType == HONChannelInviteButtonTypeSMS) {
			caption = @"Share Chat Link on SMS";
			
//		} else if (self.buttonType == HONChannelInviteButtonTypeEmail) {
//			caption = @"Share Chat Link on Email";
			
		} else if (self.buttonType == HONChannelInviteButtonTypeKakao) {
			caption = @"Share Chat Link on Kakao";;
			
		} else if (self.buttonType == HONChannelInviteButtonTypeKik) {
			caption = @"Share Chat Link on Kik";
			
		} else if (self.buttonType == HONChannelInviteButtonTypeLine) {
			caption = @"Share Chat Link on LINE";
		}
		
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectFromSize(self.frame.size);
		[button setBackgroundImage:[UIImage imageNamed:@"composeTextButton_nonActive"] forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:@"composeTextButton_Active"] forState:UIControlStateHighlighted];
		[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
		button.titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15];
		[button setTitle:caption forState:UIControlStateNormal];
		[button setTitle:caption forState:UIControlStateHighlighted];
		[button addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setButtonType:(HONChannelInviteButtonType)buttonType {
	_buttonType = buttonType;
}


#pragma mark - Navigation
- (void)_goSelect {
	if ([self.delegate respondsToSelector:@selector(channelInviteButtonView:didSelectType:)])
		[self.delegate channelInviteButtonView:self didSelectType:_buttonType];
}


@end
