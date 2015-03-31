//
//  HONStatusUpdateFooterView.m
//  HotOrNot
//
//  Created by BIM  on 3/18/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "UIView+BuiltInMenlo.h"

#import "HONStatusUpdateFooterView.h"

@interface HONStatusUpdateFooterView()
@property (nonatomic, strong) UIButton *takePhotoButton;
@end

@implementation HONStatusUpdateFooterView
@synthesize delegate = _delegate;

- (id)init {
	if ((self = [super initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 75.0, [UIScreen mainScreen].bounds.size.width, 75.0)])) {
		
		_takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_takePhotoButton.frame = CGRectMake((self.frame.size.width - 56.0), 0.0, 56.0, 56.0);
		[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_nonActive"] forState:UIControlStateNormal];
		[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Active"] forState:UIControlStateHighlighted];
		[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButtonDisabled"] forState:UIControlStateDisabled];
		[_takePhotoButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_takePhotoButton];
		
//		UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		commentButton.frame = CGRectMake((_takePhotoButton.frame.origin.x - 56.0) * 0.5, 0.0, 56.0, 56.0);
//		[commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_nonActive"] forState:UIControlStateNormal];
//		[commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Active"] forState:UIControlStateHighlighted];
//		[commentButton addTarget:self action:@selector(_goTextComment) forControlEvents:UIControlEventTouchUpInside];
//		[self addSubview:commentButton];
//		
//		UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		shareButton.frame = CGRectMake(_takePhotoButton.frameEdges.right + ((self.frame.size.width - _takePhotoButton.frameEdges.right) * 0.5), 0.0, 56.0, 56.0);
//		[shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_nonActive"] forState:UIControlStateNormal];
//		[shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_Active"] forState:UIControlStateHighlighted];
//		[shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
//		[self addSubview:shareButton];
	}
	
	return (self);
}

- (void)toggleTakePhotoButton:(BOOL)isEnabled {
	[_takePhotoButton setEnabled:isEnabled];
}


#pragma mark - Navigation
- (void)_goTextComment {
	if ([self.delegate respondsToSelector:@selector(statusUpdateFooterViewEnterComment:)])
		[self.delegate statusUpdateFooterViewEnterComment:self];
}

- (void)_goShare {
	if ([self.delegate respondsToSelector:@selector(statusUpdateFooterViewShowShare:)])
		[self.delegate statusUpdateFooterViewShowShare:self];
}

- (void)_goTakePhoto {
	if ([self.delegate respondsToSelector:@selector(statusUpdateFooterViewTakePhoto:)])
		[self.delegate statusUpdateFooterViewTakePhoto:self];
}

@end
