//
//  HONEmotionsPickerDisplayView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 00:03 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONEmotionsPickerDisplayView.h"
#import "HONColorAuthority.h"
#import "HONDeviceIntrinsics.h"
#import "HONFontAllocator.h"
#import "HONPhysicsGovernor.h"

#define MAX_DISPLAYED_NAMES 5
#define COLS_PER_ROW 5

const CGSize kMaxLabelSize = {240.0, 66.0};

@interface HONEmotionsPickerDisplayView ()
@property (nonatomic, strong) NSMutableArray *emotions;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *imageHolderView;
@property (nonatomic) CGSize captionSize;
@end

@implementation HONEmotionsPickerDisplayView

- (id)initWithFrame:(CGRect)frame withExistingEmotions:(NSArray *)emotions {
	if ((self = [super initWithFrame:frame])) {
		_emotions = [emotions mutableCopy];
		
		_label = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 10.0, 260.0, 22.0)];
		_label.backgroundColor = [UIColor clearColor];
		_label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
		_label.textColor = [UIColor whiteColor];
		_label.numberOfLines = 0;
		[self addSubview:_label];
		
		_imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(_label.frame.origin.x + _label.frame.size.width + 10.0, 0.0, 44.0, 44.0)];
		//_imageHolderView.backgroundColor = [[HONColorAuthority sharedInstance] honDebugColor:HONDebugBlueColor];
		[self addSubview:_imageHolderView];
		
		[self _updateLabel];
		
		for (HONEmotionVO *vo in _emotions)
			[self _appendImageWithEmotion:vo];
		
		
		
//		NSLog(@"[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n\n");
//		
//		for (int i=8; i<=36; i++) {
//			_label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:i];
//			[self _updateLabel];
//		}
//		NSLog(@"[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n");
//		
//		for (int i=8; i<=36; i++) {
//			_label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:i];
//			[self _updateLabel];
//		}
//		NSLog(@"[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n");
//		
//		for (int i=8; i<=36; i++) {
//			_label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:i];
//			[self _updateLabel];
//		}
//		NSLog(@"[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n");
//		
//		for (int i=8; i<=36; i++) {
//			_label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:i];
//			[self _updateLabel];
//		}
//		NSLog(@"[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n");
		
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
		[self _updateLabel];
		[_emotions removeObject:dropEmotionVO];
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
	
	if (cnt <= MIN([_emotions count], ([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? 10 : 5)) {
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(col * 60, row * 60.0, 44.0, 44.0)];
		//imageView.backgroundColor = [[HONColorAuthority sharedInstance] honDebugColor:HONDebugGreenColor];
		[imageView setTag:emotionVO.emotionID];
		imageView.alpha = 0.0;
		[_imageHolderView addSubview:imageView];
		
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			imageView.image = image;
			
			[UIView animateWithDuration:[[HONPhysicsGovernor sharedInstance] springOrthodoxDuration] delay:[[HONPhysicsGovernor sharedInstance] springOrthodoxDelay]
				 usingSpringWithDamping:[[HONPhysicsGovernor sharedInstance] springOrthodoxDampening] initialSpringVelocity:[[HONPhysicsGovernor sharedInstance] springOrthodoxInitVelocity]
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
		
	[UIView animateWithDuration:[[HONPhysicsGovernor sharedInstance] springOrthodoxDuration] * 0.5 delay:[[HONPhysicsGovernor sharedInstance] springOrthodoxDelay]
		 usingSpringWithDamping:[[HONPhysicsGovernor sharedInstance] springOrthodoxDampening] initialSpringVelocity:0.0
						options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent
	 
					 animations:^(void) {
						 imageView.alpha = 0.0;
						 
					 } completion:^(BOOL finished) {
						 if (index <= [_imageHolderView.subviews count] - 1)
							 [self _consolidateImageViewsInRange:NSMakeRange(index+1, [_imageHolderView.subviews count] - (index + 1))];
					 }];
}

- (void)_consolidateImageViewsInRange:(NSRange)range {
	UIImageView *dropImageView = (UIImageView *)[_imageHolderView.subviews objectAtIndex:range.location - 1];
	
	int col, row;
	for (int i=range.location; i<[_imageHolderView.subviews count]; i++) {
		col = (i - 1) % COLS_PER_ROW;
		row = (int)floor((i - 1) / COLS_PER_ROW);
		
		UIImageView *imageView = (UIImageView *)[_imageHolderView.subviews objectAtIndex:i];
		[UIView animateWithDuration:[[HONPhysicsGovernor sharedInstance] springOrthodoxDuration] delay:[[HONPhysicsGovernor sharedInstance] springOrthodoxDelay]
			 usingSpringWithDamping:[[HONPhysicsGovernor sharedInstance] springOrthodoxDampening] initialSpringVelocity:[[HONPhysicsGovernor sharedInstance] springOrthodoxInitVelocity]
							options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent
		 
						 animations:^(void) {
							 imageView.frame = CGRectMake(col * 60.0, row * 60.0, imageView.frame.size.width, imageView.frame.size.height);
							 
						 } completion:^(BOOL finished) {
							 if (i == [_imageHolderView.subviews count] - 1)
								 [dropImageView removeFromSuperview];
						 }];
	}
	
	
}

- (void)_updateLabel {
	//_label.text = [[NSAttributedString alloc] initWithString:[self _captionForEmotions] attributes:@{}];
	
	NSDictionary *attribParams = @{NSFontAttributeName				: _label.font,
								   NSShadowAttributeName			: [[HONFontAllocator sharedInstance] orthodoxShadowAttribute],
								   NSParagraphStyleAttributeName	: [[HONFontAllocator sharedInstance] doubleLineSpacingParagraphStyleForFont:_label.font]};
	
	_captionSize = [[self _captionForEmotions] boundingRectWithSize:kMaxLabelSize
															options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
														 attributes:attribParams
															context:nil].size;
	
	_captionSize = CGSizeMake(MIN(ceil(_captionSize.width), kMaxLabelSize.width), MIN(ceil(_captionSize.height), kMaxLabelSize.height));
	
	_label.frame = CGRectMake(_label.frame.origin.x, _label.frame.origin.y, _captionSize.width, _captionSize.height);
	_label.attributedText = [[NSAttributedString alloc] initWithString:[self _captionForEmotions] attributes:attribParams];
	
	_imageHolderView.frame = CGRectMake(([_emotions count] == 1) ? _label.frame.origin.x + _label.frame.size.width : 10.0, ([_emotions count] == 1) ? 0.0 : _label.frame.origin.y + _label.frame.size.height, ([_emotions count] == 1) ? 60.0 : 300.0, 60.0 + ((int)ceil([_emotions count] / COLS_PER_ROW) * 60.0));

	
	NSLog(@"\n\t\t|--|--|--|--|--|--|:|--|--|--|--|--|--|");
	NSLog(@"FONT ATTRIBS:[%@]", _label.font.fontDescriptor.fontAttributes);
	NSLog(@"--// %@ @ (%d) //--", [_label.font.fontDescriptor.fontAttributes objectForKey:@"NSFontNameAttribute"], (int)_label.font.pointSize);
	NSLog(@"DRAW SIZE:[%@] ATTR SIZE:[%@]", NSStringFromCGSize(_captionSize), NSStringFromCGSize(_label.attributedText.size));
	NSLog(@"X-HEIGHT:[%f]", _label.font.xHeight);
	NSLog(@"CAP:[%f]", _label.font.capHeight);
	NSLog(@"ASCENDER:[%f] DESCENDER:[%f]", _label.font.ascender, _label.font.descender);
	NSLog(@"LINE HEIGHT:[%f]", _label.font.lineHeight);
	NSLog(@"[=-=-=-=-=-=-=-=-=|=-=-=-=-=-=-=-=-=|:|=-=-=-=-=-=-=-=-=|=-=-=-=-=-=-=-=-=]");
}


#pragma mark - Data Tally
- (NSString *)_captionForEmotions {
	NSString *emotionNames = @"";
	int cnt = 0;
	
	for (HONEmotionVO *vo in _emotions) {
		emotionNames = [emotionNames stringByAppendingFormat:@"%@, ", vo.emotionName];
		cnt++;
		
		if (cnt == MAX_DISPLAYED_NAMES)
			break;
	}
	
	emotionNames = ([emotionNames length] >= 2) ? [emotionNames substringToIndex:[emotionNames length] - 2] : @"";
	return (([_emotions count] > 0) ? [NSString stringWithFormat:@"- is feeling %@%@", emotionNames, ([_emotions count] > MAX_DISPLAYED_NAMES) ? [NSString stringWithFormat:@", +%d more…", ([_emotions count] - MAX_DISPLAYED_NAMES)] : @""] : @"- is feeling…");
}


@end
