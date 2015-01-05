//
//  HONHomeViewCell.m
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONHomeViewCell.h"
#import "HONRefreshingLabel.h"

@interface HONHomeViewCell()
@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) HONRefreshingLabel *scoreLabel;
@property (nonatomic) BOOL isLoading;
@end

@implementation HONHomeViewCell
@synthesize delegate = _delegate;
@synthesize statusUpdateVO = _statusUpdateVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_isLoading = NO;
		
		[self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
		
		_loadingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imageLoadingDots_home"]];
		[self.contentView addSubview:_loadingImageView];
		
		_imageView = [[UIImageView alloc] initWithFrame:CGRectFromSize(self.frame.size)];
		[self.contentView addSubview:_imageView];
		
		_selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_selectButton.frame = self.frame;
		[self.contentView addSubview:_selectButton];
		
		_scoreLabel = [[HONRefreshingLabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 55.0, self.frame.size.height - 19.0, 50.0, 20.0)];
		_scoreLabel.backgroundColor = [UIColor clearColor];
		_scoreLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
		_scoreLabel.textAlignment = NSTextAlignmentRight;
		_scoreLabel.textColor = [UIColor whiteColor];
		[_scoreLabel setText:NSStringFromInt(_statusUpdateVO.score)];
		[self.contentView addSubview:_scoreLabel];
	}
	
	return (self);
}

- (void)dealloc {
	if (_isLoading) {
		[_imageView cancelImageRequestOperation];
	}
	
	_isLoading = NO;
}

- (void)destroy {
	if (_isLoading) {
		[_imageView cancelImageRequestOperation];
	}
	
	_isLoading = NO;
}


#pragma mark - Public APIs
- (void)setStatusUpdateVO:(HONStatusUpdateVO *)statusUpdateVO {
	_statusUpdateVO = statusUpdateVO;
	
//	_imageView.hidden = YES;
//	[_scoreLabel toggleLoading:YES];
//	[self refeshScore];
	
	[_scoreLabel setText:NSStringFromInt(_statusUpdateVO.score)];
	
	_isLoading = YES;
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_imageView.image = image;
		_isLoading = NO;
		
		[_loadingImageView removeFromSuperview];
		_loadingImageView = nil;
		
		[_selectButton addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		NSLog(@"ERROR:[%@]", error.description);
		_imageView.image = [UIImage imageNamed:@"placeholderClubPhoto_320x320"];
		_isLoading = NO;
		
		[_loadingImageView removeFromSuperview];
		_loadingImageView = nil;
		
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONAPICaller sharedInstance] normalizePrefixForImageURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeClubs completion:nil];
	};
	
//	NSLog(@"URL:[%@]", [[_statusUpdateVO.composeImageVO.urlPrefix stringByAppendingString:kComposeImageURLSuffix214] stringByAppendingString:kComposeImageStaticFileExtension]);
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_statusUpdateVO.composeImageVO.iconURL]
														cachePolicy:kOrthodoxURLCachePolicy
													timeoutInterval:[HONAppDelegate timeoutInterval]]
					  placeholderImage:[UIImage imageNamed:@"imageLoadingDots_home"]
							   success:imageSuccessBlock
							   failure:imageFailureBlock];
	
	
}

- (void)refeshScore {
	[[HONAPICaller sharedInstance] retrieveVoteTotalForChallengeWithChallengeID:_statusUpdateVO.statusUpdateID completion:^(NSNumber *result) {
		_statusUpdateVO.score = [result intValue];
		[_scoreLabel setText:NSStringFromInt(_statusUpdateVO.score)];
		[_scoreLabel toggleLoading:NO];
		
		NSLog(@"CELL:{%@} -=- [%d / %d] SCORE:(%d)", NSStringFromNSIndexPath(self.indexPath), _statusUpdateVO.statusUpdateID, _statusUpdateVO.clubID, _statusUpdateVO.score);
	}];
}

- (void)toggleImageLoading:(BOOL)isLoading {
	if (isLoading) {
		if (!_isLoading) {
			_isLoading = YES;
			_imageView.hidden = NO;
			
			void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
				_imageView.image = image;
				_isLoading = NO;
				
				[_selectButton addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
			};
			
			void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
				NSLog(@"ERROR:[%@]", error.description);
				_imageView.image = [UIImage imageNamed:@"placeholderClubPhoto_320x320"];
				_isLoading = NO;
				
				[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONAPICaller sharedInstance] normalizePrefixForImageURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeClubs completion:nil];
			};
			
//			NSLog(@"URL:[%@]", [_clubPhotoVO.imagePrefix stringByAppendingString:kSnapMediumSuffix]);
			[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_statusUpdateVO.imagePrefix stringByAppendingString:kSnapMediumSuffix]]
																cachePolicy:kOrthodoxURLCachePolicy
															timeoutInterval:[HONAppDelegate timeoutInterval]]
							  placeholderImage:[UIImage imageNamed:@"loadingArrows"]
									   success:imageSuccessBlock
									   failure:imageFailureBlock];
		}
		
	} else {
		_isLoading = NO;
		[_imageView cancelImageRequestOperation];
	}
}


#pragma mark - Navigation
- (void)_goSelect {
	if ([self.delegate respondsToSelector:@selector(homeViewCell:didSelectStatusUpdate:)])
		[self.delegate homeViewCell:self didSelectStatusUpdate:_statusUpdateVO];
}

@end
