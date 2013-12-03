//
//  HONCameraSubjectViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/24/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONCameraSubjectViewCell.h"

@interface HONCameraSubjectViewCell()
@property (nonatomic, strong) HONEmotionVO *emotionVO;
@property (nonatomic, strong) UIImageView *priceImageView;
@end

@implementation HONCameraSubjectViewCell

//@synthesize subject = _subject;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initWithEmotion:(HONEmotionVO *)emotionVO AsEvenRow:(BOOL)isEven {
	if ((self = [super init])) {
		self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:(0.15 * isEven)];
		_emotionVO = emotionVO;
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(3.0, 9.0, 44.0, 44.0)];
		[imageView setImageWithURL:[NSURL URLWithString:_emotionVO.imageURL] placeholderImage:nil];
		[self.contentView addSubview:imageView];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 19.0, 200.0, 24.0)];
		label.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:19];
		label.textColor = [UIColor whiteColor];
		label.backgroundColor = [UIColor clearColor];
		label.text = _emotionVO.hastagName;
		[self.contentView addSubview:label];
		
		_priceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"freeButton_nonActive"]];
		_priceImageView.frame = CGRectOffset(_priceImageView.frame, 245.0, 10.0);
		[self addSubview:_priceImageView];
	}
	
	return (self);
}

//- (void)setSubject:(NSDictionary *)subject {
//	_subject = subject;
//	
//	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(3.0, 9.0, 44.0, 44.0)];
//	[imageView setImageWithURL:[NSURL URLWithString:[_subject objectForKey:@"img"]] placeholderImage:nil];
//	[self.contentView addSubview:imageView];
//	
//	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 19.0, 200.0, 24.0)];
//	label.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:19];
//	label.textColor = [UIColor whiteColor];
//	label.backgroundColor = [UIColor clearColor];
//	label.text = [_subject objectForKey:@"text"];
//	[self.contentView addSubview:label];
//}

- (void)showTapOverlay {
	_priceImageView.image = [UIImage imageNamed:@"freeButton_Active"];
	
	UIView *tappedOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.frame.size.height)];
	tappedOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.67];
	[self.contentView addSubview:tappedOverlayView];
	
	[UIView animateWithDuration:0.125 animations:^(void) {
		tappedOverlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[tappedOverlayView removeFromSuperview];
		_priceImageView.image = [UIImage imageNamed:@"freeButton_nonActive"];
	}];
}

@end
