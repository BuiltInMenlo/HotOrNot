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
@property (nonatomic, strong) UIImageView *loadingImageView;
@property(nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UIImageView *captionImageView;
@property (nonatomic, strong) UIImageView *statusImageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *localityLabel;
@end

@implementation HONCommentItemView
@synthesize commentVO = _commentVO;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor whiteColor];
		
		_loadingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loadingDots_50"]];
		_loadingImageView.frame = CGRectOffset(_loadingImageView.frame, 15.0, 15.0);
//		[self addSubview:_loadingImageView];
		
		_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(17.0, 16.0, 35.0, 35.0)];
		[self addSubview:_avatarImageView];
		
		[[HONViewDispensor sharedInstance] maskView:_avatarImageView withMask:[UIImage imageNamed:@"topicMask"]];
		
		_bgImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"greyChatBubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(19.0, 24.0, 19.0, 19.0) resizingMode:UIImageResizingModeStretch]];
		_bgImageView.frame = CGRectMake(59.0, 16.0, 214.0, 36.0);
		[self addSubview:_bgImageView];
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0, 23.0, 175.0, 18.0)];
		_captionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.textColor = [UIColor blackColor];
		_captionLabel.lineBreakMode = NSLineBreakByWordWrapping;
		[self addSubview:_captionLabel];
		
		_captionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(82.0, 24.0, 35.0, 35.0)];
		[self addSubview:_captionImageView];
		
		_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 19.0, 80.0, 14.0)];
		_timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
		_timeLabel.backgroundColor = [UIColor clearColor];
		_timeLabel.textColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.75];
		[self addSubview:_timeLabel];
		
		_localityLabel = [[UILabel alloc] initWithFrame:CGRectMake(_captionLabel.frameEdges.left, _bgImageView.frameEdges.bottom + 6.0, 180.0, 14.0)];
		_localityLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
		_localityLabel.backgroundColor = [UIColor clearColor];
		_localityLabel.textColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.75];
		[self addSubview:_localityLabel];
		
		_statusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"statusUpdate_sent"]];
		//[self addSubview:_statusImageView];
		
		UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
		overlayButton.frame = CGRectFromSize(self.frame.size);
		[self addSubview:overlayButton];
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
	
	_avatarImageView.image = (_commentVO.userID == [[HONUserAssistant sharedInstance] activeUserID]) ? [UIImage imageNamed:@"greenAvatar"] : [UIImage imageNamed:@"greyAvatar"];
	
	_captionLabel.text = _commentVO.textContent;
	_captionLabel.numberOfLines = [_captionLabel numberOfLinesNeeded];
	NSLog(@"SIZE:[%@] -=- %d", NSStringFromCGSize([_captionLabel sizeForText]), [_captionLabel numberOfLinesNeeded]);
	[_captionLabel resizeFrameForMultiline];
	
	_bgImageView.frame = CGRectResizeWidth(_bgImageView.frame, _captionLabel.frame.size.width + 36.0);
	_bgImageView.frame = CGRectResizeHeight(_bgImageView.frame, (_captionLabel.frame.size.height > _bgImageView.frame.size.height) ? _captionLabel.frame.size.height + 18.0 : _bgImageView.frame.size.height);
	
	_timeLabel.text = [[HONDateTimeAlloter sharedInstance] intervalSinceDate:_commentVO.addedDate];
	_timeLabel.frame = CGRectTranslate(_timeLabel.frame, CGPointMake(_bgImageView.frameEdges.right + 10.0, 0.0 + (_bgImageView.frameEdges.top + (_bgImageView.frame.size.height - _timeLabel.frame.size.height) * 0.5)));
	
	_localityLabel.text = @"Mountain View";
	
	_avatarImageView.frame = CGRectTranslateY(_avatarImageView.frame, _bgImageView.frameEdges.bottom - _avatarImageView.frame.size.height);
	_localityLabel.frame = CGRectTranslateY(_localityLabel.frame, _bgImageView.frameEdges.bottom + 6.0);
	
	_bgImageView.hidden = (_commentVO.commentContentType == HONCommentContentTypeImage);
	_captionImageView.hidden = (_commentVO.commentContentType != HONCommentContentTypeImage);
	_statusImageView.hidden = (_commentVO.userID != [[HONUserAssistant sharedInstance] activeUserID]);
	
	if (_commentVO.userID == [[HONUserAssistant sharedInstance] activeUserID]) {
		_bgImageView.image = [[UIImage imageNamed:@"greenChatBubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(19.0, 19.0, 19.0, 24.0) resizingMode:UIImageResizingModeStretch];
		_captionLabel.textAlignment = NSTextAlignmentRight;
		_timeLabel.textAlignment = NSTextAlignmentRight;
		_localityLabel.textAlignment = NSTextAlignmentRight;
		
		_loadingImageView.frame = CGRectTranslateX(_loadingImageView.frame, self.frame.size.width - 30.0);
		_avatarImageView.frame = CGRectTranslateX(_avatarImageView.frame, self.frame.size.width - 50.0);
		_avatarImageView.frame = CGRectTranslateY(_avatarImageView.frame, _bgImageView.frameEdges.top);
		
		_captionLabel.frame = CGRectTranslateX(_captionLabel.frame, (self.frame.size.width - 86.0) - _captionLabel.frame.size.width);
		_bgImageView.frame = CGRectTranslateX(_bgImageView.frame, (self.frame.size.width - 60.0) - _bgImageView.frame.size.width);
		_timeLabel.frame = CGRectTranslateX(_timeLabel.frame, (self.frame.size.width - 60.0) - (_bgImageView.frame.size.width + 10.0) - _timeLabel.frame.size.width);
		_localityLabel.frame = CGRectTranslateX(_localityLabel.frame, (self.frame.size.width - 86.0) - _localityLabel.frame.size.width);
	}
	
	
	NSLog(@"FRAMES:[%@][%@][%@]", NSStringFromCGRect(_bgImageView.frame), NSStringFromCGRect(_captionLabel.frame), NSStringFromCGRect(_timeLabel.frame));
	
	
	if (_commentVO.commentContentType == HONCommentContentTypeText) {
		//NSLog(@"SIZE:[%@] -=- %d", NSStringFromCGSize([_captionLabel sizeForText]), [_captionLabel numberOfLinesNeeded]);
//		[_captionLabel resizeFrameForMultiline];
//		_captionLabel.frame = CGRectTranslateX(_captionLabel.frame, (_commentVO.userID == [[HONUserAssistant sharedInstance] activeUserID]) ? 260.0 - _captionLabel.frame.size.width : _captionLabel.frame.origin.x);
//		_bgImageView.frame = CGRectMake((_commentVO.userID == [[HONUserAssistant sharedInstance] activeUserID]) ? 265.0 - (_captionLabel.frame.size.width + 24.0) : _bgImageView.frame.origin.x, _bgImageView.frame.origin.y, _captionLabel.frame.size.width + 24.0, _captionLabel.frame.size.height + 16.0);
//		_timeLabel.frame = CGRectOffset(_timeLabel.frame, 320.0 - (_bgImageView.frame.size.width + 80.0), 17.0 + ((_bgImageView.frame.size.height - _timeLabel.frame.size.height) * 0.5));
		
		//NSLog(@"FRAMES:[%@][%@]", NSStringFromCGRect(_captionLabel.frame), NSStringFromCGRect(_bgImageView.frame));

	} else if (_commentVO.commentContentType == HONCommentContentTypeImage) {
		_captionImageView.image = _commentVO.imageContent;
		_captionImageView.frame = CGRectResize(_captionImageView.frame, CGSizeMult(_captionImageView.image.size, 0.5));
		_captionImageView.frame = CGRectTranslateX(_captionImageView.frame, (_commentVO.userID == [[HONUserAssistant sharedInstance] activeUserID]) ? 250.0 - _captionImageView.frame.size.width : _captionImageView.frame.origin.x);
		_bgImageView.frame = CGRectMake((_commentVO.userID == [[HONUserAssistant sharedInstance] activeUserID]) ? 275.0 - (_captionImageView.frame.size.width + 50.0) : _bgImageView.frame.origin.x, _bgImageView.frame.origin.y, _captionImageView.frame.size.width + 24.0, _captionImageView.frame.size.height + 16.0);
		//NSLog(@"FRAMES:[%@][%@]", NSStringFromCGRect(_captionImageView.frame), NSStringFromCGRect(_bgImageView.frame));
	}
	
//	_statusImageView.frame = CGRectOffset(_statusImageView.frame, 320.0 - (_bgImageView.frame.size.width + 80.0), 17.0 + ((_bgImageView.frame.size.height - _statusImageView.frame.size.height) * 0.5));
	
	if (_commentVO.commentStatusType == HONCommentStatusTypeSent) {
		_statusImageView.image = [UIImage imageNamed:@"statusUpdate_sent"];
		
	} else if (_commentVO.commentStatusType == HONCommentStatusTypeDelivered) {
		_statusImageView.image = [UIImage imageNamed:@"statusUpdate_delivered"];
		
	} else if (_commentVO.commentStatusType == HONCommentStatusTypeSeen) {
		_statusImageView.image = [UIImage imageNamed:@"statusUpdate_seen"];
	
	} else
		_statusImageView.image = [UIImage imageNamed:@"statusUpdate_unknown"];
	
	self.frame = CGRectResizeHeight(self.frame, _localityLabel.frameEdges.bottom);
}


- (void)updateStatus:(HONCommentStatusType)statusType {
	if (statusType == HONCommentStatusTypeSent) {
		_statusImageView.image = [UIImage imageNamed:@"statusUpdate_sent"];
	
	} else if (statusType == HONCommentStatusTypeDelivered) {
		_statusImageView.image = [UIImage imageNamed:@"statusUpdate_delivered"];
		
	} else if (statusType == HONCommentStatusTypeSeen) {
		_statusImageView.image = [UIImage imageNamed:@"statusUpdate_seen"];
	}
}

@end
