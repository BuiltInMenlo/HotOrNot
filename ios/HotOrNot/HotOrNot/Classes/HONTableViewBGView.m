//
//  HONTableViewBGView.m
//  HotOrNot
//
//  Created by BIM  on 10/4/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UILabel+BoundingRect.h"
#import "UILabel+FormattedText.h"

#import "HONTableViewBGView.h"

@interface HONTableViewBGView ()
@property (nonatomic, strong) NSParagraphStyle *paragraphStyle;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) UILabel *label;
@end

@implementation HONTableViewBGView
@synthesize delegate = _delegate;
@synthesize viewType = _viewType;
@synthesize yOffset = _yOffset;

- (id)initAsType:(HONTableViewBGViewType)type withCaption:(NSString *)caption usingTarget:(id)target action:(SEL)action {
	if ((self = [super initWithFrame:CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 59.0) * 0.5, 320.0, 59.0)])) {
		self.hidden = YES;
		
		_viewType = type;
		_caption = caption;
		
		NSRange range = [_caption rangeOfString:@"\n"];
		range.length = [[_caption substringFromIndex:range.location] length];
		
		NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
		style.minimumLineHeight = 29.0;
		style.maximumLineHeight = style.minimumLineHeight;
		style.alignment = NSTextAlignmentCenter;
		_paragraphStyle = [style copy];
		
		_label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		_label.backgroundColor = [UIColor clearColor];
		_label.font = [[[HONFontAllocator sharedInstance] cartoGothicBook] fontWithSize:19];
		_label.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		_label.numberOfLines = 2;
		_label.attributedText = [[NSAttributedString alloc] initWithString:_caption attributes:@{NSParagraphStyleAttributeName	: _paragraphStyle}];
		[_label setFont:[[[HONFontAllocator sharedInstance] cartoGothicBold] fontWithSize:_label.font.pointSize] range:range];
		[self addSubview:_label];
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = _label.frame;//[_label boundingRectForCharacterRange:range];
		[button setTag:_viewType];
		[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setViewType:(HONTableViewBGViewType)viewType {
	_viewType = viewType;
}

- (void)setYOffset:(CGFloat)yOffset {
	_yOffset = yOffset;
	self.frame = CGRectMake(self.frame.origin.x, _yOffset + (([UIScreen mainScreen].bounds.size.height - self.frame.size.height) * 0.5), self.frame.size.width, self.frame.size.height);
}


#pragma mark - Navigation
@end
