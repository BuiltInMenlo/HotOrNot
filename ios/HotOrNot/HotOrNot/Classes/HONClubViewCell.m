//
//  HONClubViewCell.m
//  HotOrNot
//
//  Created by BIM  on 8/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"
#import "UIImageView+AFNetworking.h"
#import "UILabel+FormattedText.h"

#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

#import "HONClubViewCell.h"
#import "HONClubPhotoVO.h"
#import "HONImageLoadingView.h"

@interface HONClubViewCell ()
@property (nonatomic, strong) UIView *statsHolderView;
@property (nonatomic, strong) UIView *emotionHolderView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) NSArray *emotionVOs;
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@property (nonatomic, strong) FLAnimatedImageView *animatedImageView;
@property (nonatomic) CGSize maxTitleLabelSize;
@end

const CGRect kOrgLoaderFrame = {17.0f, 17.0f, 42.0f, 44.0f};

@implementation HONClubViewCell
@synthesize delegate = _delegate;
@synthesize caption = _caption;
@synthesize contactUserVO = _contactUserVO;
@synthesize trivialUserVO = _trivialUserVO;
@synthesize clubVO = _clubVO;
@synthesize statusUpdateVO = _statusUpdateVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		_maxTitleLabelSize = CGSizeMake(230.0, 26.0);
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(31.0, 13.0, _maxTitleLabelSize.width, _maxTitleLabelSize.height)];
//		_titleLabel.backgroundColor = [[HONColorAuthority sharedInstance] honDebugDefaultColor];
		_titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
		_titleLabel.textColor = [UIColor blackColor];
		[self.contentView addSubview:_titleLabel];
		
		_subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y + 28.0, _titleLabel.frame.size.width, 14.0)];
//		_subtitleLabel.backgroundColor = [[HONColorAuthority sharedInstance] honDebugColor:HONDebugGreenColor];
		_subtitleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
		_subtitleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		[self.contentView addSubview:_subtitleLabel];
		
		_statsHolderView = [[UIView alloc] initWithFrame:CGRectMake(275.0, 30.0, 16.0, 16.0)];
		[self.contentView addSubview:_statsHolderView];
		
		_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(270.0, 29.0, 34.0, 14.0)];
		_timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
		_timeLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		_timeLabel.backgroundColor = [UIColor clearColor];
		_timeLabel.textAlignment = NSTextAlignmentRight;
		[self.contentView addSubview:_timeLabel];
	}
	
	return (self);
	
}

- (id)initAsCellType:(HONClubViewCellType)cellType {
	if ((self = [self init])) {
		_cellType = cellType;
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setCaption:(NSString *)caption {
	_caption = caption;
	_titleLabel.text = _caption;
	
//	CGSize size = [_caption boundingRectWithSize:_titleLabel.frame.size
//										 options:NSStringDrawingTruncatesLastVisibleLine
//									  attributes:@{NSFontAttributeName:_titleLabel.font}
//										 context:nil].size;
	CGRect maxFrame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y + 10.0, _maxTitleLabelSize.width, _titleLabel.frame.size.height);
//	CGRect reqFrame = CGRectMake(_titleLabel.frame.origin.x - 7.0, _titleLabel.frame.origin.y + 10.0, MIN(_titleLabel.frame.size.width, size.width), MIN(_titleLabel.frame.size.height, size.height));
	
	_titleLabel.frame = maxFrame;
	
}
- (void)setContactUserVO:(HONContactUserVO *)contactUserVO {
	_contactUserVO = contactUserVO;
	
	NSString *nameCaption = _contactUserVO.fullName;//[NSString stringWithFormat:@"Invite %@ to this app", _contactUserVO.fullName];
	_titleLabel.text = nameCaption;
	_titleLabel.attributedText = [[NSAttributedString alloc] initWithString:nameCaption attributes:@{}];
	[_titleLabel setFont:_titleLabel.font range:[nameCaption rangeOfString:_contactUserVO.fullName]];
	
	CGSize size = [[nameCaption stringByAppendingString:@""] boundingRectWithSize:_titleLabel.frame.size
																		  options:NSStringDrawingTruncatesLastVisibleLine
																	   attributes:@{NSFontAttributeName:_titleLabel.font}
																		  context:nil].size;
	
	CGRect maxFrame = CGRectMake(_titleLabel.frame.origin.x - 7.0, _titleLabel.frame.origin.y + 10.0, _maxTitleLabelSize.width, _titleLabel.frame.size.height);
	_titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y + 11.0, MIN(maxFrame.size.width, size.width), MIN(maxFrame.size.height, size.height));
}

- (void)setTrivialUserVO:(HONTrivialUserVO *)trivialUserVO {
	_trivialUserVO = trivialUserVO;
	
	NSString *nameCaption = _trivialUserVO.username;//(_trivialUserVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? @"Me " : _trivialUserVO.username;//[NSString stringWithFormat:@"%@ is…", _trivialUserVO.username];
	_titleLabel.text = nameCaption;
	
	CGSize size = [_titleLabel.text boundingRectWithSize:_titleLabel.frame.size
												options:NSStringDrawingTruncatesLastVisibleLine
											 attributes:@{NSFontAttributeName:_titleLabel.font}
												context:nil].size;
	CGRect maxFrame = CGRectMake(_titleLabel.frame.origin.x - 7.0, _titleLabel.frame.origin.y + 10.0, _maxTitleLabelSize.width, _titleLabel.frame.size.height);
	_titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y + 11.0, MIN(maxFrame.size.width, size.width), MIN(maxFrame.size.height, size.height));
}

- (void)setClubVO:(HONUserClubVO *)clubVO {
	_clubVO = clubVO;
	
//	_statusUpdateVO = ([_clubVO.submissions count] == 0) ? [HONClubPhotoVO clubPhotoWithDictionary:[[HONClubAssistant sharedInstance] emptyClubPhotoDictionary]] : (HONClubPhotoVO *)[_clubVO.submissions firstObject];
//	_emotionVOs = [[HONClubAssistant sharedInstance] emotionsForClubPhoto:_statusUpdateVO];
	
//	NSLog(@"cell.clubVO:[%@]", _clubVO.dictionary);
//	NSLog(@"cell.clubPhotoVO:[%@]", _statusUpdateVO.dictionary);
//	NSLog(@"cell.emotionVOs:[%@]", _emotionVOs);
	
	[super accVisible:NO];
	
	NSString *creatorName = _statusUpdateVO.username;//(_statusUpdateVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? @"You" : _statusUpdateVO.username;
	__block NSMutableString *titleCaption = [creatorName mutableCopy];//  [[creatorName stringByAppendingString:@" is"] mutableCopy];//(_statusUpdateVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? @" are" : @" is"] mutableCopy];
	
	NSString *subtitleCaption = @"";
	NSMutableArray *uniqueParticipants = [NSMutableArray array];
	[_clubVO.submissions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONClubPhotoVO *vo = (HONClubPhotoVO *)obj;
		
		if (![uniqueParticipants containsObject:vo.username])
			[uniqueParticipants addObject:vo.username];
	}];
	
	[_clubVO.activeMembers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
		
		if (![uniqueParticipants containsObject:vo.username])
			[uniqueParticipants addObject:vo.username];
	}];
	
	[_clubVO.pendingMembers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
		
		if (![uniqueParticipants containsObject:vo.username])
			[uniqueParticipants addObject:vo.username];
	}];
	
	for (NSString *username in uniqueParticipants) {
		if ([username isEqualToString:titleCaption])
			continue;
		
		subtitleCaption = [subtitleCaption stringByAppendingFormat:@"%@, ", username];
	}
	
	subtitleCaption = ([subtitleCaption rangeOfString:@", "].location != NSNotFound) ? [subtitleCaption substringToIndex:[subtitleCaption length] - 2] : subtitleCaption;
	subtitleCaption = ([subtitleCaption length] == 2) ? [subtitleCaption stringByAppendingString:titleCaption] : subtitleCaption;
//	NSString *subtitleCaption = [_statusUpdateVO.username stringByAppendingFormat:@" +%d more%@", [uniqueSubmissions count], ([_clubVO.pendingMembers count] > 0) ? [NSString stringWithFormat:@", waiting on %d other%@", [_clubVO.pendingMembers count], ([_clubVO.pendingMembers count] == 1) ? @"" : @"s"] : @""];
	
	_titleLabel.attributedText = [[NSAttributedString alloc] initWithString:titleCaption];
	[_titleLabel setFont:[[[HONFontAllocator alloc] helveticaNeueFontRegular] fontWithSize:18] range:[titleCaption rangeOfString:creatorName]];
	_subtitleLabel.text = subtitleCaption;
	
	_titleLabel.frame = CGRectInset(_titleLabel.frame, -18.0, 0.0);
	_titleLabel.frame = CGRectOffset(_titleLabel.frame, (50.0 + 18.0), 0.0);
	_titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, MIN(_maxTitleLabelSize.width - 30.0, _titleLabel.frame.size.width), _titleLabel.frame.size.height);
	_subtitleLabel.frame = CGRectOffset(_titleLabel.frame, 0.0, 21.0);
	
	_timeLabel.text = [[HONDateTimeAlloter sharedInstance] intervalSinceDate:_statusUpdateVO.addedDate];
	
	_imageLoadingView = [[HONImageLoadingView alloc] initAtPos:CGPointZero asLargeLoader:NO];
	_imageLoadingView.frame = CGRectMake(17.0, 17.0, 42.0, 44.0);
	_imageLoadingView.alpha = 0.75;
	[self.contentView addSubview:_imageLoadingView];
	
	_emotionHolderView = [self _holderViewForStatusUpdate];
	_emotionHolderView.frame = CGRectOffset(_emotionHolderView.frame, 17.0, 11.0);
	[self.contentView addSubview:_emotionHolderView];
	
	HONEmotionVO *emotionVO = (HONEmotionVO *)[_emotionVOs firstObject];
	if (emotionVO.imageType == HONEmotionImageTypeGIF) {
//		NSLog(@"GIF **** EMOTION STICKER:[%@]", emotionVO.smallImageURL);
//		if (!_animatedImageView) {
			_animatedImageView = [[FLAnimatedImageView alloc] init];
			_animatedImageView.contentMode = UIViewContentModeScaleAspectFit; // centers in frame
			_animatedImageView.clipsToBounds = YES;
//		}
		
		_animatedImageView.frame = CGRectOffset(_emotionHolderView.frame, -17.0, -11.0);
		[_emotionHolderView addSubview:_animatedImageView];
		_emotionHolderView.hidden = NO;
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSURL *url = [NSURL URLWithString:emotionVO.smallImageURL];
			FLAnimatedImage *animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				_animatedImageView.animatedImage = animatedImage;
				
				[UIView animateWithDuration:0.125 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
					_emotionHolderView.alpha = 1.0;
					
				} completion:^(BOOL finished) {
					_imageLoadingView.hidden = YES;
					[_imageLoadingView stopAnimating];
				}];
			});
		});
		
	} else if (emotionVO.imageType == HONEmotionImageTypePNG) {
	}

}

- (void)appendTitleCaption:(NSString *)captionSuffix {
	_caption = [_titleLabel.text stringByAppendingString:captionSuffix];
	CGSize size = [_caption boundingRectWithSize:_titleLabel.frame.size
										 options:NSStringDrawingTruncatesLastVisibleLine
									  attributes:@{NSFontAttributeName:_titleLabel.font}
										 context:nil].size;

	_titleLabel.frame = CGRectInset(_titleLabel.frame, MAX(-_maxTitleLabelSize.width, -size.width * 0.5), 0.0);
	_titleLabel.frame = CGRectOffset(_titleLabel.frame, MIN(_maxTitleLabelSize.width, size.width * 0.5), 0.0);
	_titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, MIN(_maxTitleLabelSize.width, _titleLabel.frame.size.width), _titleLabel.frame.size.height);
	_titleLabel.text = _caption;
}

- (void)prependTitleCaption:(NSString *)captionPrefix {
	_caption = [captionPrefix stringByAppendingString:_titleLabel.text];
	
	CGSize size = [_caption boundingRectWithSize:_titleLabel.frame.size
										 options:NSStringDrawingTruncatesLastVisibleLine
									  attributes:@{NSFontAttributeName:_titleLabel.font}
										 context:nil].size;


	_titleLabel.frame = CGRectInset(_titleLabel.frame, MAX(-_maxTitleLabelSize.width, -size.width * 0.5), 0.0);
	_titleLabel.frame = CGRectOffset(_titleLabel.frame, MIN(_maxTitleLabelSize.width, size.width * 0.5), 0.0);
	_titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, MIN(_maxTitleLabelSize.width, _titleLabel.frame.size.width), _titleLabel.frame.size.height);
	_titleLabel.text = _caption;
}

- (void)addSubtitleCaption:(NSString *)caption {
	_subtitleLabel.hidden = NO;
	_subtitleLabel.alpha = 1.0;
	_subtitleLabel.text = caption;
	
	CGSize size = [caption boundingRectWithSize:_titleLabel.frame.size
										options:NSStringDrawingTruncatesLastVisibleLine
									 attributes:@{NSFontAttributeName:_titleLabel.font}
										context:nil].size;
	
	_titleLabel.frame = CGRectInset(_titleLabel.frame, MAX(-_maxTitleLabelSize.width, -size.width * 0.5), 0.0);
	_titleLabel.frame = CGRectOffset(_titleLabel.frame, MIN(_maxTitleLabelSize.width, size.width * 0.5), 0.0);
	_titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, MIN(_maxTitleLabelSize.width, _titleLabel.frame.size.width), _titleLabel.frame.size.height);
	
	_titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, 18.0, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
	_subtitleLabel.frame = CGRectOffset(_titleLabel.frame, 0.0, 21.0);
}

- (void)hideTimeStat {
//	_timeLabel.hidden = YES;
}

- (void)accVisible:(BOOL)isVisible {
	_statsHolderView.hidden = !isVisible;
	_emotionHolderView.hidden = !isVisible;
	_imageLoadingView.hidden = !isVisible;
	_subtitleLabel.hidden = !isVisible;
	//_titleLabel.hidden = !isVisible;
	
	[super accVisible:isVisible];
}


- (void)toggleImageLoading:(BOOL)isLoading {
	HONEmotionVO *emotionVO = (HONEmotionVO *)[_emotionVOs firstObject];
	
	if (emotionVO.imageType == HONEmotionImageTypePNG) {
		if (isLoading) {
			
			_emotionHolderView.hidden = NO;
			UIImageView *imageView = (UIImageView *)[[_emotionHolderView subviews] firstObject];
			
			if (imageView.image == nil) {
				if ([_clubVO.submissions count] == 0)
					[[HONViewDispensor sharedInstance] maskView:imageView withMask:[UIImage imageNamed:@"defaultThumbPhotoMask"]];
				
				void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
					NSLog(@"!!!!!! FAILED:[%@]", request.URL.absoluteURL);
					
					imageView.backgroundColor = [[HONColorAuthority sharedInstance] honLightGreyTextColor];
					imageView.image = [UIImage imageNamed:@"placeholderClubPhoto_small"];
					[[HONViewDispensor sharedInstance] maskView:imageView withMask:[UIImage imageNamed:@"placeholderThumbPhotoMask"]];
					
					[UIView animateWithDuration:0.125 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
						_emotionHolderView.alpha = 1.0;
						
					} completion:^(BOOL finished) {
						_imageLoadingView.hidden = YES;
						[_imageLoadingView stopAnimating];
					}];
				};
				
				void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
					imageView.image = image;
					
					if ([_clubVO.submissions count] == 0) {
						[[HONViewDispensor sharedInstance] maskView:imageView withMask:[UIImage imageNamed:@"placeholderThumbPhotoMask"]];
					}
					
					[UIView animateWithDuration:0.125 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
						_emotionHolderView.alpha = 1.0;
						
					} completion:^(BOOL finished) {
						_imageLoadingView.hidden = YES;
						[_imageLoadingView stopAnimating];
					}];
				};
				
				NSString *imgURL = ([_emotionVOs count] > 0) ? emotionVO.smallImageURL : [_clubVO.coverImagePrefix stringByAppendingString:kSnapLargeSuffix];
				[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imgURL]
																   cachePolicy:kOrthodoxURLCachePolicy
															   timeoutInterval:[HONAppDelegate timeoutInterval]]
								 placeholderImage:nil
										  success:imageSuccessBlock
										  failure:imageFailureBlock];
				
			} else {
				_imageLoadingView.hidden = YES;
				[_imageLoadingView stopAnimating];
			}
			
		} else {
			_imageLoadingView.alpha = 1.0;
			_imageLoadingView.hidden = NO;
				
			UIImageView *imageView = (UIImageView *)[[_emotionHolderView subviews] firstObject];
			[imageView cancelImageRequestOperation];
		}
	}
}

- (void)_goDeselect {
	[super _goDeselect];
	
	NSLog(@"[*:*] clubViewCell:_goDeselect");
	
	if (_clubVO != nil) {
		if ([self.delegate respondsToSelector:@selector(clubViewCell:didSelectClub:)])
			[self.delegate clubViewCell:self didSelectClub:_clubVO];
	
	} else {
		if (_trivialUserVO != nil) {
			if ([self.delegate respondsToSelector:@selector(clubViewCell:didSelectTrivialUser:)])
				[self.delegate clubViewCell:self didSelectTrivialUser:_trivialUserVO];
		
		} else {
			if ([self.delegate respondsToSelector:@selector(clubViewCell:didSelectContactUser:)])
				[self.delegate clubViewCell:self didSelectContactUser:_contactUserVO];
		}
	}
}

- (void)_goSelect {
	[super _goSelect];
	
	NSLog(@"[*:*] clubViewCell:_goSelect");
	
	if (_clubVO != nil) {
		if ([self.delegate respondsToSelector:@selector(clubViewCell:didSelectClub:)])
			[self.delegate clubViewCell:self didSelectClub:_clubVO];
		
	} else {
		if (_trivialUserVO != nil) {
			if ([self.delegate respondsToSelector:@selector(clubViewCell:didSelectTrivialUser:)])
				[self.delegate clubViewCell:self didSelectTrivialUser:_trivialUserVO];
			
		} else {
			if ([self.delegate respondsToSelector:@selector(clubViewCell:didSelectContactUser:)])
				[self.delegate clubViewCell:self didSelectContactUser:_contactUserVO];
		}
	}
}


#pragma mark - UI Presentation
- (UIView *)_holderViewForStatusUpdate {
	UIView *view = [[UIView alloc] initWithFrame:CGRectFromSize(CGSizeMake(50.0, 50.0))];
	view.hidden = YES;
	view.alpha = 0.0;

	UIImageView *imageView = [[UIImageView alloc] initWithFrame:view.frame];
	[view addSubview:imageView];
	
	return (view);
}

@end
