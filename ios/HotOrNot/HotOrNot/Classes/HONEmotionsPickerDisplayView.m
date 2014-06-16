//
//  HONEmotionsPickerDisplayView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 00:03 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "UILabel+BoundingRect.h"
#import "UILabel+FormattedText.h"

#import "HONEmotionsPickerDisplayView.h"

#define COLS_PER_ROW 6
#define SPACING

NSString * const kBaseCaption = @"is feeling";
const CGSize kImageSize = {37.0f, 37.0f};
const CGSize kImagePaddingSize = {17.0f, 17.0f};

@interface HONEmotionsPickerDisplayView ()
@property (nonatomic, strong) NSMutableArray *emotions;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *imageHolderView;
@property (nonatomic) CGSize captionSize;
@end

@implementation HONEmotionsPickerDisplayView

- (id)initWithFrame:(CGRect)frame withExistingEmotions:(NSArray *)emotions {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor whiteColor];
		
		_emotions = [emotions mutableCopy];
		
		_label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 300.0, 22.0)];
		_label.backgroundColor = [UIColor clearColor];
		_label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
		_label.textColor = [UIColor blackColor];
		_label.textAlignment = NSTextAlignmentCenter;
		_label.text = [kBaseCaption stringByAppendingString:@"…"];
		[self addSubview:_label];
		
		_imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 40.0, 300.0, self.frame.size.height - 40.0)];
//		_imageHolderView.backgroundColor = [[HONColorAuthority sharedInstance] honDebugColor:HONDebugBlueColor];
		[self addSubview:_imageHolderView];
		
		[self _updateLabel];
		
		for (HONEmotionVO *vo in _emotions)
			[self _appendImageWithEmotion:vo];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)addEmotion:(HONEmotionVO *)emotionVO {
	[_emotions addObject:emotionVO];
	
	[self _updateLabel];
	[self _appendImageWithEmotion:emotionVO];
}

- (void)removeEmotion:(HONEmotionVO *)emotionVO {
	HONEmotionVO *dropEmotionVO = nil;
	for (HONEmotionVO *vo in _emotions) {
		if (vo.emotionID == emotionVO.emotionID) {
			dropEmotionVO = vo;
			break;
		}
	}
	
	if (dropEmotionVO != nil) {
		[_emotions removeObject:dropEmotionVO];
		[self _updateLabel];
	}
	
	
	int ind = 0;
	UIImageView *dropImageView = nil;
	for (UIImageView *imageView in _imageHolderView.subviews) {
		if (imageView.tag == emotionVO.emotionID) {
			dropImageView = imageView;
			break;
		}
		
		ind++;
	}
	
	
	if (dropImageView != nil)
		[self _dropImageAtIndex:ind];
	
	
	if ([_emotions count] == 0) {
		for (UIImageView *imageView in _imageHolderView.subviews)
			[imageView removeFromSuperview];
	}
	
	if ([_imageHolderView.subviews count] == 0)
		[_emotions removeAllObjects];
}


#pragma mark - UI Presentation
- (void)_appendImageWithEmotion:(HONEmotionVO *)emotionVO {
	int cnt = [_imageHolderView.subviews count];
	int col = cnt % COLS_PER_ROW;
	int row = (int)floor(cnt / COLS_PER_ROW);
	
	if (cnt <= MIN([_emotions count], ([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? 18 : 12)) {
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(col * (kImageSize.width + kImagePaddingSize.width), row * (kImageSize.width + kImagePaddingSize.width), kImageSize.width, kImageSize.height)];
		[imageView setTag:emotionVO.emotionID];
		imageView.alpha = 0.0;
		[_imageHolderView addSubview:imageView];
		
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			imageView.image = image;
			
			[UIView animateWithDuration:0.33 delay:0.0
				 usingSpringWithDamping:0.875 initialSpringVelocity:0.5
								options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent
			 
							 animations:^(void) {
								 imageView.alpha = 1.0;
							 } completion:^(BOOL finished) {
							 }];
		};
		
		[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:emotionVO.imageURL] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						 placeholderImage:nil
								  success:imageSuccessBlock
								  failure:nil];
	}
}

- (void)_dropImageAtIndex:(int)index {
	UIImageView *imageView = (UIImageView *)[_imageHolderView.subviews objectAtIndex:index];
		
	[UIView animateWithDuration:0.125 delay:0.0
		 usingSpringWithDamping:0.875 initialSpringVelocity:0.0
						options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent
	 
					 animations:^(void) {
						 imageView.alpha = 0.0;
						 
					 } completion:^(BOOL finished) {
						 if (index == [_imageHolderView.subviews count] - 1)
							 [[_imageHolderView.subviews lastObject] removeFromSuperview];
						 
						 else {
							 if ([_imageHolderView.subviews count] > 0)
								 [self _consolidateImageViewsInRange:NSMakeRange(index+1, [_imageHolderView.subviews count] - (index + 1))];
						 }
					 }];
}

- (void)_consolidateImageViewsInRange:(NSRange)range {
	UIImageView *dropImageView = (UIImageView *)[_imageHolderView.subviews objectAtIndex:range.location - 1];
	
	int col, row;
	for (int i=range.location; i<[_imageHolderView.subviews count]; i++) {
		col = (i - 1) % COLS_PER_ROW;
		row = (int)floor((i - 1) / COLS_PER_ROW);
		
		UIImageView *imageView = (UIImageView *)[_imageHolderView.subviews objectAtIndex:i];
		[UIView animateWithDuration:0.33 delay:0.0
			 usingSpringWithDamping:0.875 initialSpringVelocity:0.5
							options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent
		 
						 animations:^(void) {
							 imageView.frame = CGRectMake(col * (kImageSize.width + kImagePaddingSize.width), row * (kImageSize.width + kImagePaddingSize.width), imageView.frame.size.width, imageView.frame.size.height);
							 
						 } completion:^(BOOL finished) {
							 [dropImageView removeFromSuperview];
						 }];
	}
	
	
}

- (void)_updateLabel {
	
	if ([_emotions count] > 0) {
		HONEmotionVO *vo = (HONEmotionVO *)[_emotions lastObject];
		
		_label.text = [kBaseCaption stringByAppendingFormat:@" %@…", vo.emotionName];
		[_label setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:18] range:[_label.text rangeOfString:vo.emotionName]];
		
	
	} else {
		_label.text = [kBaseCaption stringByAppendingString:@"…"];
		[_label setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:18] range:[_label.text rangeOfString:_label.text]];
	}
	
//	NSLog(@"\n\t\t|--|--|--|--|--|--|:|--|--|--|--|--|--|");
//	NSLog(@"FONT ATTRIBS:[%@]", _label.font.fontDescriptor.fontAttributes);
//	NSLog(@"--// %@ @ (%d) //--", [_label.font.fontDescriptor.fontAttributes objectForKey:@"NSFontNameAttribute"], (int)_label.font.pointSize);
//	NSLog(@"DRAW SIZE:[%@] ATTR SIZE:[%@]", NSStringFromCGSize(_captionSize), NSStringFromCGSize(_label.attributedText.size));
//	NSLog(@"X-HEIGHT:[%f]", _label.font.xHeight);
//	NSLog(@"CAP:[%f]", _label.font.capHeight);
//	NSLog(@"ASCENDER:[%f] DESCENDER:[%f]", _label.font.ascender, _label.font.descender);
//	NSLog(@"LINE HEIGHT:[%f]", _label.font.lineHeight);
//	NSLog(@"[=-=-=-=-=-=-=-=-=|=-=-=-=-=-=-=-=-=|:|=-=-=-=-=-=-=-=-=|=-=-=-=-=-=-=-=-=]");
}


@end
