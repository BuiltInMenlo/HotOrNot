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

#import "FishEyeView.h"
#import "PicoSticker.h"

#import "HONClubPhotoViewCell.h"
#import "HONEmotionVO.h"
#import "HONImageLoadingView.h"

@interface HONClubPhotoViewCell () <FishEyeIndexDelegate>
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@property (nonatomic, strong) FishEyeView *fishEyeView;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation HONClubPhotoViewCell
@synthesize indexPath = _indexPath;
@synthesize clubPhotoVO = _clubPhotoVO;
@synthesize clubName = _clubName;


const CGRect kEmotionInitFrame = {78.0f, 78.0f, 44.0f, 44.0f};
const CGRect kEmotionLoadedFrame = {0.0f, 0.0f, 200.0f, 200.0f};
const CGRect kEmotionOutroFrame = {-12.0f, -12.0f, 224.0f, 224.0f};

const CGSize kEmotionMinMagSize = {96.0f, 96.0f};
const CGFloat kEmotionMaxMagRate = 3.0f;




+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		self.contentView.frame = [UIScreen mainScreen].bounds;
		self.backgroundColor = [UIColor blackColor];
	}
	
	return (self);
}

- (void)setClubName:(NSString *)clubName {
	_clubName = clubName;
}

- (void)setClubPhotoVO:(HONClubPhotoVO *)clubPhotoVO {
	_clubPhotoVO = clubPhotoVO;
	
	_imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:self.contentView asLargeLoader:NO];
	[self.contentView addSubview:_imageLoadingView];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
	[self.contentView addSubview:imageView];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		imageView.image = image;
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[imageView setImageWithURL:[NSURL URLWithString:[[HONClubAssistant sharedInstance] rndCoverImageURL]]];
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONAPICaller sharedInstance] normalizePrefixForImageURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeClubs completion:nil];
	};
	
	[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_clubPhotoVO.imagePrefix stringByAppendingString:([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]]
													   cachePolicy:kOrthodoxURLCachePolicy
												   timeoutInterval:[HONAppDelegate timeoutInterval]]
					 placeholderImage:nil
							  success:imageSuccessBlock
							  failure:imageFailureBlock];
	
	
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
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(160.0, [UIScreen mainScreen].bounds.size.height - 34.0, 150.0, 30.0)];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.font = [[[HONFontAllocator sharedInstance] cartoGothicBold] fontWithSize:24];
	timeLabel.textColor = [UIColor whiteColor];
	timeLabel.shadowColor = [UIColor colorWithWhite:0.5 alpha:0.75];
	timeLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = [[[HONDateTimeAlloter sharedInstance] intervalSinceDate:_clubPhotoVO.addedDate] stringByAppendingString:@""];
	[self.contentView addSubview:timeLabel];
					  
//	NSString *format = ([_clubPhotoVO.subjectNames count] == 1) ? NSLocalizedString(@"ago_emotion", nil) :NSLocalizedString(@"ago_emotions", nil);
//	timeLabel.text = [[[HONDateTimeAlloter sharedInstance] intervalSinceDate:_clubPhotoVO.addedDate] stringByAppendingFormat:format, [_clubPhotoVO.subjectNames count]];
//	
//	UILabel *feelingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, [UIScreen mainScreen].bounds.size.height - 208.0, 200.0, 26.0)];
//	feelingLabel.backgroundColor = [UIColor clearColor];
//	feelingLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:19];
//	feelingLabel.textColor = [UIColor whiteColor];
//	feelingLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.75];
//	feelingLabel.shadowOffset = CGSizeMake(1.0, 1.0);
//	
//	feelingLabel.text = NSLocalizedString(@"is_feeling2", nil);
//	[self.contentView addSubview:feelingLabel];
	
	
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, (([UIScreen mainScreen].bounds.size.height - kEmotionLoadedFrame.size.height) * 0.5) + 10.0, 320.0, kEmotionLoadedFrame.size.height)];
	_scrollView.contentSize = CGSizeMake([_clubPhotoVO.subjectNames count] * (kEmotionLoadedFrame.size.width + 6.0), _scrollView.frame.size.height);
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.pagingEnabled = NO;
	_scrollView.contentInset = UIEdgeInsetsMake(0.0, 8.0, 0.0, 0.0);
	_scrollView.contentOffset = CGPointMake(-8.0, 0.0);
	[self.contentView addSubview:_scrollView];
	
	int cnt = 0;
	NSMutableArray *emotions = [NSMutableArray array];
	for (HONEmotionVO *emotionVO in [[HONClubAssistant sharedInstance] emotionsForClubPhoto:_clubPhotoVO]) {
		UIView *emotionView = [self _viewForEmotion:emotionVO atIndex:cnt];
		emotionView.frame = CGRectOffset(emotionView.frame, cnt * (kEmotionLoadedFrame.size.width + 6.0), 0.0);
		[_scrollView addSubview:emotionView];
		[emotions addObject:emotionView];
		
		UIButton *nextPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
		nextPageButton.frame = emotionView.frame;
		[nextPageButton addTarget:self action:@selector(_goNextPhoto) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:nextPageButton];
		
		cnt++;
	}
	
	
//	[self performSelector:@selector(_goSelectorDelay:) withObject:nil afterDelay:5.0];
	
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
	_scoreLabel.textColor = [UIColor whiteColor];
	_scoreLabel.textAlignment = NSTextAlignmentCenter;
	_scoreLabel.text = [@"" stringFromInt:_clubPhotoVO.score];
//	[self.contentView addSubview:_scoreLabel];
}


- (void)_goSelectorDelay:(id)sender {
	NSMutableArray *emotions = [NSMutableArray array];
	[_scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (idx % 2 == 0)
			[emotions addObject:[((UIView *)obj).subviews firstObject]];
	}];
	
	
	_fishEyeView = [[FishEyeView alloc] initializeWithImages:emotions
												 withMinSize:kEmotionMinMagSize
												 withMaxRate:kEmotionMaxMagRate
											 withActionCount:7];
	_fishEyeView.indexDelegate = self;
	
	_fishEyeView.backgroundColor = [[HONColorAuthority sharedInstance] honDebugDefaultColor];
	[self.contentView addSubview:_fishEyeView];
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
	_indexPath = indexPath;
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
- (UIView *)_viewForEmotion:(HONEmotionVO *)emotionVO atIndex:(int)index {
	UIView *holderView = [[UIView alloc] initWithFrame:kEmotionLoadedFrame];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:holderView asLargeLoader:NO];
	imageLoadingView.alpha = 0.667;
	[imageLoadingView startAnimating];
	[holderView addSubview:imageLoadingView];
	
//	PicoSticker *picoSticker = [[PicoSticker alloc] initWithPCContent:emotionVO.pcContent];
//	[holderView addSubview:picoSticker];
	
//	PicoSticker *picoSticker = [[HONStickerAssistant sharedInstance] stickerFromCandyBoxWithContentID:emotionVO.emotionID];
//	[holderView addSubview:picoSticker];
	
	CGSize scaleSize = CGSizeMake(kEmotionInitFrame.size.width / kEmotionLoadedFrame.size.width, kEmotionInitFrame.size.height / kEmotionLoadedFrame.size.height);
	CGPoint offsetPt = CGPointMake(CGRectGetMidX(kEmotionInitFrame) - CGRectGetMidX(kEmotionLoadedFrame), CGRectGetMidY(kEmotionInitFrame) - CGRectGetMidY(kEmotionLoadedFrame));
	CGAffineTransform transform = CGAffineTransformMake(scaleSize.width, 0.0, 0.0, scaleSize.height, offsetPt.x, offsetPt.y);
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:kEmotionLoadedFrame];
	[imageView setTintColor:[UIColor whiteColor]];
	[imageView setTag:[emotionVO.emotionID intValue]];
	imageView.alpha = 0.0;
	imageView.transform = transform;
	[holderView addSubview:imageView];
	
//	UIImageView *fxImageView = [[UIImageView alloc] initWithFrame:kEmotionLoadedFrame];
//	fxImageView.hidden = YES;
//	[holderView addSubview:fxImageView];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		imageView.image = image;
//		fxImageView.image = image;
		
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
//							 fxImageView.hidden = NO;
						 }];
		
//		CGSize scaleSize = CGSizeMake(kEmotionOutroFrame.size.width / kEmotionLoadedFrame.size.width, kEmotionOutroFrame.size.height / kEmotionLoadedFrame.size.height);
//		CGPoint offsetPt = CGPointMake(CGRectGetMidX(kEmotionOutroFrame) - CGRectGetMidX(kEmotionLoadedFrame), CGRectGetMidY(kEmotionOutroFrame) - CGRectGetMidY(kEmotionLoadedFrame));
//		
//		[UIView animateWithDuration:0.250 delay:(0.250 + (0.125 * index))
//			 usingSpringWithDamping:0.950 initialSpringVelocity:0.000
//							options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationCurveEaseOut)
//		 
//						 animations:^(void) {
//							 fxImageView.alpha = 0.0;
//							 fxImageView.transform = CGAffineTransformMake(scaleSize.width, 0.0, 0.0, scaleSize.height, offsetPt.x, offsetPt.y);;
//							 
//						 }completion:^(BOOL finished) {
//							 [fxImageView removeFromSuperview];
//						 }];
		
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
	return (holderView);
}

#pragma mark - FishEyeView Delegates
- (void)fishEyeIndex:(NSUInteger)index {
	NSLog(@"[:|:] fishEyeIndex:[%d]", index);
}


@end
