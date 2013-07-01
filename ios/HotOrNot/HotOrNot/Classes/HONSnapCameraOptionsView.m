//
//  HONSnapCameraOptionsView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 6/30/13 @ 10:31 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "HONSnapCameraOptionsView.h"


@interface HONSnapCameraOptionsView ()
@property (nonatomic, strong) UIButton *flipCameraButton;
@property (nonatomic, strong) UIButton *cameraRollButton;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation HONSnapCameraOptionsView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"typeOverlay"]];
		bgImageView.frame = CGRectOffset(bgImageView.frame, 0.0, self.frame.size.height - 422.0);
		bgImageView.userInteractionEnabled = YES;
		[self addSubview:bgImageView];
	}
	
	return (self);
}


#pragma mark - Navigation


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
