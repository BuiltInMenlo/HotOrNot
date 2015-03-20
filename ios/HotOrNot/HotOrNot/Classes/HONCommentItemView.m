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
//@property (nonatomic, strong) UIImageView *loadingImageView;
//@property(nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UIButton *photoButton;
//@property (nonatomic, strong) UIImageView *captionImageView;
//@property (nonatomic, strong) UIImageView *statusImageView;
//@property (nonatomic, strong) UILabel *timeLabel;
//@property (nonatomic, strong) UILabel *localityLabel;
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
		
		_photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_photoButton.frame = CGRectMake(_captionLabel.frameEdges.right, 20.0, 0.0, 0.0);
//		_photoButton.backgroundColor = [[HONColorAuthority sharedInstance] honDebugColor:HONDebugRedColor];
		[_photoButton setBackgroundImage:[UIImage imageNamed:@"viewPhotoButton_nonActive"] forState:UIControlStateNormal];
		[_photoButton setBackgroundImage:[UIImage imageNamed:@"viewPhotoButton_Active"] forState:UIControlStateHighlighted];
		[_photoButton setBackgroundImage:[UIImage imageNamed:@"viewPhotoButton_Disabled"] forState:UIControlStateDisabled];
		[_photoButton setBackgroundImage:[UIImage imageNamed:@"viewPhotoButton_Selected"] forState:UIControlStateSelected];
		[_photoButton setBackgroundImage:[UIImage imageNamed:@"viewPhotoButton_Selected"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
		[self addSubview:_photoButton];
		
//		UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		overlayButton.frame = CGRectFromSize(self.frame.size);
//		[self addSubview:overlayButton];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setCommentVO:(HONCommentVO *)commentVO {
	_commentVO = commentVO;
	
	/*
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_avatarImageView.image = image;
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		NSLog(@"ERROR:[%@]", error.description);
		_avatarImageView.image = [UIImage imageNamed:@"placeholderClubPhoto_320x320"];
	};
	
	//NSLog(@"URL:[%@]", _commentVO.avatarPrefix);
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_commentVO.avatarPrefix]
															   cachePolicy:kOrthodoxURLCachePolicy
														   timeoutInterval:[HONAPICaller timeoutInterval]]
							 placeholderImage:[UIImage imageNamed:@"loadingDots_50"]
									  success:imageSuccessBlock
									  failure:imageFailureBlock];
	*/
	
	//_avatarImageView.image = (_commentVO.userID == [[HONUserAssistant sharedInstance] activeUserID]) ? [UIImage imageNamed:@"greenAvatar"] : [UIImage imageNamed:@"greyAvatar"];
	
	NSString *caption = [NSString stringWithFormat:@"%@ %@", _commentVO.username, _commentVO.textContent];
	_captionLabel.text = caption;
	_captionLabel.numberOfLines = [_captionLabel numberOfLinesNeeded];
	_captionLabel.textColor = (_commentVO.commentContentType == HONCommentContentTypeBOT) ? [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.75] : _captionLabel.textColor;
	[_captionLabel setTextColor:(_commentVO.commentContentType == HONCommentContentTypeBOT) ? [UIColor colorWithRed:1.000 green:0.635 blue:0.000 alpha:1.00] : [UIColor colorWithRed:1.000 green:0.847 blue:0.000 alpha:1.00] range:[_captionLabel.text rangeOfString:_commentVO.username]];
//	NSLog(@"SIZE:[%@] -=- %d", NSStringFromCGSize([_captionLabel sizeForText]), [_captionLabel numberOfLinesNeeded]);
	[_captionLabel resizeFrameForText];
	
	_photoButton.frame = CGRectTranslateX(_photoButton.frame, _captionLabel.frameEdges.right);
	
	if (_commentVO.commentContentType == HONCommentContentTypeImage) {
		_photoButton.frame = CGRectResize(_photoButton.frame, [_photoButton backgroundImageForState:UIControlStateNormal].size);
		_photoButton.frame = CGRectTranslate(_photoButton.frame, CGPointMake(_captionLabel.frameEdges.right + 10.0, _captionLabel.frame.origin.y + (_captionLabel.frame.size.height - _photoButton.frame.size.height) * 0.5));
		[_photoButton addTarget:self action:@selector(_goShowPhoto) forControlEvents:UIControlEventTouchUpInside];
	}
	
	_bgView.frame = CGRectResizeWidth(_bgView.frame, MIN(_photoButton.frameEdges.right, self.frame.size.width - 20.0));
	_bgView.frame = CGRectResizeHeight(_bgView.frame, _captionLabel.frame.size.height + 20.0);
	
	//_timeLabel.text = [[HONDateTimeAlloter sharedInstance] intervalSinceDate:_commentVO.addedDate];
	//_timeLabel.frame = CGRectTranslate(_timeLabel.frame, CGPointMake(_bgImageView.frameEdges.right + 8.0, 0.0 + (_bgImageView.frameEdges.top + (_bgImageView.frame.size.height - _timeLabel.frame.size.height) * 0.5)));
	
	//[[HONGeoLocator sharedInstance] addressForLocation:_commentVO.location onCompletion:^(NSDictionary *result) {
	//	_localityLabel.text = [result objectForKey:@"city"];
	//}];
	
	//_avatarImageView.frame = CGRectTranslateY(_avatarImageView.frame, _bgImageView.frameEdges.bottom - _avatarImageView.frame.size.height);
	//_localityLabel.frame = CGRectTranslateY(_localityLabel.frame, _bgImageView.frameEdges.bottom + 8);
	
//	_bgImageView.hidden = (_commentVO.commentContentType == HONCommentContentTypeImage);
//	_captionImageView.hidden = (_commentVO.commentContentType != HONCommentContentTypeImage);
//	_statusImageView.hidden = (_commentVO.userID != [[HONUserAssistant sharedInstance] activeUserID]);
	
	if (_commentVO.userID == [[HONUserAssistant sharedInstance] activeUserID]) {
		//_bgImageView.image = [[UIImage imageNamed:@"greenChatBubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(17.0, 17.0, 17.0, 27.0) resizingMode:UIImageResizingModeStretch];
		//_captionLabel.textAlignment = NSTextAlignmentRight;
		//_timeLabel.textAlignment = NSTextAlignmentRight;
		//_localityLabel.textAlignment = NSTextAlignmentRight;
		
//		_loadingImageView.frame = CGRectTranslateX(_loadingImageView.frame, self.frame.size.width - 30.0);
//		_avatarImageView.frame = CGRectTranslateX(_avatarImageView.frame, self.frame.size.width - 50.0);
//		_avatarImageView.frame = CGRectTranslateY(_avatarImageView.frame, _bgImageView.frameEdges.top);
		
		//_captionLabel.frame = CGRectTranslateX(_captionLabel.frame, (self.frame.size.width - 83.0) - _captionLabel.frame.size.width);
		//_bgImageView.frame = CGRectTranslateX(_bgImageView.frame, (self.frame.size.width - 60.0) - _bgImageView.frame.size.width);
		//_timeLabel.frame = CGRectTranslateX(_timeLabel.frame, (self.frame.size.width - 60.0) - (_bgImageView.frame.size.width + 10.0) - _timeLabel.frame.size.width);
		//_localityLabel.frame = CGRectTranslateX(_localityLabel.frame, _captionLabel.frameEdges.right - _localityLabel.frame.size.width);
	}
	
	
	NSLog(@"FRAMES -- BG:[%@] CAPTION:[%@] BUTTON:[%@]", NSStringFromCGRect(_bgView.frame), NSStringFromCGRect(_captionLabel.frame), NSStringFromCGRect(_photoButton.frame));
	
	self.frame = CGRectResize(self.frame, _bgView.frame.size);
	self.frame = CGRectResizeHeight(self.frame, _bgView.frameEdges.bottom + 5.0);
}


#pragma mark - Public APIs
- (void)updateStatus:(HONCommentStatusType)statusType {
}


#pragma mark - Navigation
- (void)_goShowPhoto {
	if ([self.delegate respondsToSelector:@selector(commentItemView:showPhotoForComment:)])
		[self.delegate commentItemView:self showPhotoForComment:_commentVO];
}

@end
