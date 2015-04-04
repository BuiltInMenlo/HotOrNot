//
//  HONCommentItemView.m
//  HotOrNot
//
//  Created by BIM  on 12/31/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+BuiltinMenlo.h"
#import "UILabel+BuiltinMenlo.h"
#import "UIView+BuiltinMenlo.h"

#import "HONCommentItemView.h"

@interface HONCommentItemView()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UIImageView *photoIconImageView;
@end

@implementation HONCommentItemView
@synthesize commentVO = _commentVO;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_bgView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 11.0, self.frame.size.width - 10.0, 38.0)];
		_bgView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.90];
		[self addSubview:_bgView];
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 20.0, self.frame.size.width - 74.0, 18.0)];
		_captionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
		_captionLabel.backgroundColor = [UIColor clearColor];
//		_captionLabel.backgroundColor = [[HONColorAuthority sharedInstance] honDebugColor:HONDebugVioletColor];
		_captionLabel.textColor = [UIColor whiteColor];
		_captionLabel.lineBreakMode = NSLineBreakByWordWrapping;
		[self addSubview:_captionLabel];
		
		_photoIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_captionLabel.frameEdges.right, 20.0, 0.0, 0.0)];
		//_photoIconImageView.backgroundColor = [[HONColorAuthority sharedInstance] honDebugColor:HONDebugRedColor];
		_photoIconImageView.image = [UIImage imageNamed:@"viewPhotoButton_Selected"];
		[self addSubview:_photoIconImageView];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setCommentVO:(HONCommentVO *)commentVO {
	_commentVO = commentVO;
	
	NSString *caption = [NSString stringWithFormat:@"%@ %@", _commentVO.username, _commentVO.textContent];
	_captionLabel.text = caption;
	_captionLabel.numberOfLines = [_captionLabel numberOfLinesNeeded];
	_captionLabel.textColor = (_commentVO.messageType == HONChatMessageTypeBOT) ? [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.75] : _captionLabel.textColor;
	[_captionLabel setTextColor:(_commentVO.messageType == HONChatMessageTypeBOT) ? [UIColor colorWithRed:1.000 green:0.635 blue:0.000 alpha:1.00] : [UIColor colorWithRed:1.000 green:0.847 blue:0.000 alpha:1.00] range:[_captionLabel.text rangeOfString:_commentVO.username]];
//	NSLog(@"SIZE:[%@] -=- %d", NSStringFromCGSize([_captionLabel sizeForText]), [_captionLabel numberOfLinesNeeded]);
	[_captionLabel resizeFrameForText];
	
	_photoIconImageView.frame = CGRectTranslateX(_photoIconImageView.frame, _captionLabel.frameEdges.right);
	
	if (_commentVO.messageType == HONChatMessageTypeIMG) {
		//_photoIconImageView.frame = CGRectResize(_photoIconImageView.frame, _photoIconImageView.image.size);
		//_photoIconImageView.frame = CGRectTranslate(_photoIconImageView.frame, CGPointMake(_captionLabel.frameEdges.right + 10.0, _captionLabel.frame.origin.y + (_captionLabel.frame.size.height - _photoIconImageView.frame.size.height) * 0.5));
		
		UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
		lpGestureRecognizer.minimumPressDuration = 0.25;
		lpGestureRecognizer.delaysTouchesBegan = YES; //
//		lpGestureRecognizer.cancelsTouchesInView = NO;
//		lpGestureRecognizer.delaysTouchesEnded = NO;
		[self addGestureRecognizer:lpGestureRecognizer];
	
	} else if (_commentVO.messageType == HONChatMessageTypeVID) {
	} else if (_commentVO.messageType == HONChatMessageTypeAUT) {
		_photoIconImageView.image = [UIImage imageNamed:@"autShareButton_nonActive"];
		_photoIconImageView.frame = CGRectResize(_photoIconImageView.frame, _photoIconImageView.image.size);
		_photoIconImageView.frame = CGRectTranslate(_photoIconImageView.frame, CGPointMake(10.0, 0.0));
		_captionLabel.frame = _photoIconImageView.frame;
		
		UIButton *linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		linkButton.frame = _photoIconImageView.frame;
		[linkButton addTarget:self action:@selector(_goCopyLink) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:linkButton];
		
		_bgView.hidden = YES;
	}
	
	_bgView.frame = CGRectResizeWidth(_bgView.frame, MIN(_photoIconImageView.frameEdges.right, self.frame.size.width - 20.0));
	_bgView.frame = CGRectResizeHeight(_bgView.frame, _captionLabel.frame.size.height + 20.0);
	
	NSLog(@"FRAMES -- BG:[%@] CAPTION:[%@] BUTTON:[%@]", NSStringFromCGRect(_bgView.frame), NSStringFromCGRect(_captionLabel.frame), NSStringFromCGRect(_photoIconImageView.frame));
	
	self.frame = CGRectResize(self.frame, _bgView.frame.size);
	self.frame = CGRectResizeHeight(self.frame, _bgView.frameEdges.bottom + 5.0);
}


#pragma mark - Public APIs
- (void)updateStatus:(HONCommentStatusType)statusType {
}


#pragma mark - Navigation
-(void)_goLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		NSLog(@"gestureRecognizer.state:[%@]", NSStringFromUIGestureRecognizerState(gestureRecognizer.state));
		
		CGPoint touchPoint = [gestureRecognizer locationInView:self];
		NSLog(@"TOUCH:%@", NSStringFromCGPoint(touchPoint));
		
		if (CGRectContainsPoint(CGRectInset(_photoIconImageView.frame, -16.0, -16.0), touchPoint)) {
			if ([self.delegate respondsToSelector:@selector(commentItemView:showPhotoForComment:)])
				[self.delegate commentItemView:self showPhotoForComment:_commentVO];
		}
		
	} else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		NSLog(@"gestureRecognizer.state:[%@]", NSStringFromUIGestureRecognizerState(gestureRecognizer.state));
		
		if ([self.delegate respondsToSelector:@selector(commentItemView:hidePhotoForComment:)])
			[self.delegate commentItemView:self hidePhotoForComment:_commentVO];
	}
}

- (void)_goCopyLink {
	if ([self.delegate respondsToSelector:@selector(commentItemViewShareLink:)])
		[self.delegate commentItemViewShareLink:self];
}

@end
