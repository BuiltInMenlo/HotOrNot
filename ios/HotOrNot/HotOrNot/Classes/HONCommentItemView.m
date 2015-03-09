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
@end

@implementation HONCommentItemView
@synthesize commentVO = _commentVO;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor whiteColor];
		
		_loadingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loadingDots_50"]];
		_loadingImageView.frame = CGRectOffset(_loadingImageView.frame, 15.0, 15.0);
//		[self addSubview:_loadingImageView];
		
		_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 15.0, 35.0, 35.0)];
		[self addSubview:_avatarImageView];
		
		[[HONViewDispensor sharedInstance] maskView:_avatarImageView withMask:[UIImage imageNamed:@"topicMask"]];
		
		_bgImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"greyChatBubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0, 16.0, 24.0, 4.0) resizingMode:UIImageResizingModeStretch]];
		
		_bgImageView.frame = CGRectMake(57.0, 16.0, 170.0, 34.0);
		[self addSubview:_bgImageView];
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0, 24.0, 150.0, 18.0)];
		_captionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.textColor = [UIColor blackColor];
		_captionLabel.lineBreakMode = NSLineBreakByWordWrapping;
		[self addSubview:_captionLabel];
		
		_captionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(72.0, 24.0, 35.0, 35.0)];
		[self addSubview:_captionImageView];
		
		_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0, 63.0, 160.0, 16.0)];
		_timeLabel.font = [[[HONFontAllocator sharedInstance] cartoGothicBook] fontWithSize:12];
		_timeLabel.backgroundColor = [UIColor clearColor];
		_timeLabel.textColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.75];
		[self addSubview:_timeLabel];
		
		_statusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"statusUpdate_sent"]];
		[self addSubview:_statusImageView];
		
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
	
	UILabel *initialLabel = [[UILabel alloc] initWithFrame:CGRectFromSize(_avatarImageView.frame.size)];
	initialLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
	initialLabel.backgroundColor = [UIColor clearColor];
	initialLabel.textColor = [UIColor blackColor];
	initialLabel.text = [[_commentVO.username substringToIndex:1] uppercaseString];
	initialLabel.textAlignment = NSTextAlignmentCenter;
	//[_avatarImageView addSubview:initialLabel];
	
	
	_statusImageView.hidden = (_commentVO.userID != [[HONUserAssistant sharedInstance] activeUserID]);
	if (_commentVO.userID == [[HONUserAssistant sharedInstance] activeUserID]) {
		_bgImageView.image = [[UIImage imageNamed:@"greenChatBubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0, 4.0, 24.0, 16.0) resizingMode:UIImageResizingModeStretch];
		
		_loadingImageView.frame = CGRectOffsetX(_loadingImageView.frame, 265.0);
		_avatarImageView.frame = CGRectOffsetX(_avatarImageView.frame, 265.0);
		_timeLabel.frame = CGRectOffset(_timeLabel.frame, 20.0, 0.0);
		_timeLabel.textAlignment = NSTextAlignmentRight;
	}
	
	_captionLabel.text = _commentVO.textContent;
	_captionLabel.numberOfLines = [_captionLabel numberOfLinesNeeded];
	
	_bgImageView.hidden = (_commentVO.commentContentType == HONCommentContentTypeImage);
	_captionImageView.hidden = (_commentVO.commentContentType != HONCommentContentTypeImage);
	
	if (_commentVO.commentContentType == HONCommentContentTypeText) {
		//NSLog(@"SIZE:[%@] -=- %d", NSStringFromCGSize([_captionLabel sizeForText]), [_captionLabel numberOfLinesNeeded]);
		[_captionLabel resizeFrameForMultiline];
		_captionLabel.frame = CGRectTranslateX(_captionLabel.frame, (_commentVO.userID == [[HONUserAssistant sharedInstance] activeUserID]) ? 250.0 - _captionLabel.frame.size.width : _captionLabel.frame.origin.x);
		_bgImageView.frame = CGRectMake((_commentVO.userID == [[HONUserAssistant sharedInstance] activeUserID]) ? 265.0 - (_captionLabel.frame.size.width + 24.0) : _bgImageView.frame.origin.x, _bgImageView.frame.origin.y, _captionLabel.frame.size.width + 24.0, _captionLabel.frame.size.height + 16.0);
		//NSLog(@"FRAMES:[%@][%@]", NSStringFromCGRect(_captionLabel.frame), NSStringFromCGRect(_bgImageView.frame));

	} else if (_commentVO.commentContentType == HONCommentContentTypeImage) {
		_captionImageView.image = _commentVO.imageContent;
		_captionImageView.frame = CGRectResize(_captionImageView.frame, CGSizeMult(_captionImageView.image.size, 0.5));
		_captionImageView.frame = CGRectTranslateX(_captionImageView.frame, (_commentVO.userID == [[HONUserAssistant sharedInstance] activeUserID]) ? 250.0 - _captionImageView.frame.size.width : _captionImageView.frame.origin.x);
		_bgImageView.frame = CGRectMake((_commentVO.userID == [[HONUserAssistant sharedInstance] activeUserID]) ? 265.0 - (_captionImageView.frame.size.width + 24.0) : _bgImageView.frame.origin.x, _bgImageView.frame.origin.y, _captionImageView.frame.size.width + 24.0, _captionImageView.frame.size.height + 16.0);
		//NSLog(@"FRAMES:[%@][%@]", NSStringFromCGRect(_captionImageView.frame), NSStringFromCGRect(_bgImageView.frame));
	}
	
	_statusImageView.frame = CGRectOffset(_statusImageView.frame, 320.0 - (_bgImageView.frame.size.width + 80.0), 17.0 + ((_bgImageView.frame.size.height - _statusImageView.frame.size.height) * 0.5));
	_timeLabel.frame = CGRectTranslateY(_timeLabel.frame, 10.0 + _bgImageView.frameEdges.bottom);
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	[dateFormatter setDateFormat:@"MM/dd/yyyy @ hh:mm a"];
	_timeLabel.text = [dateFormatter stringFromDate:_commentVO.addedDate];
	
	if (_commentVO.commentStatusType == HONCommentStatusTypeSent) {
		_statusImageView.image = [UIImage imageNamed:@"statusUpdate_sent"];
		
	} else if (_commentVO.commentStatusType == HONCommentStatusTypeDelivered) {
		_statusImageView.image = [UIImage imageNamed:@"statusUpdate_delivered"];
		
	} else if (_commentVO.commentStatusType == HONCommentStatusTypeSeen) {
		_statusImageView.image = [UIImage imageNamed:@"statusUpdate_seen"];
	
	} else
		_statusImageView.image = [UIImage imageNamed:@"statusUpdate_unknown"];
	
	self.frame = CGRectResizeHeight(self.frame, _timeLabel.frameEdges.bottom);
	_avatarImageView.frame = CGRectTranslateY(_avatarImageView.frame, _bgImageView.frameEdges.bottom - _avatarImageView.frame.size.height);
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
