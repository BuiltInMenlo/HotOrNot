//
//  HONStoreProductViewCell.m
//  HotOrNot
//
//  Created by BIM  on 10/7/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

#import "HONStoreProductViewCell.h"

@interface HONStoreProductViewCell()
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UIImageView *productImageView;
@property (nonatomic, strong) FLAnimatedImageView *animatedImageView;
@end

@implementation HONStoreProductViewCell
@synthesize isPurchased = _isPurchased;
@synthesize storeProductVO = _storeProductVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		
	}
	
	return (self);
}

- (void)setStoreProductVO:(HONStoreProductVO *)storeProductVO {
//	NSLog(@"setStoreProductVO:[%@]", storeProductVO.dictionary);
	
	_storeProductVO = storeProductVO;
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0, 16.0, 50.0, 50.0)];
	bgImageView.image = [UIImage imageNamed:@"stickerItemBG"];
	[self.contentView addSubview:bgImageView];
	
	_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(81.0, 15.0, 260.0, 21.0)];
	_captionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17];
	_captionLabel.textColor =  [UIColor blackColor];
	_captionLabel.backgroundColor = [UIColor clearColor];
	_captionLabel.text = [NSString stringWithFormat:@"%d. %@", _storeProductVO.displayIndex, _storeProductVO.productName];
	[self.contentView addSubview:_captionLabel];
	
	_priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(81.0, 38.0, 260.0, 18.0)];
	_priceLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
	_priceLabel.textColor =  [[HONColorAuthority sharedInstance] honLightGreyTextColor];
	_priceLabel.backgroundColor = [UIColor clearColor];
	_priceLabel.text = (_storeProductVO.isPurchased) ? @"PURCHASED" : [NSString stringWithFormat:@"$%.02f", _storeProductVO.price];
	[self.contentView addSubview:_priceLabel];
	
	if (_storeProductVO.imageType == HONStoreProuctImageTypeGIF) {
		if (!_animatedImageView) {
			_animatedImageView = [[FLAnimatedImageView alloc] init];
			_animatedImageView.contentMode = UIViewContentModeScaleAspectFill;
			_animatedImageView.clipsToBounds = YES;
		}
		
		_animatedImageView.frame = bgImageView.frame;
		[self.contentView addSubview:_animatedImageView];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSURL *url = [NSURL URLWithString:_storeProductVO.imageURL];
			FLAnimatedImage *animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				_animatedImageView.animatedImage = animatedImage;
			});
		});
		
	} else if (_storeProductVO.imageType == HONStoreProuctImageTypePNG) {
		_productImageView = [[UIImageView alloc] initWithFrame:bgImageView.frame];
		[self.contentView addSubview:_productImageView];
		
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			_productImageView.image = image;
		};
		
		void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		};
		
		[_productImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_storeProductVO.imageURL]
																   cachePolicy:kOrthodoxURLCachePolicy
															   timeoutInterval:[HONAPICaller timeoutInterval]]
							  placeholderImage:nil
									   success:imageSuccessBlock
									   failure:imageFailureBlock];
	}
}

@end
