//
//  HONSubjectViewCell.m
//  HotOrNot
//
//  Created by BIM  on 12/13/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONSubjectViewCell.h"


@interface HONSubjectViewCell ()
@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIImageView *lLoadingImageView;
@property (nonatomic, strong) UIImageView *lIconImageView;
@property (nonatomic, strong) UILabel *lCaptionLabel;
@property (nonatomic, strong) UIButton *lSelectButton;
@property (nonatomic, strong) UIImageView *rLoadingImageView;
@property (nonatomic, strong) UIImageView *rIconImageView;
@property (nonatomic, strong) UILabel *rCaptionLabel;
@property (nonatomic, strong) UIButton *rSelectButton;
@end

@implementation HONSubjectViewCell
@synthesize delegate = _delegate;
@synthesize topicVO = _topicVO;
@synthesize lTopicVO = _lTopicVO;
@synthesize rTopicVO = _rTopicVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		[self hideChevron];
		
		_loadingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imageLoadingDots_compose"]];
		_loadingImageView.frame = CGRectOffset(_loadingImageView.frame, 143.0, 0.0);
		//[self.contentView addSubview:_loadingImageView];
		
		_iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 9.0, 35.0, 35.0)];
		[self.contentView addSubview:_iconImageView];
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(57.0, 14.0, 160.0, 24.0)];
		_captionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
		_captionLabel.textColor =  [UIColor blackColor];
		_captionLabel.backgroundColor = [UIColor clearColor];
//		_captionLabel.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:_captionLabel];
		
		_selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_selectButton.frame = _iconImageView.frame;
		[_selectButton addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
//		[self.contentView addSubview:_selectButton];
		
		/*
		_lLoadingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imageLoadingDots_compose"]];
		_lLoadingImageView.frame = CGRectOffset(_lLoadingImageView.frame, 44.0, 0.0);
		[self.contentView addSubview:_lLoadingImageView];
		
		_lIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(44.0, 0.0, 78.0, 78.0)];
		[self.contentView addSubview:_lIconImageView];
		
		_lCaptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 88.0, 150.0, 14.0)];
		_lCaptionLabel.font = [[[HONFontAllocator sharedInstance] cartoGothicBold] fontWithSize:12];
		_lCaptionLabel.textColor =  [UIColor whiteColor];
		_lCaptionLabel.backgroundColor = [UIColor clearColor];
		_lCaptionLabel.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:_lCaptionLabel];
		
		_lSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_lSelectButton.frame = _lIconImageView.frame;
		[_lSelectButton addTarget:self action:@selector(_goSelectLeft) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_lSelectButton];
		
		_rLoadingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imageLoadingDots_compose"]];
		_rLoadingImageView.frame = CGRectOffset(_rLoadingImageView.frame, 193.0, 0.0);
		[self.contentView addSubview:_rLoadingImageView];
		
		_rIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(193.0, 0.0, 78.0, 78.0)];
		[self.contentView addSubview:_rIconImageView];
		
		_rCaptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(170.0, 88.0, 150.0, 14.0)];
		_rCaptionLabel.font = [[[HONFontAllocator sharedInstance] cartoGothicBold] fontWithSize:12];
		_rCaptionLabel.textColor =  [UIColor whiteColor];
		_rCaptionLabel.backgroundColor = [UIColor clearColor];
		_rCaptionLabel.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:_rCaptionLabel];
		
		_rSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_rSelectButton.frame = _rIconImageView.frame;
		[_rSelectButton addTarget:self action:@selector(_goSelectRight) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_rSelectButton];
		*/
	}
	
	return (self);
}

- (void)dealloc {
	
}

- (void)destroy {
	[super destroy];
}


#pragma mark - PublicAPIs
- (void)setTopicVO:(HONTopicVO *)topicVO {
	_topicVO = topicVO;
	_captionLabel.text = _topicVO.topicName;
}

- (void)setLTopicVO:(HONTopicVO *)lTopicVO {
	_lTopicVO = lTopicVO;
	_lCaptionLabel.text = _lTopicVO.topicName;
}

- (void)setRTopicVO:(HONTopicVO *)rTopicVO {
	_rTopicVO = rTopicVO;
	_rCaptionLabel.text = _rTopicVO.topicName;
}

- (void)toggleImageLoading:(BOOL)isLoading {
	if (isLoading) {
		void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			NSLog(@"!!!!!! FAILED:[%@]", request.URL.absoluteURL);
		};
		
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			_iconImageView.image = image;
		};
		
		[_iconImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_topicVO.iconURL]
																cachePolicy:kOrthodoxURLCachePolicy
															timeoutInterval:[HONAPICaller timeoutInterval]]
							  placeholderImage:nil
									   success:imageSuccessBlock
									   failure:imageFailureBlock];
		
		
		
		void (^lImageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			NSLog(@"!!!!!! FAILED:[%@]", request.URL.absoluteURL);
		};
		
		void (^lImageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			_lIconImageView.image = image;
		};
		
		[_lIconImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_lTopicVO.iconURL]
																 cachePolicy:kOrthodoxURLCachePolicy
															 timeoutInterval:[HONAPICaller timeoutInterval]]
							   placeholderImage:nil
										success:lImageSuccessBlock
										failure:lImageFailureBlock];
		
		void (^rImageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			NSLog(@"!!!!!! FAILED:[%@]", request.URL.absoluteURL);
		};
		
		void (^rImageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			_rIconImageView.image = image;
		};
		
		[_rIconImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_rTopicVO.iconURL]
																 cachePolicy:kOrthodoxURLCachePolicy
															 timeoutInterval:[HONAPICaller timeoutInterval]]
							   placeholderImage:nil
										success:rImageSuccessBlock
										failure:rImageFailureBlock];
		
	} else {
		[_iconImageView cancelImageRequestOperation];
		[_lIconImageView cancelImageRequestOperation];
		[_rIconImageView cancelImageRequestOperation];
	}
}

#pragma mark - Navigation
- (void)_goSelect {
	if ([self.delegate respondsToSelector:@selector(subjectViewCell:didSelectSubject:)])
		[self.delegate subjectViewCell:self didSelectSubject:_topicVO];
}

- (void)_goSelectLeft {
	if ([self.delegate respondsToSelector:@selector(subjectViewCell:didSelectSubject:)])
		[self.delegate subjectViewCell:self didSelectSubject:_lTopicVO];
}

- (void)_goSelectRight {
	if ([self.delegate respondsToSelector:@selector(subjectViewCell:didSelectSubject:)])
		[self.delegate subjectViewCell:self didSelectSubject:_rTopicVO];
}


@end
