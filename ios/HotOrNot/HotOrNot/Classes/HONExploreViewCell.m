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
		self.backgroundColor = [UIColor blackColor];
	}
	
	return (self);
}

- (void)setLChallengeVO:(HONChallengeVO *)lChallengeVO {
	_lChallengeVO = lChallengeVO;
	
	_leftHeroOpponentVO = _lChallengeVO.creatorVO;
//	if ([_lChallengeVO.challengers count] > 0 && ([((HONOpponentVO *)[_lChallengeVO.challengers objectAtIndex:0]).joinedDate timeIntervalSinceNow] > [_leftHeroOpponentVO.joinedDate timeIntervalSinceNow]))
//		_leftHeroOpponentVO = (HONOpponentVO *)[_lChallengeVO.challengers objectAtIndex:0];
	
	__weak typeof(self) weakSelf = self;
//	NSLog(@"L-CHALLENGE:(%d)[%@]", _lChallengeVO.challengeID, [NSString stringWithFormat:@"%@Medium_320x320.jpg",_leftHeroOpponentVO.imagePrefix]);
	
	_leftHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 160.0)];
	_leftHolderView.clipsToBounds = YES;
	[self.contentView addSubview:_leftHolderView];
	
	_leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 160.0)];
	_leftImageView.alpha = 0.0;
	[_leftHolderView addSubview:_leftImageView];
	[_leftImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@Medium_320x320.jpg",_leftHeroOpponentVO.imagePrefix]]
															   cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
							 placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
								 weakSelf.leftImageView.image = image;
								 [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.leftImageView.alpha = 1.0; } completion:nil];
							 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
								 //[weakSelf _reloadLeftImage];
							 }];
	
	UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timelineImageFade"]];
	gradientImageView.frame = CGRectOffset(gradientImageView.frame, 0.0, 6.0);
	[self.contentView addSubview:gradientImageView];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0, 130.0, 140.0, 24.0)];
	subjectLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
	subjectLabel.textColor = [UIColor colorWithWhite:0.898 alpha:1.0];
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

- (void)setRChallengeVO:(HONChallengeVO *)rChallengeVO {
	_rChallengeVO = rChallengeVO;
	
	_rightHeroOpponentVO = _rChallengeVO.creatorVO;
//	if ([_rChallengeVO.challengers count] > 0 && ([((HONOpponentVO *)[_rChallengeVO.challengers objectAtIndex:0]).joinedDate timeIntervalSinceNow] > [_rightHeroOpponentVO.joinedDate timeIntervalSinceNow]))
//		_rightHeroOpponentVO = (HONOpponentVO *)[_rChallengeVO.challengers objectAtIndex:0];
	
//	NSLog(@"R-CHALLENGE:(%d)[%@]", _rChallengeVO.challengeID, [NSString stringWithFormat:@"%@Medium_320x320.jpg",_rightHeroOpponentVO.imagePrefix]);
	
	__weak typeof(self) weakSelf = self;
	
	_rightHolderView = [[UIView alloc] initWithFrame:CGRectMake(160.0, 0.0, 160.0, 160.0)];
//	_rightHolderView.clipsToBounds = YES;
	[self.contentView addSubview:_rightHolderView];
	
	_rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 160.0)];
	_rightImageView.alpha = 0.0;
	[_rightHolderView addSubview:_rightImageView];
	[_rightImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@Medium_320x320.jpg",_rightHeroOpponentVO.imagePrefix]]
															cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
						  placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
							  weakSelf.rightImageView.image = image;
							  [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.rightImageView.alpha = 1.0; } completion:nil];
						  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
							  //[weakSelf _reloadRightImage];
						  }];
	
	UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timelineImageFade"]];
	gradientImageView.frame = CGRectOffset(gradientImageView.frame, 160.0, 6.0);
	[self.contentView addSubview:gradientImageView];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(169.0, 130.0, 140.0, 24.0)];
	subjectLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
	subjectLabel.textColor = [UIColor colorWithWhite:0.898 alpha:1.0];
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


#pragma mark - Navigation
- (void)_goLeftLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan)
		[self.delegate exploreViewCellShowPreview:self forChallenge:_lChallengeVO];
	
	else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized)
		[self.delegate exploreViewCellHidePreview:self];
}

- (void)_goRightLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan)
		[self.delegate exploreViewCellShowPreview:self forChallenge:_rChallengeVO];
	
	else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized)
		[self.delegate exploreViewCellHidePreview:self];
}

- (void)_goSelectLeft {
	UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 160.0)];
	overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.85];
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
	overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.85];
	[self.contentView addSubview:overlayView];
	
	[UIView animateWithDuration:0.25 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		overlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[overlayView removeFromSuperview];
	}];
	
	[self.delegate exploreViewCell:self selectRightChallenge:_rChallengeVO];
}


#pragma mark - UI Presentation
- (void)_reloadLeftImage {
	__weak typeof(self) weakSelf = self;
	
	_leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-25.0, 0.0, 320.0, 320.0)];
	_leftImageView.alpha = 0.0;
	[_leftHolderView addSubview:_leftImageView];
	[_leftImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", _leftHeroOpponentVO.imagePrefix]]
															   cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
							 placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
								 weakSelf.leftImageView.image = image;
								 [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.leftImageView.alpha = 1.0; } completion:nil];
							 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
								 NSLog(@"%@_l.jpg", weakSelf.lChallengeVO.creatorVO.imagePrefix);
							 }];
}

- (void)_reloadRightImage {
	__weak typeof(self) weakSelf = self;
	
	_rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-25.0, 0.0, 320.0, 320.0)];
	_rightImageView.alpha = 0.0;
	[_rightHolderView addSubview:_rightImageView];
	[_rightImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", _rightHeroOpponentVO.imagePrefix]]
															cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
						  placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
							  weakSelf.rightImageView.image = image;
							  [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.rightImageView.alpha = 1.0; } completion:nil];
						  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
							  NSLog(@"%@_l.jpg", weakSelf.rChallengeVO.creatorVO.imagePrefix);
						  }];
}

@end
