//
//  HONEmoticonPickerItemView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/21/2014 @ 20:44 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "UIImageView+AFNetworking.h"

#import "HONEmoticonPickerItemView.h"

@interface HONEmoticonPickerItemView ()
@property (nonatomic, strong) HONEmotionVO *emotionVO;
@property (nonatomic, strong) UIImageView *selectedImageView;
@property (nonatomic) BOOL isSelected;
@end

@implementation HONEmoticonPickerItemView

- (id)initAtPosition:(CGPoint)position withEmotion:(HONEmotionVO *)emotionVO {
	if ((self = [super initWithFrame:CGRectMake(position.x, position.y, 75.0, 75.0)])) {
		_emotionVO = emotionVO;
		_isSelected = NO;
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 16.0, 44.0, 44.0)];
		[self addSubview:imageView];
		
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			imageView.image = image;
			
			[UIView animateWithDuration:0.25 animations:^(void) {
				imageView.alpha = 1.0;
			} completion:nil];
		};
		
		[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_emotionVO.imageURL] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						 placeholderImage:nil
								  success:imageSuccessBlock
								  failure:nil];
		
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 13.0)];
		label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:11];
		label.textColor = [UIColor blackColor];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		label.text = _emotionVO.emotionName;
		[self addSubview:label];
		
		_selectedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emotionSelectedOverlay"]];
		_selectedImageView.alpha = (int)_isSelected;
		[self addSubview:_selectedImageView];
		
		UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
		toggleButton.frame = imageView.frame;
		[toggleButton addTarget:self action:@selector(_goToggle) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:toggleButton];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goToggle {
	_isSelected = !_isSelected;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_selectedImageView.alpha = (int)_isSelected;
		
	} completion:^(BOOL finished) {
		if (_isSelected) {
			if ([self.delegate respondsToSelector:@selector(emotionItemView:selectedEmotion:)])
				[self.delegate emotionItemView:self selectedEmotion:_emotionVO];
		
		} else {
			if ([self.delegate respondsToSelector:@selector(emotionItemView:deselectedEmotion:)])
				[self.delegate emotionItemView:self deselectedEmotion:_emotionVO];
		}
	}];
}


@end
