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
	
	NSLog(@"lChallengeID:[%d]", _lChallengeVO.challengeID);
	
	_leftHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 160.0)];
	_leftHolderView.clipsToBounds = YES;
	[self.contentView addSubview:_leftHolderView];
	
	if (_lChallengeVO.challengeID == -1) {
		_leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friendsTile"]];
		_leftImageView.alpha = 0.0;
		[_leftHolderView addSubview:_leftImageView];
		
		UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		selectButton.frame = _leftHolderView.frame;
		[selectButton setBackgroundImage:[UIImage imageNamed:@"discoveryOverlay"] forState:UIControlStateHighlighted];
		[selectButton addTarget:self action:@selector(_goInvite) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:selectButton];
		
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_leftImageView.alpha = 1.0;
		} completion:nil];
	
	} else if (_lChallengeVO.challengeID == 0) {
		_leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchTile"]];
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
		[self _populateCellWithHero:_lChallengeVO.creatorVO isLeftSide:YES];
	}
}

- (void)setRChallengeVO:(HONChallengeVO *)rChallengeVO {
	_rChallengeVO = rChallengeVO;
	
	NSLog(@"rChallengeID:[%d]", _rChallengeVO.challengeID);
	
	_rightHolderView = [[UIView alloc] initWithFrame:CGRectMake(160.0, 0.0, 160.0, 160.0)];
	_rightHolderView.clipsToBounds = YES;
	[self.contentView addSubview:_rightHolderView];
	
	if (_rChallengeVO.challengeID == -1) {
		_rightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friendsTile"]];
		_rightImageView.alpha = 0.0;
		[_rightHolderView addSubview:_rightImageView];
		
		UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		selectButton.frame = _rightHolderView.frame;
		[selectButton setBackgroundImage:[UIImage imageNamed:@"discoveryOverlay"] forState:UIControlStateHighlighted];
		[selectButton addTarget:self action:@selector(_goInvite) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:selectButton];
		
	} else if (_rChallengeVO.challengeID == 0) {
		_rightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchTile"]];
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
		[self _populateCellWithHero:_rChallengeVO.creatorVO isLeftSide:NO];
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

- (void)_goInvite {
	[self.delegate exploreViewCellShowInvite:self];
}

- (void)_goSearch {
	[self.delegate exploreViewCellShowSearch:self];
}


#pragma mark UI Prentation
- (void)_populateCellWithHero:(HONOpponentVO *)opponentVO isLeftSide:(BOOL)isLeft {
	UIView *holderView = (isLeft) ? _leftHolderView: _rightHolderView;
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 160.0)];
	imageView.alpha = 0.0;
	[holderView addSubview:imageView];
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		imageView.image = image;
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			imageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RECREATE_IMAGE_SIZES" object:opponentVO.imagePrefix];
	};
	
	
	[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[opponentVO.imagePrefix stringByAppendingString:kSnapMediumSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
						  placeholderImage:nil
								   success:successBlock
								   failure:failureBlock];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 117.0, 140.0, 18.0)];
	nameLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:14];
	nameLabel.textColor = [UIColor whiteColor];
	nameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
	nameLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = opponentVO.username;
	[holderView addSubview:nameLabel];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 133.0, 140.0, 18.0)];
	subjectLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:14];
	subjectLabel.textColor = [UIColor whiteColor];
	subjectLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
	subjectLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = opponentVO.subjectName;
	[holderView addSubview:subjectLabel];
	
	UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	selectButton.frame = CGRectMake(0.0, 0.0, holderView.frame.size.width, holderView.frame.size.height);
	[selectButton setBackgroundImage:[UIImage imageNamed:@"discoveryOverlay"] forState:UIControlStateHighlighted];
	[selectButton addTarget:self action:(isLeft) ? @selector(_goSelectLeft) : @selector(_goSelectRight) forControlEvents:UIControlEventTouchUpInside];
	[holderView addSubview:selectButton];
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLeftLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.25;
	[selectButton addGestureRecognizer:lpGestureRecognizer];
}


@end
