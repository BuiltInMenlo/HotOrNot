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

NSString * const kBaseCaption = @"- is feeling";
const CGSize kImageSize = {37.0f, 37.0f};
const CGSize kImagePaddingSize = {17.0f, 17.0f};
const CGSize kLabelMaxSize = {220.0f, 22.0f};

@interface HONEmotionsPickerDisplayView ()
@property (nonatomic, strong) NSMutableArray *emotions;
@property (nonatomic, strong) UILabel *label;
//@property (nonatomic, strong) UIView *emotionHolderView;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIImageView *cursorImageView;
@end

@implementation HONEmotionsPickerDisplayView

- (id)initWithFrame:(CGRect)frame withPreviewImage:(UIImage *)image {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor whiteColor];
		
		
		_previewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 71.0, 44.0, 44.0)];
		_previewImageView.image = image;
		[self addSubview:_previewImageView];
		

		[HONImagingDepictor maskImageView:_previewImageView withMask:[UIImage imageNamed:@"thumbMask"]];
		
		_emotions = [NSMutableArray array];
		
		_label = [[UILabel alloc] initWithFrame:CGRectMake(_previewImageView.frame.origin.x + _previewImageView.frame.size.width + 10.0, 82.0, kLabelMaxSize.width, kLabelMaxSize.height)];
		_label.backgroundColor = [UIColor whiteColor];
		_label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
		_label.textColor = [UIColor blackColor];
		_label.text = kBaseCaption;
		[self addSubview:_label];
		
		_cursorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_label.frame.origin.x + _label.frame.size.width + 3.0, 79.0, 2.0, 30.0)];
		_cursorImageView.animationImages = @[[UIImage imageNamed:@"emojiCursor_off"], [UIImage imageNamed:@"emojiCursor_on"]];
		_cursorImageView.animationDuration = 0.875;
		_cursorImageView.animationRepeatCount = 0;
		[self addSubview:_cursorImageView];
		[_cursorImageView startAnimating];
		
//		_emotionHolderView = [[UIView alloc] initWithFrame:CGRectMake(_label.frame.origin.x + _label.frame.size.width + 5.0, 72.0, 44.0, 44.0)];
//		_emotionHolderView.backgroundColor = [[HONColorAuthority sharedInstance] honDebugColor:HONDebugBlueColor];
//		[self addSubview:_emotionHolderView];
		
		[self _updateLabel];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)addEmotion:(HONEmotionVO *)emotionVO {
	[_emotions addObject:emotionVO];
	
	[self _updateLabel];
	[self _replaceImageWithEmotion:emotionVO];
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
		
		if ([_emotions count] == 0)
			[self _removeImageEmotion];
		
		else
			[self _replaceImageWithEmotion:[_emotions lastObject]];
		
		[self _updateLabel];
	}
}


#pragma mark - UI Presentation
- (void)_replaceImageWithEmotion:(HONEmotionVO *)emotionVO {
//	if ([_emotionHolderView.subviews count] > 0) {
//		UIImageView *imageView = [_emotionHolderView.subviews firstObject];
//		
//		[UIView animateWithDuration:0.125 delay:0.0
//			 usingSpringWithDamping:0.875 initialSpringVelocity:0.0
//							options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent
//		 
//						 animations:^(void) {
//							 imageView.alpha = 0.0;
//							 
//						 } completion:^(BOOL finished) {
//							 void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//								 imageView.image = image;
//							 
//								 [UIView animateWithDuration:0.33 delay:0.0
//									  usingSpringWithDamping:0.875 initialSpringVelocity:0.5
//													 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent
//								  
//												  animations:^(void) {
//													  imageView.alpha = 1.0;
//												  } completion:^(BOOL finished) {
//												  }];
//							 };
//							 
//							 [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:emotionVO.imageURL] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
//											  placeholderImage:nil
//													   success:imageSuccessBlock
//													   failure:nil];
//						 }];
//		
//	} else {
//		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
//		imageView.alpha = 0.0;
//		[_emotionHolderView addSubview:imageView];
//		
//		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//			imageView.image = image;
//			
//			[UIView animateWithDuration:0.33 delay:0.0
//				 usingSpringWithDamping:0.875 initialSpringVelocity:0.5
//								options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent
//			 
//							 animations:^(void) {
//								 imageView.alpha = 1.0;
//							 } completion:^(BOOL finished) {
//							 }];
//		};
//		
//		[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:emotionVO.imageURL] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
//						 placeholderImage:nil
//								  success:imageSuccessBlock
//								  failure:nil];
//	}
}

- (void)_removeImageEmotion {
//	UIImageView *imageView = [_emotionHolderView.subviews firstObject];
//	
//	[UIView animateWithDuration:0.125 delay:0.0
//		 usingSpringWithDamping:0.875 initialSpringVelocity:0.0
//						options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent
//	 
//					 animations:^(void) {
//						 imageView.alpha = 0.0;
//						 
//					 } completion:^(BOOL finished) {
//					 }];
}


- (void)_updateLabel {
	if ([_emotions count] > 0) {
		HONEmotionVO *vo = (HONEmotionVO *)[_emotions lastObject];
		
		_label.text = [kBaseCaption stringByAppendingFormat:@" %@", vo.emotionName];
		[_label setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:18] range:[_label.text rangeOfString:vo.emotionName]];
		
	
	} else {
		_label.text = kBaseCaption;
		[_label setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18] range:[_label.text rangeOfString:_label.text]];
	}
	
	CGSize neededSize = [[_label.text stringByAppendingString:@" "] boundingRectWithSize:kLabelMaxSize
																				 options:(NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin)
																			  attributes:@{NSFontAttributeName:_label.font}
																				 context:nil].size;
	
//	CGSize neededSize = [[[NSAttributedString alloc] initWithString:_label.text attributes:@{NSFontAttributeName:_label.font}]
//						 boundingRectWithSize:kLabelMaxSize
//						 options:NSStringDrawingTruncatesLastVisibleLine
//						 context:nil].size;
	
	CGSize actualSize = CGSizeMake(MIN(neededSize.width, kLabelMaxSize.width) + 3.0, kLabelMaxSize.height);
//	NSLog(@"SIZE:[%@] MAX:[%@] // (%@) <<%@>>", NSStringFromCGSize(neededSize), NSStringFromCGSize(kLabelMaxSize), NSStringFromCGSize(actualSize), _label.text);
	
	
	
//	int orgX = (320.0 - ((([_emotions count] > 0) ? 103.0 : 54.0) + actualSize.width)) * 0.5;
	int orgX = (320.0 - (54.0 + actualSize.width)) * 0.5;
	_previewImageView.frame = CGRectMake(orgX, _previewImageView.frame.origin.y, _previewImageView.frame.size.width, _previewImageView.frame.size.height);
	_label.frame = CGRectMake(_previewImageView.frame.origin.x + _previewImageView.frame.size.width + 10.0, _label.frame.origin.y, actualSize.width, actualSize.height);
	_cursorImageView.frame = CGRectMake(_label.frame.origin.x + _label.frame.size.width + 3.0, _cursorImageView.frame.origin.y, _cursorImageView.frame.size.width, _cursorImageView.frame.size.height);
//	_emotionHolderView.frame = CGRectMake(_label.frame.origin.x + _label.frame.size.width + 5.0, 72.0, 44.0, 44.0);
	
	
		  
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
