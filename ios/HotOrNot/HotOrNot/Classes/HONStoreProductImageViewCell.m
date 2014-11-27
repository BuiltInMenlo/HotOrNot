//
//  HONStoreProductImageViewCell.m
//  HotOrNot
//
//  Created by BIM  on 11/3/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"
#import "UIImageView+AFNetworking.h"

#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

#import "HONStoreProductImageViewCell.h"

@interface HONStoreProductImageViewCell()
@property (nonatomic, strong) UIImageView *productImageView;
@property (nonatomic, strong) FLAnimatedImageView *animatedImageView;
@end

@implementation HONStoreProductImageViewCell
@synthesize imageDict = _imageDict;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setImageDict:(NSDictionary *)imageDict {
//	NSLog(@"setImageDict:[%@]", imageDict);
	_imageDict = imageDict;
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectFromSize(self.frame.size)];
	bgImageView.image = [UIImage imageNamed:@"stickerItemBG"];
	[self.contentView addSubview:bgImageView];
	
	if ([[_imageDict objectForKey:@"type"] isEqualToString:@"gif"]) {
		
		if (_animatedImageView == nil) {
			_animatedImageView = [[FLAnimatedImageView alloc] init];
			_animatedImageView.frame = bgImageView.frame;
			_animatedImageView.contentMode = UIViewContentModeScaleToFill; // stretches w/o ratio -- UIViewContentModeScaleAspectFit; // centers in frame
			_animatedImageView.clipsToBounds = YES;
			[self.contentView addSubview:_animatedImageView];
		}
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSURL *url = [NSURL URLWithString:[_imageDict objectForKey:@"url"]];
			FLAnimatedImage *animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				_animatedImageView.animatedImage = animatedImage;
			});
		});
		
	} else if ([[_imageDict objectForKey:@"type"] isEqualToString:@"png"]) {
		_productImageView = [[UIImageView alloc] initWithFrame:bgImageView.frame];
		[self.contentView addSubview:_productImageView];
		
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			_productImageView.image = image;
		};
		
		void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		};
		
		[_productImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_imageDict objectForKey:@"url"]]
																   cachePolicy:NSURLRequestReturnCacheDataElseLoad
															   timeoutInterval:[HONAppDelegate timeoutInterval]]
							  placeholderImage:nil
									   success:imageSuccessBlock
									   failure:imageFailureBlock];
	}
}


@end
