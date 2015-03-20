//
//  HONImageRevealerView.m
//  HotOrNot
//
//  Created by BIM  on 3/19/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONImageRevealerView.h"
#import "HONLoadingOverlayView.h"

@interface HONImageRevealerView () <HONLoadingOverlayViewDelegate>
@property (nonatomic, strong) HONCommentVO *commentVO;
@property (nonatomic, strong) HONLoadingOverlayView *loadingOverlayView;
@property (nonatomic, strong) UILabel *usernameLabel;
@end

@implementation HONImageRevealerView
@synthesize delegate = _delegate;

- (id)initWithComment:(HONCommentVO *)commentVO {
	if ((self = [super initWithFrame:[UIScreen mainScreen].bounds])) {
		_commentVO = commentVO;
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)intro {
	
}

- (void)outro {
	[self _decompose];
}


#pragma mark - UI Presentation
- (void)_decompose {
	NSLog(@"::|> _decompose <|::");
	
	[UIView animateKeyframesWithDuration:0.125 * ((int)(self.alpha > 0.0))
								   delay:0.000
								 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut)
							  animations:^(void) {
								  self.alpha = 0.0;
								  
							  } completion:^(BOOL finished) {
								  [self removeFromSuperview];
								  
								  if ([self.delegate respondsToSelector:@selector(imageRevealerViewDidOutro:)])
									  [self.delegate imageRevealerViewDidOutro:self];
							  }];
}

@end
