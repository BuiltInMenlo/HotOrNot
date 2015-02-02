//
//  HONComposeViewCell.m
//  HotOrNot
//
//  Created by BIM  on 12/12/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONTopicViewCell.h"

@interface HONTopicViewCell ()
@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UIButton *selectButton;
@end

@implementation HONTopicViewCell
@synthesize delegate = _delegate;
@synthesize topicVO = _topicVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		_loadingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imageLoadingDots_compose"]];
		_loadingImageView.frame = CGRectOffset(_loadingImageView.frame, 12.0, 12.0);
		[self.contentView addSubview:_loadingImageView];
		
		_iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 12.0, 35.0, 35.0)];
		[self.contentView addSubview:_iconImageView];
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 14.0, 200.0, 26.0)];
		_captionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
		_captionLabel.textColor =  [UIColor blackColor];
		_captionLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_captionLabel];
		
		_selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_selectButton.frame = CGRectFromSize(self.frame.size);
//		[self.contentView addSubview:_selectButton];
	}
	
	return (self);
}

- (void)dealloc {
}

- (void)destroy {
	[super destroy];
}


#pragma mark - Public APIs
- (void)setTopicVO:(HONTopicVO *)topicVO {
	_topicVO = topicVO;
	
	_captionLabel.text = _topicVO.topicName;
	
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
}

- (void)toggleCaption:(BOOL)isVisible {
	_captionLabel.hidden = !isVisible;
}

- (void)toggleImageLoading:(BOOL)isLoading {
//	if (isLoading) {
//		void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
//			NSLog(@"!!!!!! FAILED:[%@]", request.URL.absoluteURL);
//		};
//		
//		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//			_iconImageView.image = image;
//		};
//		
//		[_iconImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_topicVO.iconURL]
//																cachePolicy:kOrthodoxURLCachePolicy
//															timeoutInterval:[HONAPICaller timeoutInterval]]
//							  placeholderImage:nil
//									   success:imageSuccessBlock
//									   failure:imageFailureBlock];
//	} else {
//		[_iconImageView cancelImageRequestOperation];
//	}
}


#pragma mark - Navigation
- (void)_goSelect {
	if ([self.delegate respondsToSelector:@selector(topicViewCell:didSelectTopic:)])
		[self.delegate topicViewCell:self didSelectTopic:_topicVO];
}

@end
