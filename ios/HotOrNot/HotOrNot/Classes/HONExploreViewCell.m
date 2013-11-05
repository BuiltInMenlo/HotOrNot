//
//  HONExploreViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.07.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONExploreViewCell.h"
#import "HONImageLoadingView.h"

@interface HONExploreViewCell()
@property (nonatomic, strong) HONOpponentVO *leftHeroOpponentVO;
@property (nonatomic, strong) HONOpponentVO *rightHeroOpponentVO;
@property (nonatomic, strong) UIView *leftHolderView;
@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIView *leftOverlayView;
@property (nonatomic, strong) UIView *rightHolderView;
@property (nonatomic, strong) UIImageView *rightImageView;
@property (nonatomic, strong) UIView *rightOverlayView;
@end


@implementation HONExploreViewCell
@synthesize delegate = _delegate;
@synthesize lChallengeVO = _lChallengeVO;
@synthesize rChallengeVO = _rChallengeVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		self.backgroundColor = [UIColor whiteColor];
	}
	
	return (self);
}

- (void)setLChallengeVO:(HONChallengeVO *)lChallengeVO {
	_lChallengeVO = lChallengeVO;
	
	_leftHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 160.0)];
	_leftHolderView.clipsToBounds = YES;
	[self.contentView addSubview:_leftHolderView];
	
	if (_lChallengeVO.challengeID == 0) {
		_leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchIcon"]];
		_leftImageView.alpha = 0.0;
		[_leftHolderView addSubview:_leftImageView];
		
		UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		selectButton.frame = _leftHolderView.frame;
		[selectButton setBackgroundImage:[UIImage imageNamed:@"discoveryOverlay"] forState:UIControlStateHighlighted];
		[selectButton addTarget:self action:@selector(_goSearch) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:selectButton];
		
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_leftImageView.alpha = 1.0;
		} completion:nil];
	
	} else {
		_leftHeroOpponentVO = _lChallengeVO.creatorVO;
		if ([_lChallengeVO.challengers count] > 0 && ([((HONOpponentVO *)[_lChallengeVO.challengers objectAtIndex:0]).joinedDate timeIntervalSinceNow] > [_leftHeroOpponentVO.joinedDate timeIntervalSinceNow]) && !_lChallengeVO.isCelebCreated && !_lChallengeVO.isExploreChallenge)
			_leftHeroOpponentVO = (HONOpponentVO *)[_lChallengeVO.challengers objectAtIndex:0];
		
		void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			_leftImageView.image = image;
			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
				_leftImageView.alpha = 1.0;
			} completion:nil];
		};
		
		void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"RECREATE_IMAGE_SIZES" object:_leftHeroOpponentVO.imagePrefix];
		};
		
		_leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 160.0)];
		_leftImageView.alpha = 0.0;
		[_leftHolderView addSubview:_leftImageView];
		[_leftImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_leftHeroOpponentVO.imagePrefix stringByAppendingString:kSnapMediumSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
							  placeholderImage:nil
									   success:successBlock
									   failure:failureBlock];
	
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 133.0, 140.0, 22.0)];
		subjectLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:16];
		subjectLabel.textColor = [UIColor whiteColor];
		subjectLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
		subjectLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.text = _lChallengeVO.subjectName;
		[self.contentView addSubview:subjectLabel];
			
		UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		selectButton.frame = _leftHolderView.frame;
		[selectButton setBackgroundImage:[UIImage imageNamed:@"discoveryOverlay"] forState:UIControlStateHighlighted];
		[selectButton addTarget:self action:@selector(_goSelectLeft) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:selectButton];
		
		UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLeftLongPress:)];
		lpGestureRecognizer.minimumPressDuration = 0.25;
		[selectButton addGestureRecognizer:lpGestureRecognizer];
	}
}

- (void)setRChallengeVO:(HONChallengeVO *)rChallengeVO {
	_rChallengeVO = rChallengeVO;
	
	_rightHolderView = [[UIView alloc] initWithFrame:CGRectMake(160.0, 0.0, 160.0, 160.0)];
	_rightHolderView.clipsToBounds = YES;
	[self.contentView addSubview:_rightHolderView];
	
	if (_rChallengeVO.challengeID == 0) {
		_rightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchIcon"]];
		_rightImageView.alpha = 0.0;
		[_rightHolderView addSubview:_rightImageView];
		
		UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		selectButton.frame = _rightHolderView.frame;
		[selectButton setBackgroundImage:[UIImage imageNamed:@"discoveryOverlay"] forState:UIControlStateHighlighted];
		[selectButton addTarget:self action:@selector(_goSearch) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:selectButton];
		
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_rightImageView.alpha = 1.0;
		} completion:nil];
		
	} else {
		_rightHeroOpponentVO = _rChallengeVO.creatorVO;
		if ([_rChallengeVO.challengers count] > 0 && ([((HONOpponentVO *)[_rChallengeVO.challengers objectAtIndex:0]).joinedDate timeIntervalSinceNow] > [_rightHeroOpponentVO.joinedDate timeIntervalSinceNow]) && !_rChallengeVO.isCelebCreated && !_rChallengeVO.isExploreChallenge)
			_rightHeroOpponentVO = (HONOpponentVO *)[_rChallengeVO.challengers objectAtIndex:0];
		
		void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			_rightImageView.image = image;
			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
				_rightImageView.alpha = 1.0;
			} completion:nil];
		};
		
		void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"RECREATE_IMAGE_SIZES" object:_rightHeroOpponentVO.imagePrefix];
		};
		
		_rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 160.0)];
		_rightImageView.alpha = 0.0;
		[_rightHolderView addSubview:_rightImageView];
		[_rightImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_rightHeroOpponentVO.imagePrefix stringByAppendingString:kSnapMediumSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
							   placeholderImage:nil
										success:successBlock
										failure:failureBlock];
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(170.0, 133.0, 140.0, 22.0)];
		subjectLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:16];
		subjectLabel.textColor = [UIColor whiteColor];
		subjectLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
		subjectLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.text = _rChallengeVO.subjectName;
		[self.contentView addSubview:subjectLabel];
			
		UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		selectButton.frame = _rightHolderView.frame;
		[selectButton setBackgroundImage:[UIImage imageNamed:@"discoveryOverlay"] forState:UIControlStateHighlighted];
		[selectButton addTarget:self action:@selector(_goSelectRight) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:selectButton];
		
		UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goRightLongPress:)];
		lpGestureRecognizer.minimumPressDuration = 0.25;
		[selectButton addGestureRecognizer:lpGestureRecognizer];
	}
}


#pragma mark - Navigation
- (void)_goLeftLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		[self.delegate exploreViewCellShowPreview:self forChallenge:_lChallengeVO];
	
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
	}
}

- (void)_goRightLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		[self.delegate exploreViewCellShowPreview:self forChallenge:_rChallengeVO];
	
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
	}
}

- (void)_goSelectLeft {
	UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 160.0)];
	overlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.85];
	[self.contentView addSubview:overlayView];
	
	[UIView animateWithDuration:0.25 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		overlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[overlayView removeFromSuperview];
	}];
	
	[self.delegate exploreViewCell:self selectLeftChallenge:_lChallengeVO];
}

- (void)_goSelectRight {
	UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(160.0, 0.0, 160.0, 160.0)];
	overlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.85];
	[self.contentView addSubview:overlayView];
	
	[UIView animateWithDuration:0.25 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		overlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[overlayView removeFromSuperview];
	}];
	
	[self.delegate exploreViewCell:self selectRightChallenge:_rChallengeVO];
}

- (void)_goSearch {
	[self.delegate exploreViewCellShowSearch:self];
}


@end
