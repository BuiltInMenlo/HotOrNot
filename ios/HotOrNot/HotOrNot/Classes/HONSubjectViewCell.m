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
@end

@implementation HONSubjectViewCell
@synthesize delegate = _delegate;
@synthesize subjectVO = _subjectVO;

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


#pragma mark - PublicAPIs
- (void)setSubjectVO:(HONSubjectVO *)subjectVO {
	_subjectVO = subjectVO;
	
	_captionLabel.text = _subjectVO.subjectName;
}

- (void)toggleImageLoading:(BOOL)isLoading {
	if (isLoading) {
		void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			NSLog(@"!!!!!! FAILED:[%@]", request.URL.absoluteURL);
		};
		
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			_iconImageView.image = image;
		};
		
		[_iconImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_subjectVO.icoURL]
																cachePolicy:kOrthodoxURLCachePolicy
															timeoutInterval:[HONAppDelegate timeoutInterval]]
							  placeholderImage:nil
									   success:imageSuccessBlock
									   failure:imageFailureBlock];
		
	} else {
		[_iconImageView cancelImageRequestOperation];
	}
}

#pragma mark - Navigation
- (void)_goSelect {
	if ([self.delegate respondsToSelector:@selector(subjectViewCell:didSelectSubject:)])
		[self.delegate subjectViewCell:self didSelectSubject:_subjectVO];
}


@end
