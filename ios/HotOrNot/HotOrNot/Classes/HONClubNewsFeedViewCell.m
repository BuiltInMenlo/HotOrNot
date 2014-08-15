//
//  HONClubNewsFeedViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/25/2014 @ 11:00 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+AFNetworking.h"
#import "UILabel+BoundingRect.m"
#import "UILabel+FormattedText.h"
#import "UIView+ReverseSubviews.h"

#import "HONClubNewsFeedViewCell.h"
#import "HONImageLoadingView.h"
#import "HONClubPhotoVO.h"
#import "HONEmotionVO.h"

@interface HONClubNewsFeedViewCell ()
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic) HONClubNewsFeedCellType clubNewsFeedCellType;
@end

@implementation HONClubNewsFeedViewCell
@synthesize clubVO = _clubVO;
@synthesize clubPhotoVO = _clubPhotoVO;
@synthesize clubPhotoIndex = _clubPhotoIndex;
@synthesize delegate = _delegate;


+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellBG_normal"]];
	}
	
	return (self);
}



#pragma mark - Public APIs
- (void)setClubVO:(HONUserClubVO *)clubVO {
	_clubVO = clubVO;
	_clubNewsFeedCellType = (_clubVO.clubEnrollmentType == HONClubEnrollmentTypeMember || (_clubVO.clubEnrollmentType == HONClubEnrollmentTypeOwner && [_clubVO.submissions count] > 0)) ? HONClubNewsFeedCellTypePhotoSubmission : HONClubNewsFeedCellTypeNonMember;
	
	if (_clubNewsFeedCellType != HONClubNewsFeedCellTypePhotoSubmission) {
		NSString *titleCaption = [_clubVO.clubName stringByAppendingString: NSLocalizedString(@"title_joinNow", @" - Join Now!"])];
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.0, 7.0, 238.0, 16.0)];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
		_titleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		_titleLabel.attributedText = [[NSAttributedString alloc] initWithString:titleCaption attributes:@{}];
		[_titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:12] range:[titleCaption rangeOfString:_clubVO.clubName]];
		[_titleLabel setTextColor:[UIColor blackColor] range:[titleCaption rangeOfString:_clubVO.clubName]];
		[self.contentView addSubview:_titleLabel];
		
		UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.frame.origin.x, 25.0, 180.0, 16.0)];
		subtitleLabel.backgroundColor = [UIColor clearColor];
		subtitleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
		subtitleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		[self.contentView addSubview:subtitleLabel];
		
		NSString *subtitleCaption = _clubVO.ownerName;
		if ([_clubVO.activeMembers count] > 0) {
			subtitleCaption = [subtitleCaption stringByAppendingString:@", "];
			int cnt = 0;
			for (HONTrivialUserVO *vo in _clubVO.activeMembers) {
				NSString *caption = ([_clubVO.activeMembers count] - cnt > 1) ? [subtitleCaption stringByAppendingFormat:@"%@, & %d more", vo.username, ([_clubVO.activeMembers count] - cnt)] : [subtitleCaption stringByAppendingString:vo.username];
				CGSize size = [caption boundingRectWithSize:subtitleLabel.frame.size
													options:NSStringDrawingTruncatesLastVisibleLine
												 attributes:@{NSFontAttributeName:subtitleLabel.font}
													context:nil].size;
				NSLog(@"SIZE:[%@](%@)", NSStringFromCGSize(size), caption);
				if (size.width >= subtitleLabel.frame.size.width)
					break;
				
				subtitleCaption = [subtitleCaption stringByAppendingFormat:@"%@, ", vo.username];
				cnt++;
			}
			
			subtitleCaption = [subtitleCaption substringToIndex:[subtitleCaption length] - 2];
			int remaining = [_clubVO.activeMembers count] - cnt;
			
			if (remaining > 0)
				subtitleCaption = [subtitleCaption stringByAppendingFormat:@", & %d more", remaining];
		}
		
		subtitleLabel.text = subtitleCaption;
		
		UIButton *createClubButton = [UIButton buttonWithType:UIButtonTypeCustom];
		createClubButton.frame = CGRectMake(253.0, 2.0, 64.0, 44.0);
		[createClubButton setBackgroundImage:[UIImage imageNamed:@"plusClubButton_nonActive"] forState:UIControlStateNormal];
		[createClubButton setBackgroundImage:[UIImage imageNamed:@"plusClubButton_Active"] forState:UIControlStateHighlighted];
		[createClubButton addTarget:self action:(_clubVO.clubEnrollmentType == HONClubEnrollmentTypeCreate || _clubVO.clubEnrollmentType == HONClubEnrollmentTypeSuggested) ? @selector(_goCreateClub) : (_clubVO.clubEnrollmentType == HONClubEnrollmentTypeThreshold) ? @selector(_goThresholdClub) : @selector(_goJoinClub) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:createClubButton];
		
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 44.0, 44.0)];
		avatarImageView.alpha = 0.0;
		[self.contentView addSubview:avatarImageView];
		
		[[HONImageBroker sharedInstance] maskView:avatarImageView withMask:[UIImage imageNamed:@"avatarMask"]];
		
		void (^avatarImageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			avatarImageView.image = image;
			[UIView animateWithDuration:0.25 animations:^(void) {
				avatarImageView.alpha = 1.0;
			} completion:nil];
		};
		
		void (^avatarImageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONAPICaller sharedInstance] normalizePrefixForImageURL:request.URL.absoluteString] forBucketType:(_clubNewsFeedCellType == HONClubNewsFeedCellTypePhotoSubmission) ? HONS3BucketTypeAvatars : HONS3BucketTypeClubs completion:nil];
			
			[avatarImageView setImageWithURL:[NSURL URLWithString:[[[HONClubAssistant sharedInstance] defaultCoverImageURL] stringByAppendingString:kSnapMediumSuffix]]];
			[UIView animateWithDuration:0.25 animations:^(void) {
				avatarImageView.alpha = 1.0;
			} completion:nil];
		};
		
		[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[ _clubVO.coverImagePrefix stringByAppendingString:kSnapThumbSuffix]]
																 cachePolicy:kURLRequestCachePolicy
															 timeoutInterval:[HONAppDelegate timeoutInterval]]
							   placeholderImage:nil
										success:avatarImageSuccessBlock
										failure:avatarImageFailureBlock];
	}
}

- (void)setClubPhotoVO:(HONClubPhotoVO *)clubPhotoVO {
	_clubPhotoVO = clubPhotoVO;
	_clubPhotoIndex = 0;
	[_clubVO.submissions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONClubPhotoVO *vo = (HONClubPhotoVO *)obj;
		if (vo.challengeID == _clubPhotoVO.challengeID) {
			_clubPhotoIndex = idx;
			*stop = YES;
		}
	}];
	
	if (_clubNewsFeedCellType == HONClubNewsFeedCellTypePhotoSubmission) {
		NSString *titleCaption = [NSString stringWithFormat:NSLocalizedString(@"in_news", @"%@ - in %@"), _clubPhotoVO.username, _clubVO.clubName]; //@" - "
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(69.0, 10.0, 210.0, 16.0)];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
		_titleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		_titleLabel.attributedText = [[NSAttributedString alloc] initWithString:titleCaption attributes:@{}];
		[_titleLabel setTextColor:[UIColor blackColor] range:NSMakeRange(0, [_clubPhotoVO.username length])];
		[_titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:12] range:NSMakeRange([titleCaption length] - [_clubVO.clubName length], [_clubVO.clubName length])];
		[self.contentView addSubview:_titleLabel];
		
		_imageLoadingView = [[HONImageLoadingView alloc] initAtPos:CGPointMake(18.0, 16.0) asLargeLoader:NO];
		[self.contentView addSubview:_imageLoadingView];
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(17.0, 16.0, 44.0, 44.0)];
		[self.contentView addSubview:imageView];
		
		[[HONImageBroker sharedInstance] maskView:imageView withMask:[UIImage imageNamed:@"thumbMask"]];
		
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			imageView.image = image;
			[UIView animateWithDuration:0.25 animations:^(void) {
				imageView.alpha = 1.0;
			} completion:nil];
		};
		
		void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONAPICaller sharedInstance] normalizePrefixForImageURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeClubs completion:nil];
			
			
			NSLog(@"DEFAULT:[%@]", [[[HONClubAssistant sharedInstance] defaultCoverImageURL] stringByAppendingString:kSnapMediumSuffix]);
			[imageView setImageWithURL:[NSURL URLWithString:[[[HONClubAssistant sharedInstance] defaultCoverImageURL] stringByAppendingString:kSnapMediumSuffix]]];
			[UIView animateWithDuration:0.25 animations:^(void) {
				imageView.alpha = 1.0;
			} completion:nil];
		};
		
		[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_clubPhotoVO.imagePrefix stringByAppendingString:kSnapThumbSuffix]]
														   cachePolicy:kURLRequestCachePolicy
													   timeoutInterval:[HONAppDelegate timeoutInterval]]
						 placeholderImage:nil
								  success:imageSuccessBlock
								  failure:imageFailureBlock];
		
		UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		avatarButton.frame = imageView.frame;
		[avatarButton addTarget:self action:@selector(_goUserProfile) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:avatarButton];
		
		UIButton *usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
		usernameButton.frame = [_titleLabel boundingRectForCharacterRange:[titleCaption rangeOfString:_clubPhotoVO.username]];
		[usernameButton addTarget:self action:@selector(_goUserProfile) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:usernameButton];
		
		[_titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:12] range:[titleCaption rangeOfString:_clubPhotoVO.username]];
		
		_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(270.0, 12.0, 35.0, 16.0)];
		_timeLabel.backgroundColor = [UIColor clearColor];
		_timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
		_timeLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		_timeLabel.textAlignment = NSTextAlignmentRight;
		_timeLabel.text = [[HONDateTimeAlloter sharedInstance] intervalSinceDate:_clubVO.updatedDate];
		[self.contentView addSubview:_timeLabel];
		
		NSMutableArray *prev = [NSMutableArray array];
		
		int cnt = 0;
		for (HONEmotionVO *emotionVO in [[HONClubAssistant sharedInstance] emotionsForClubPhoto:_clubPhotoVO]) {
			BOOL isFound = NO;
			for (NSString *name in prev) {
				if ([name isEqualToString:emotionVO.emotionName]) {
					isFound = YES;
					break;
				}
			}
			
			if (!isFound) {
				UIView *emotionView = [self _viewForEmotion:emotionVO];
				emotionView.frame = CGRectOffset(emotionView.frame, 69.0 + (cnt * 30), 34.0);
				[self.contentView addSubview:emotionView];
				
				if (++cnt == 7) {
					UILabel *elipsisLabel = [[UILabel alloc] initWithFrame:CGRectMake(289.0, 46.0, 15.0, 14.0)];
					elipsisLabel.backgroundColor = [UIColor clearColor];
					elipsisLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:14];
					elipsisLabel.textColor = [UIColor blackColor];
					elipsisLabel.text = @"…";
					[self.contentView addSubview:elipsisLabel];
					
					break;
				}
			}
		}
	}
}


#pragma mark - Navigation
- (void)_goCreateClub {
	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:createClubWithProtoVO:)])
		[self.delegate clubNewsFeedViewCell:self createClubWithProtoVO:_clubVO];
}

- (void)_goUserProfile {
	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:showUserProfileForClubPhoto:)])
		[self.delegate clubNewsFeedViewCell:self showUserProfileForClubPhoto:_clubPhotoVO];
}

- (void)_goJoinClub {
	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:joinClub:)])
		[self.delegate clubNewsFeedViewCell:self joinClub:_clubVO];
}

- (void)_goThresholdClub {
	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:joinThresholdClub:)])
		[self.delegate clubNewsFeedViewCell:self joinThresholdClub:_clubVO];
}

- (void)_goLike {
	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:upvoteClubPhoto:)])
		[self.delegate clubNewsFeedViewCell:self upvoteClubPhoto:_clubPhotoVO];
}

- (void)_goReply {
	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:replyToClubPhoto:)])
		[self.delegate clubNewsFeedViewCell:self replyToClubPhoto:_clubVO];
}


#pragma mark - UI Presentation
- (UIView *)_viewForEmotion:(HONEmotionVO *)emotionVO {
	CGRect orgFrame = {0.0, 0.0, 150.0, 150.0};
	CGRect adjFrame = {0.0, 0.0, 25.0, 25.0};
	
	UIView *view = [[UIView alloc] initWithFrame:adjFrame];
	view.contentMode = UIViewContentModeRedraw;
	view.layer.borderColor = [UIColor clearColor].CGColor;
	view.layer.borderWidth = 2.5f;
	view.layer.shouldRasterize = YES;
	view.layer.rasterizationScale = 3.0f;
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:view asLargeLoader:NO];
	imageLoadingView.alpha = 0.5;
	[view addSubview:imageLoadingView];
	
	CGSize scaleSize = CGSizeMake(adjFrame.size.width / orgFrame.size.width, adjFrame.size.height / orgFrame.size.height);
	CGPoint offsetPt = CGPointMake(CGRectGetMidX(adjFrame) - CGRectGetMidX(orgFrame), CGRectGetMidY(adjFrame) - CGRectGetMidY(orgFrame));
	
	CGAffineTransform transform = CGAffineTransformMake(scaleSize.width, 0.0, 0.0, scaleSize.height, offsetPt.x, offsetPt.y);
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:orgFrame];
	imageView.transform = transform;
	[imageView setTag:[emotionVO.emotionID intValue]];
	imageView.alpha = 0.0;
	[view addSubview:imageView];
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[imageLoadingView stopAnimating];
		[imageLoadingView removeFromSuperview];
	};
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		imageView.image = image;
		
		[UIView animateWithDuration:0.125 animations:^(void) {
			imageView.alpha = 1.0;
		} completion:^(BOOL finished) {
			[imageLoadingView stopAnimating];
			[imageLoadingView removeFromSuperview];
		}];
	};
	
	[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:emotionVO.smallImageURL]
													   cachePolicy:NSURLRequestReturnCacheDataElseLoad
												   timeoutInterval:[HONAppDelegate timeoutInterval]]
					 placeholderImage:nil
							  success:imageSuccessBlock
							  failure:imageFailureBlock];
	
	return (view);
}

@end
