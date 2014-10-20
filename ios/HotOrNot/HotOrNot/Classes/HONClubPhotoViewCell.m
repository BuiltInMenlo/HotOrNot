//
//  HONClubPhotoViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/14/2014 @ 21:59 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"
#import "UIImageView+AFNetworking.h"
#import "UILabel+BoundingRect.h"
#import "UILabel+FormattedText.h"

#import "PicoSticker.h"

#import "HONClubPhotoViewCell.h"
#import "HONEmotionVO.h"
#import "HONImageLoadingView.h"

@interface HONClubPhotoViewCell ()
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *emotionLabel;
@property (nonatomic, strong) UIView *tintedView;

@property (nonatomic, strong) NSMutableArray *emotionViews;
@property (nonatomic, strong) NSMutableArray *emotions;
@property (nonatomic) CGFloat emotionInsetAmt;
@property (nonatomic) CGSize emotionSpacingSize;
@property (nonatomic) UIOffset indHistory;
@property (nonatomic, strong) NSTimer *tintTimer;
@end

@implementation HONClubPhotoViewCell
@synthesize clubVO = _clubVO;
@synthesize clubPhotoVO = _clubPhotoVO;

const CGRect kEmotionInitFrame = {80.0f, 80.0f, 53.0f, 53.0f};
const CGRect kEmotionLoadedFrame = {0.0f, 0.0f, 212.0f, 212.0f};
const CGRect kEmotionOutroFrame = {-6.0f, -6.0f, 224.0f, 224.0f};
const CGSize kStickerPaddingSize = {108.0f, 108.0f};

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		self.contentView.frame = [UIScreen mainScreen].bounds;
	}
	
	return (self);
}

- (void)dealloc {
	_scrollView.delegate = nil;
}

- (void)setClubPhotoVO:(HONClubPhotoVO *)clubPhotoVO {
	_clubPhotoVO = clubPhotoVO;
	
	if ([_clubPhotoVO.imagePrefix rangeOfString:@"defaultClubPhoto"].location == NSNotFound) {
		_imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:self.contentView asLargeLoader:NO];
		[self.contentView addSubview:_imageLoadingView];
	}
	
	_imgView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
	[self.contentView addSubview:_imgView];
	
	
	//NSLog(@"IMG PREFIX:[%@]", _clubPhotoVO.imagePrefix);
	if ([_clubPhotoVO.imagePrefix rangeOfString:@"defaultClubPhoto"].location != NSNotFound) {
//		[self _changeTint];
//		_tintTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(_changeTint) userInfo:nil repeats:YES];
		
	} else {
		if (_clubPhotoVO.photoType == HONClubPhotoTypeGIF) {
			FLAnimatedImageView *animatedImageView = [[FLAnimatedImageView alloc] init];
			animatedImageView.frame = self.contentView.frame;
			animatedImageView.contentMode = UIViewContentModeScaleAspectFill; // fills frame w/ proprotions
			animatedImageView.clipsToBounds = YES;
			[_imgView addSubview:animatedImageView];
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				NSURL *url = [NSURL URLWithString:@"https://cdn.picocandy.com/1df5644d9e94/t/54330ce5ab4b8b0468000166/small.gif"];//[_clubPhotoVO.imagePrefix stringByAppendingString:[kSnapLargeSuffix stringByReplacingOccurrencesOfString:@".jpg" withString:@"gif"]]];
				NSLog(@"IMG URL:[%@]", url);
				FLAnimatedImage *animatedImage1 = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
				
				dispatch_async(dispatch_get_main_queue(), ^{
					animatedImageView.animatedImage = animatedImage1;
				});
			});
			
		} else {
			void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
				_imgView.image = image;
//				[self _loadEmotions];
			};
			
			void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
				[_imgView setImageWithURL:[NSURL URLWithString:[[HONClubAssistant sharedInstance] rndCoverImageURL]]];
				[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONAPICaller sharedInstance] normalizePrefixForImageURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeClubs completion:nil];
			};
			
			[_imgView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_clubPhotoVO.imagePrefix stringByAppendingString:([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]]
																cachePolicy:kOrthodoxURLCachePolicy
															timeoutInterval:[HONAppDelegate timeoutInterval]]
							  placeholderImage:nil
									   success:imageSuccessBlock
									   failure:imageFailureBlock];
		}
	}
	
	[self.contentView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bgComposeOverlay"]]];
	
	CGSize maxSize = CGSizeMake(296.0, 24.0);
	CGSize size = [_clubPhotoVO.username boundingRectWithSize:maxSize
													  options:(NSStringDrawingTruncatesLastVisibleLine)
												   attributes:@{NSFontAttributeName:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:19]}
													  context:nil].size;
	
	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(11.0, 80.0, MIN(maxSize.width, size.width), 24.0)];
	usernameLabel.backgroundColor = [UIColor clearColor];
	usernameLabel.textColor = [UIColor whiteColor];
	usernameLabel.shadowColor = [UIColor blackColor];
	usernameLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	usernameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:19];
	usernameLabel.text = _clubPhotoVO.username;
	//[self.contentView addSubview:usernameLabel];
	
	UIButton *usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	usernameButton.frame = usernameLabel.frame;
	[usernameButton addTarget:self action:@selector(_goUserProfile) forControlEvents:UIControlEventTouchUpInside];
	//[self.contentView addSubview:usernameButton];
					  
	_emotions = [NSMutableArray array];
	_emotionViews = [NSMutableArray array];
	_indHistory = UIOffsetZero;
	_emotionSpacingSize = CGSizeMake(kEmotionLoadedFrame.size.width + kStickerPaddingSize.width, kEmotionLoadedFrame.size.height + kStickerPaddingSize.height);
	_emotionInsetAmt = 0.5 * (320.0 - kEmotionLoadedFrame.size.width);
	
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, (([UIScreen mainScreen].bounds.size.height - kEmotionLoadedFrame.size.height) * 0.5), 320.0, kEmotionLoadedFrame.size.height)];
//	_scrollView.contentSize = CGSizeMake([_clubPhotoVO.subjectNames count] * (kEmotionLoadedFrame.size.width + 16.0), _scrollView.frame.size.height);
	_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height);
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.alwaysBounceHorizontal = YES;
	_scrollView.delegate = self;
	_scrollView.pagingEnabled = YES;
//	_scrollView.contentInset = UIEdgeInsetsMake(0.0, _emotionInsetAmt, 0.0, _emotionInsetAmt);
	[self.contentView addSubview:_scrollView];
	
	int cnt = 0;
	for (HONEmotionVO *emotionVO in [[HONClubAssistant sharedInstance] emotionsForClubPhoto:_clubPhotoVO]) {
		UIView *emotionView = [self _viewForEmotion:emotionVO atIndex:cnt];
		emotionView.frame = CGRectOffset(emotionView.frame, _emotionInsetAmt + (cnt * (kEmotionLoadedFrame.size.width + kStickerPaddingSize.width)), 0.0);
		[_scrollView addSubview:emotionView];
		[_emotionViews addObject:emotionView];
		[_emotions addObject:emotionVO];
		
		UIButton *nextPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
		nextPageButton.frame = emotionView.frame;
		[nextPageButton addTarget:self action:@selector(_goNextPhoto) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:nextPageButton];
		
		cnt++;
	}
	
	_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * [_emotions count], _scrollView.frame.size.height);//([_emotions count] == 1) ? _scrollView.frame.size.width : MAX(_scrollView.frame.size.width, [_emotions count] * _emotionSpacingSize.width), _scrollView.contentSize.height);
//	[_scrollView setContentOffset:CGPointMake(-_scrollView.contentInset.left, 0.0) animated:NO];
	
//	if ([_emotions count] == 1)
//		_scrollView.contentInset = UIEdgeInsetsMake(0.0, _scrollView.contentInset.left, 0.0, -_scrollView.contentInset.right);
	
	
	
	_tintedView = [[UIView alloc] initWithFrame:CGRectMake(0.0, (_scrollView.frame.origin.y + _scrollView.frame.size.height) + 50.0, 320.0, 47.0)];
	_tintedView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
//	[self.contentView addSubview:_tintedView];
	
	_emotionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 43.0)];
	_emotionLabel.backgroundColor = [UIColor clearColor];
	_emotionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:21];
	_emotionLabel.textColor = [UIColor whiteColor];
	_emotionLabel.textAlignment = NSTextAlignmentCenter;
	_emotionLabel.text = @"";//((HONEmotionVO *)[_emotions firstObject]).emotionName;
	[_tintedView addSubview:_emotionLabel];
	
	[self _transitionToCaption:((HONEmotionVO *)[_emotions firstObject]).emotionName withCompletion:nil];
	
	UILabel *participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, [UIScreen mainScreen].bounds.size.height - 34.0, 150.0, 30.0)];
	participantsLabel.backgroundColor = [UIColor clearColor];
	participantsLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
	participantsLabel.textColor = [UIColor blackColor];
//	participantsLabel.shadowColor = [UIColor colorWithWhite:0.5 alpha:0.75];
//	participantsLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	participantsLabel.text = @"Seen: 1";//[NSString stringWithFormat:@"1/%d", _clubVO.totalMembers];
	[self.contentView addSubview:participantsLabel];
	
	[[HONAPICaller sharedInstance] retrieveSeenTotalForChallengeWithChallengeID:_clubPhotoVO.challengeID completion:^(NSDictionary *result) {
		int tot = [[result objectForKey:@"results"] count];
		participantsLabel.text = [NSString stringWithFormat:@"Seen: %d", tot];
	}];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(160.0, [UIScreen mainScreen].bounds.size.height - 34.0, 150.0, 30.0)];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
	timeLabel.textColor = [UIColor blackColor];
//	timeLabel.shadowColor = [UIColor colorWithWhite:0.5 alpha:0.75];
//	timeLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = [[[HONDateTimeAlloter sharedInstance] intervalSinceDate:_clubPhotoVO.addedDate] stringByAppendingString:@""];
	[self.contentView addSubview:timeLabel];
	
//	UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	likeButton.frame = CGRectMake(-3.0, [UIScreen mainScreen].bounds.size.height - 74.0, 149, 64.0);
//	[likeButton setBackgroundImage:[UIImage imageNamed:@"likeTimelineButton_nonActive"] forState:UIControlStateNormal];
//	[likeButton setBackgroundImage:[UIImage imageNamed:@"likeTimelineButton_Active"] forState:UIControlStateHighlighted];
//	[likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
//	[self.contentView addSubview:likeButton];
//	
//	UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	replyButton.frame = CGRectMake(174, [UIScreen mainScreen].bounds.size.height - 74.0, 149, 64.0);
//	[replyButton setBackgroundImage:[UIImage imageNamed:@"replyTimelineButton_nonActive"] forState:UIControlStateNormal];
//	[replyButton setBackgroundImage:[UIImage imageNamed:@"replyTimelineButton_Active"] forState:UIControlStateHighlighted];
//	[replyButton addTarget:self action:@selector(_goReply) forControlEvents:UIControlEventTouchUpInside];
//	[self.contentView addSubview:replyButton];
	
	_scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(135.0, [UIScreen mainScreen].bounds.size.height - 50.0, 50.0, 16.0)];
	_scoreLabel.backgroundColor = [UIColor clearColor];
	_scoreLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:14];
	_scoreLabel.textColor = [UIColor blackColor];
	_scoreLabel.textAlignment = NSTextAlignmentCenter;
	_scoreLabel.text = @"0";
//	[self.contentView addSubview:_scoreLabel];
}


- (void)_goSelectorDelay:(id)sender {
	NSMutableArray *emotions = [NSMutableArray array];
	[_scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (idx % 2 == 0)
			[emotions addObject:[((UIView *)obj).subviews firstObject]];
	}];
}


#pragma mark - Navigation
- (void)_goUserProfile {
	if ([self.delegate respondsToSelector:@selector(clubPhotoViewCell:showUserProfileForClubPhoto:)])
		[self.delegate clubPhotoViewCell:self showUserProfileForClubPhoto:_clubPhotoVO];
}

- (void)_goLike {
	_scoreLabel.text = [@"" stringFromInt:++_clubPhotoVO.score];
	
	if ([self.delegate respondsToSelector:@selector(clubPhotoViewCell:upvotePhoto:)])
		[self.delegate clubPhotoViewCell:self upvotePhoto:_clubPhotoVO];
}

- (void)_goReply {
	if ([self.delegate respondsToSelector:@selector(clubPhotoViewCell:replyToPhoto:)])
		[self.delegate clubPhotoViewCell:self replyToPhoto:_clubPhotoVO];
}

- (void)_goNextPhoto {
	if ([self.delegate respondsToSelector:@selector(clubPhotoViewCell:advancePhoto:)])
		[self.delegate clubPhotoViewCell:self advancePhoto:_clubPhotoVO];
}


#pragma mark - UI Presentation
- (void)_loadEmotions {
	int cnt = 0;
	for (HONEmotionVO *emotionVO in [[HONClubAssistant sharedInstance] emotionsForClubPhoto:_clubPhotoVO]) {
		UIView *emotionView = [self _viewForEmotion:emotionVO atIndex:cnt];
		emotionView.frame = CGRectOffset(emotionView.frame, _emotionInsetAmt + (cnt * (kEmotionLoadedFrame.size.width + kStickerPaddingSize.width)), 0.0);
		[_scrollView addSubview:emotionView];
		[_emotionViews addObject:emotionView];
		[_emotions addObject:emotionVO];
		
		UIButton *nextPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
		nextPageButton.frame = emotionView.frame;
		[nextPageButton addTarget:self action:@selector(_goNextPhoto) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:nextPageButton];
		
		cnt++;
	}
	
	_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * [_emotions count], _scrollView.frame.size.height);
}

- (void)_changeTint {
	CGFloat hue = (arc4random() % 256 / 256.0);
	CGFloat saturation = (arc4random() % 128 / 256.0) + 0.5;
	CGFloat brightness = (arc4random() % 128 / 256.0) + 0.5;
	UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
	
	[UIView animateWithDuration:2.0 animations:^(void) {
		_imgView.layer.backgroundColor = color.CGColor;
	} completion:nil];
}

- (void)_transitionToCaption:(NSString *)caption withCompletion:(void (^)(BOOL finished))completion {
	
	if ([caption isEqualToString:_emotionLabel.text]) {
		_emotionLabel.text = caption;
	
	} else {
		UILabel *outroLabel = [[UILabel alloc] initWithFrame:_emotionLabel.frame];
		outroLabel.backgroundColor = _emotionLabel.backgroundColor;
		outroLabel.font = _emotionLabel.font;
		outroLabel.textColor = _emotionLabel.textColor;
		outroLabel.textAlignment = _emotionLabel.textAlignment;
		outroLabel.text = _emotionLabel.text;
		[_tintedView addSubview:outroLabel];
		
		_emotionLabel.alpha = 0.0;
		_emotionLabel.text = caption;
		
		[UIView animateWithDuration:0.125
						 animations:^(void) {
							 outroLabel.alpha = 0.0;
							 _emotionLabel.alpha = 1.0;
							 
						 } completion:^(BOOL finished) {
							 [outroLabel removeFromSuperview];
							 
							 if (completion)
								 completion(finished);
		}];
	}
}

- (UIView *)_viewForEmotion:(HONEmotionVO *)emotionVO atIndex:(int)index {
	UIView *holderView = [[UIView alloc] initWithFrame:kEmotionLoadedFrame];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:holderView asLargeLoader:NO];
	imageLoadingView.alpha = 0.000667;
	[imageLoadingView startAnimating];
	[holderView addSubview:imageLoadingView];
	
//	PicoSticker *picoSticker = [[PicoSticker alloc] initWithPCContent:emotionVO.pcContent];
//	[holderView addSubview:picoSticker];
	
//	PicoSticker *picoSticker = [[HONStickerAssistant sharedInstance] stickerFromCandyBoxWithContentID:emotionVO.emotionID];
//	[holderView addSubview:picoSticker];
	
	CGSize scaleSize = CGSizeMake(kEmotionInitFrame.size.width / kEmotionLoadedFrame.size.width, kEmotionInitFrame.size.height / kEmotionLoadedFrame.size.height);
	CGPoint offsetPt = CGPointMake(CGRectGetMidX(kEmotionInitFrame) - CGRectGetMidX(kEmotionLoadedFrame), CGRectGetMidY(kEmotionInitFrame) - CGRectGetMidY(kEmotionLoadedFrame));
	CGAffineTransform transform = CGAffineTransformMake(scaleSize.width, 0.0, 0.0, scaleSize.height, offsetPt.x, offsetPt.y);
	
	if (emotionVO.imageType == HONEmotionImageTypePNG) {
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:kEmotionLoadedFrame];
		[imageView setTintColor:[UIColor whiteColor]];
		[imageView setTag:[emotionVO.emotionID intValue]];
		imageView.alpha = 0.0;
		imageView.transform = transform;
		[holderView addSubview:imageView];
	
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			imageView.image = image;
			
			[imageLoadingView stopAnimating];
			imageLoadingView.hidden = YES;
			[imageLoadingView removeFromSuperview];
			
			[UIView beginAnimations:@"fade" context:nil];
			[UIView setAnimationDuration:0.250];
			[UIView setAnimationDelay:0.125];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[imageView setTintColor:[UIColor clearColor]];
			[UIView commitAnimations];
			
			[UIView animateWithDuration:0.250 delay:0.500 + (0.125 * index)
				 usingSpringWithDamping:0.750 initialSpringVelocity:0.125
								options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationCurveEaseInOut)
			 
							 animations:^(void) {
								 imageView.alpha = 1.0;
								 imageView.transform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
							 } completion:^(BOOL finished) {
							 }];
			
		};
		
		void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			[imageLoadingView stopAnimating];
			imageLoadingView.hidden = YES;
			[imageLoadingView removeFromSuperview];
		};
		
	//	NSLog(@"emotionVO.largeImageURL:[%@]", emotionVO.largeImageURL);
		[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:emotionVO.largeImageURL]
														   cachePolicy:kOrthodoxURLCachePolicy
													   timeoutInterval:[HONAppDelegate timeoutInterval]]
						 placeholderImage:nil
								  success:imageSuccessBlock
								  failure:imageFailureBlock];
		
	} else {
		FLAnimatedImageView *animatedImageView = [[FLAnimatedImageView alloc] init];
		animatedImageView.contentMode = UIViewContentModeScaleAspectFit; // centers in frame
		animatedImageView.clipsToBounds = YES;
		animatedImageView.frame = kEmotionLoadedFrame;
		animatedImageView.alpha = 0.0;
		animatedImageView.transform = transform;
		[holderView addSubview:animatedImageView];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSURL *url = [NSURL URLWithString:emotionVO.smallImageURL];
			FLAnimatedImage *animatedImage1 = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				animatedImageView.animatedImage = animatedImage1;
				
				[UIView animateWithDuration:0.250 delay:0.500 + (0.125 * index)
					 usingSpringWithDamping:0.750 initialSpringVelocity:0.125
									options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationCurveEaseInOut)
				 
								 animations:^(void) {
									 animatedImageView.alpha = 1.0;
									 animatedImageView.transform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
								 } completion:^(BOOL finished) {
								 }];
			});
		});
	}
	
	return (holderView);
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	NSLog(@"[*:*] scrollViewDidScroll:[%@] (%@)", NSStringFromCGSize(scrollView.contentSize), NSStringFromCGPoint(scrollView.contentOffset));
	
	int currInd = _indHistory.horizontal;
	
//	int axisInd = (_emotionInsetAmt + scrollView.contentOffset.x) / _emotionSpacingSize.width;
	int updtInd = MAX(0, MIN([_emotions count], (_emotionInsetAmt + scrollView.contentOffset.x) / _emotionSpacingSize.width));
	int axisCoord = (updtInd * _emotionSpacingSize.width) - _emotionInsetAmt;
	
	
	
	if (updtInd == currInd) {
//		NSLog(@"‹~|≈~~¡~≈~!~≈~¡~≈~!~≈~¡~≈~!~≈~¡~≈~|[ EQL ]|~≈~¡~≈~!~≈~¡~≈~!~≈~¡~≈~!~≈~¡~~≈|~›");
		
	} else if (updtInd < currInd) {
//		NSLog(@"‹~|≈~~¡~≈~!~≈~¡~≈~!~≈~¡~≈~!~≈~¡~≈~|[ DEC ]|~≈~¡~≈~!~≈~¡~≈~!~≈~¡~≈~!~≈~¡~~≈|~›");
//		NSLog(@"LOWER:[%.02f] COORD:[%d] UPPER:[%.02f] contentOffset:[%d] updtInd:[%d]", (axisCoord - _emotionInsetAmt), axisCoord, (axisCoord + _emotionInsetAmt), scrollView.contentOffset.x, updtInd);
		
		if (scrollView.contentOffset.x < (axisCoord + _emotionInsetAmt) && scrollView.contentOffset.x > (axisCoord - _emotionInsetAmt)) {
			_indHistory = UIOffsetMake(updtInd, currInd);
			[self _transitionToCaption:((HONEmotionVO *)[_emotions objectAtIndex:updtInd]).emotionName withCompletion:nil];
//			_emotionLabel.text = ((HONEmotionVO *)[_emotions objectAtIndex:updtInd]).emotionName;
		} else
			return;
		
	} else if (updtInd > currInd) {
//		NSLog(@"‹~|≈~~¡~≈~!~≈~¡~≈~!~≈~¡~≈~!~≈~¡~≈~|[ INC ]|~≈~¡~≈~!~≈~¡~≈~!~≈~¡~≈~!~≈~¡~~≈|~›");
//		NSLog(@"LOWER:[%.02f] COORD:[%d] UPPER:[%.02f] contentOffset:[%d] updtInd:[%d]", (axisCoord - _emotionInsetAmt), axisCoord, (axisCoord + _emotionInsetAmt), scrollView.contentOffset.x, updtInd);
		
		if (scrollView.contentOffset.x > (axisCoord - _emotionInsetAmt) && scrollView.contentOffset.x < (axisCoord + _emotionInsetAmt)) {
			_indHistory = UIOffsetMake(updtInd, currInd);
			[self _transitionToCaption:((HONEmotionVO *)[_emotions objectAtIndex:updtInd]).emotionName withCompletion:nil];
//			_emotionLabel.text = ((HONEmotionVO *)[_emotions objectAtIndex:updtInd]).emotionName;
			
		} else
			return;
	}
}

@end
