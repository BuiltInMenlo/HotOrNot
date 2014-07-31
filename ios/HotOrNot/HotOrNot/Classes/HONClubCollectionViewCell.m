//
//  HONClubCollectionViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/09/2014 @ 20:10 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+AFNetworking.h"

#import "HONClubCollectionViewCell.h"


@interface HONClubCollectionViewCell ()
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation HONClubCollectionViewCell
@synthesize clubVO = _clubVO;
@synthesize delegate = _delegate;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor whiteColor];
	}
	
	return (self);
}

- (void)setClubVO:(HONUserClubVO *)clubVO {
	_clubVO = clubVO;
	
	_coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 18.0, 100.0, 100.0)];
	_coverImageView.image = [UIImage imageNamed:@"createClubButton_nonActive"];
	_coverImageView.alpha = 0.0;
	[self.contentView addSubview:_coverImageView];
	
	[[HONImageBroker sharedInstance] maskImageView:_coverImageView withMask:[UIImage imageNamed:@"clubCoverMask"]];
	
	_iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9.0, 55.0, 80, 30.0)];
	[self.contentView addSubview:_iconImageView];
	
	_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 128.0, 120.0, 20.0)];
	_nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:15];
	_nameLabel.textColor = [UIColor blackColor];
	_nameLabel.textAlignment = NSTextAlignmentCenter;
	_nameLabel.text = _clubVO.clubName;
	[self.contentView addSubview:_nameLabel];

	
	if (_clubVO.clubID != 0) {
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			_coverImageView.image = image;
			[UIView animateWithDuration:0.0 animations:^(void) {
				_coverImageView.alpha = 1.0;
			} completion:^(BOOL finished) {
			}];
		};
		
		void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[HONAppDelegate cleanImagePrefixURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeClubs completion:nil];
			
			_clubVO.coverImagePrefix = [[HONClubAssistant sharedInstance] defaultCoverImageURL];
			[_coverImageView setImageWithURL:[NSURL URLWithString:[_clubVO.coverImagePrefix stringByAppendingString:kSnapMediumSuffix]]
							placeholderImage:[UIImage imageNamed:@"defaultClubPhoto"]];
			
			[UIView animateWithDuration:0.0 delay:0.0 options:(UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAllowUserInteraction) animations:^(void) {
				_coverImageView.alpha = 1.0;
			} completion:^(BOOL finished) {
			}];
		};
		
		if ([_clubVO.coverImagePrefix length] == 0)
			_coverImageView.image = [UIImage imageNamed:@"defaultClubCover"];
		
		else {
			[_coverImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_clubVO.coverImagePrefix stringByAppendingString:kSnapMediumSuffix]]
																	 cachePolicy:kURLRequestCachePolicy
																 timeoutInterval:[HONAppDelegate timeoutInterval]]
								   placeholderImage:nil
											success:imageSuccessBlock
											failure:imageFailureBlock];
		}
		
	} else {
		[UIView animateWithDuration:0.0 animations:^(void) {
			_coverImageView.alpha = 1.0;
		} completion:^(BOOL finished) {
		}];
	}
	
	
	if (_clubVO.clubEnrollmentType == HONClubEnrollmentTypePending) {
		_iconImageView.image = [UIImage imageNamed:@"newInviteOverlay"];
	
	} else if (_clubVO.clubEnrollmentType == HONClubEnrollmentTypeSuggested) {
		_iconImageView.image = [UIImage imageNamed:@"suggestionOverlay"];
	}
}

- (void)resetSubviews {
	for (UIView *view in self.contentView.subviews)
		[view removeFromSuperview];
	
	if (_coverImageView != nil)
		_coverImageView = nil;
	
	if (_nameLabel != nil)
		_nameLabel = nil;
	
	if (_iconImageView != nil)
		_iconImageView = nil;
}
-(void) tintCell:(BOOL)reset {
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.contentView.alpha = .40;
    } completion:^(BOOL finished) {
        if(reset){
            [self removeTint];
        }
    }];
}
-(void) removeTint{
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.contentView.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
}
#pragma mark - Navigation


@end
