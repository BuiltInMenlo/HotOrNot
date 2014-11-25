//
//  HONHomeViewCell.m
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"
#import "UIImageView+AFNetworking.h"

#import "HONHomeViewCell.h"

@interface HONHomeViewCell()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic) BOOL isLoading;
@end

@implementation HONHomeViewCell
@synthesize delegate = _delegate;
@synthesize clubPhotoVO = _clubPhotoVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_isLoading = NO;
		
		UIImageView *loadingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loadingArrows"]];
		[self.contentView addSubview:loadingImageView];
		
		_imageView = [[UIImageView alloc] initWithFrame:CGRectFromSize(self.frame.size)];
		[self.contentView addSubview:_imageView];
		
		_selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_selectButton.frame = self.frame;
		[self.contentView addSubview:_selectButton];
		
		_scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 55.0, self.frame.size.height - 17.0, 50.0, 16.0)];
		_scoreLabel.backgroundColor = [UIColor clearColor];
		_scoreLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
		_scoreLabel.textAlignment = NSTextAlignmentRight;
		_scoreLabel.textColor = [UIColor whiteColor];
		_scoreLabel.text = @"…";
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
- (void)setClubPhotoVO:(HONClubPhotoVO *)clubPhotoVO {
	_clubPhotoVO = clubPhotoVO;
	
	_imageView.hidden = YES;
	_scoreLabel.text = @"…";
	
	[self toggleImageLoading:YES];
	[self refeshScore];
}

- (void)refeshScore {
	[[HONAPICaller sharedInstance] retrieveVoteTotalForChallengeWithChallengeID:_clubPhotoVO.challengeID completion:^(NSNumber *result) {
		_clubPhotoVO.score = [result intValue];
		_scoreLabel.text = [@"" stringFromNSNumber:result includeDecimal:NO];
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
				_imageView.image = [UIImage imageNamed:@"placeholderClubPhoto_320x320"];
				_isLoading = NO;
				
				[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONAPICaller sharedInstance] normalizePrefixForImageURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeClubs completion:nil];
			};
			
//			NSLog(@"URL:[%@]", [_clubPhotoVO.imagePrefix stringByAppendingString:kSnapMediumSuffix]);
			[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_clubPhotoVO.imagePrefix stringByAppendingString:kSnapMediumSuffix]]
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
	if ([self.delegate respondsToSelector:@selector(homeViewCell:didSelectClubPhoto:)])
		[self.delegate homeViewCell:self didSelectClubPhoto:_clubPhotoVO];
}

@end
