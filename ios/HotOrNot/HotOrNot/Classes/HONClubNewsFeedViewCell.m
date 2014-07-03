//
//  HONClubNewsFeedViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/25/2014 @ 11:00 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "UILabel+BoundingRect.m"
#import "UILabel+FormattedText.h"
#import "UIView+ReverseSubviews.h"

#import "HONClubNewsFeedViewCell.h"
#import "HONClubPhotoVO.h"
#import "HONEmotionVO.h"

@interface HONClubNewsFeedViewCell ()
@property (nonatomic, strong) HONClubPhotoVO *photoVO;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic) HONClubNewsFeedCellType clubNewsFeedCellType;
@end

@implementation HONClubNewsFeedViewCell
//@synthesize timelineItemVO = _timelineItemVO;
@synthesize clubVO = _clubVO;
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
	self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(_clubNewsFeedCellType == HONClubNewsFeedCellTypePhotoSubmission) ? @"newsCellBG_normal" : @"viewCellBG_normal"]];
	
	NSString *emotions = @"";
	if (_clubNewsFeedCellType == HONClubNewsFeedCellTypePhotoSubmission) {
		_photoVO = (HONClubPhotoVO *)[_clubVO.submissions lastObject];
		for (NSString *subject in _photoVO.subjectNames) {
			emotions = [emotions stringByAppendingFormat:@"%@, ", subject];
		}
		
		if ([emotions length] > 0)
			emotions = [emotions substringToIndex:[emotions length] - 2];
	}
	
	NSString *titleCaption = (_clubNewsFeedCellType == HONClubNewsFeedCellTypePhotoSubmission) ? [NSString stringWithFormat:@"%@ is feeling %@", _photoVO.username, emotions] : _clubVO.clubName;
	NSString *avatarPrefix = (_clubNewsFeedCellType == HONClubNewsFeedCellTypePhotoSubmission) ? _photoVO.imagePrefix : _clubVO.coverImagePrefix;
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:(_clubNewsFeedCellType == HONClubNewsFeedCellTypePhotoSubmission) ? CGRectMake(13.0, 19.0, 32.0, 32.0) : CGRectMake(10.0, 10.0, 44.0, 44.0)];
	avatarImageView.alpha = 0.0;
	[self.contentView addSubview:avatarImageView];
	
	UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	avatarButton.frame = avatarImageView.frame;
	[avatarButton addTarget:self action:@selector(_goUserProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:avatarButton];
	
	[HONImagingDepictor maskImageView:avatarImageView withMask:[UIImage imageNamed:(_clubNewsFeedCellType == HONClubNewsFeedCellTypePhotoSubmission) ? @"avatarMask" : @"thumbMask"]];
	
	void (^avatarImageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		avatarImageView.image = image;
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^avatarImageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[HONAppDelegate cleanImagePrefixURL:request.URL.absoluteString] forBucketType:(_clubNewsFeedCellType == HONClubNewsFeedCellTypePhotoSubmission) ? HONS3BucketTypeAvatars : HONS3BucketTypeClubs completion:nil];
		
		avatarImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapThumbSize];
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[avatarPrefix stringByAppendingString:kSnapThumbSuffix]]
															 cachePolicy:kURLRequestCachePolicy
														 timeoutInterval:[HONAppDelegate timeoutInterval]]
						   placeholderImage:nil
									success:avatarImageSuccessBlock
									failure:avatarImageFailureBlock];
	
	CGSize maxSize = CGSizeMake(238.0, 38.0);
	CGSize size = [titleCaption boundingRectWithSize:maxSize
											 options:NSStringDrawingTruncatesLastVisibleLine
										  attributes:@{NSFontAttributeName:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16]}
											 context:nil].size;
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:(_clubNewsFeedCellType == HONClubNewsFeedCellTypePhotoSubmission) ? CGRectMake(59.0, 14.0, maxSize.width, 22.0 + ((int)(size.width > maxSize.width) * 25.0)) : CGRectMake(75.0, 22.0, 238.0, 20.0)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = (_clubNewsFeedCellType == HONClubNewsFeedCellTypePhotoSubmission) ? [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16] : [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.numberOfLines = 1 + ((int)(size.width > maxSize.width));
	titleLabel.text = [titleCaption stringByReplacingOccurrencesOfString:@" ," withString:@","];
	[self.contentView addSubview:titleLabel];
	
	if (_clubNewsFeedCellType == HONClubNewsFeedCellTypePhotoSubmission) {
		NSMutableParagraphStyle *paragraphStyle  = [[NSMutableParagraphStyle alloc] init];
		paragraphStyle.minimumLineHeight = 22.0;
		paragraphStyle.maximumLineHeight = paragraphStyle.minimumLineHeight;
		
		titleLabel.text = @"";
		titleLabel.attributedText = [[NSAttributedString alloc] initWithString:titleCaption attributes:@{NSParagraphStyleAttributeName	: paragraphStyle}];
		
	} else {
		if (_clubVO.clubEnrollmentType == HONClubEnrollmentTypePending) {
			titleLabel.frame = CGRectOffset(titleLabel.frame, 0.0, -12.0);
			
			UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 30.0, 180.0, 16.0)];
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
					size = [caption boundingRectWithSize:subtitleLabel.frame.size
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
		}
	}
	
	UIButton *createClubButton = [UIButton buttonWithType:UIButtonTypeCustom];
	createClubButton.frame = CGRectMake(247.0, 0.0, 64.0, 64.0);
	[createClubButton setBackgroundImage:[UIImage imageNamed:@"plusClubButton_nonActive"] forState:UIControlStateNormal];
	[createClubButton setBackgroundImage:[UIImage imageNamed:@"plusClubButton_Active"] forState:UIControlStateHighlighted];
	[createClubButton addTarget:self action:(_clubVO.clubEnrollmentType == HONClubEnrollmentTypeAutoGen) ? @selector(_goCreateClub) : @selector(_goJoinClub) forControlEvents:UIControlEventTouchUpInside];
	createClubButton.hidden = (_clubNewsFeedCellType == HONClubNewsFeedCellTypePhotoSubmission);
	[self.contentView addSubview:createClubButton];
	
	
	if (_clubNewsFeedCellType == HONClubNewsFeedCellTypePhotoSubmission) {
		[titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:16] range:[titleCaption rangeOfString:_photoVO.username]];
		
		UIButton *usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
		usernameButton.frame = [titleLabel boundingRectForCharacterRange:[titleCaption rangeOfString:_photoVO.username]];
		[usernameButton addTarget:self action:@selector(_goUserProfile) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:usernameButton];
		
		NSString *timeCaption = [NSString stringWithFormat:@"%@ in %@", [[HONDateTimeAlloter sharedInstance] intervalSinceDate:_clubVO.updatedDate], _clubVO.clubName];
		_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 68.0 - ((int)(size.width < maxSize.width) * 25.0), 238.0, 16.0)];
		_timeLabel.backgroundColor = [UIColor clearColor];
		_timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
		_timeLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		_timeLabel.text = timeCaption;
		[_timeLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:12] range:[timeCaption rangeOfString:_clubVO.clubName]];
		[self.contentView addSubview:_timeLabel];
		
		int row = 0;
		int col = 0;
		int tot = 0;
		for (HONEmotionVO *emotionVO in [[HONClubAssistant sharedInstance] emotionsForClubPhoto:_photoVO]) {
			
			row = (tot / 5);
			col = (tot % 5);
			UIImageView *emotionImageView = [self _imageViewForEmotion:emotionVO];
			emotionImageView.frame = CGRectOffset(emotionImageView.frame, 59.0 + (col * 52), (row * 50) + 73.0 + ((int)(size.width > maxSize.width) * 25.0));
			[self.contentView addSubview:emotionImageView];
			if (++tot == 15)
				break;
		}
		
		UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		likeButton.frame = CGRectMake(54.0, 66.0 + ((int)(size.width > maxSize.width) * 25.0) + ((row + 1) * 50.0), 124.0, 64.0);
		[likeButton setBackgroundImage:[UIImage imageNamed:@"newsLikeButton_nonActive"] forState:UIControlStateNormal];
		[likeButton setBackgroundImage:[UIImage imageNamed:@"newsLikeButton_Active"] forState:UIControlStateHighlighted];
		[likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:likeButton];
		
		UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
		replyButton.frame = CGRectMake(184.0, likeButton.frame.origin.y, 124.0, 64.0);
		[replyButton setBackgroundImage:[UIImage imageNamed:@"newsReplyButton_nonActive"] forState:UIControlStateNormal];
		[replyButton setBackgroundImage:[UIImage imageNamed:@"newsReplyButton_Active"] forState:UIControlStateHighlighted];
		[replyButton addTarget:self action:@selector(_goReply) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:replyButton];
	}
}


#pragma mark - Navigation
- (void)_goCreateClub {
	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:createClubWithProtoVO:)])
		[self.delegate clubNewsFeedViewCell:self createClubWithProtoVO:_clubVO];
}

- (void)_goUserProfile {
	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:showUserProfileForClubPhoto:)])
		[self.delegate clubNewsFeedViewCell:self showUserProfileForClubPhoto:_photoVO];
}

- (void)_goJoinClub {
	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:joinClub:)])
		[self.delegate clubNewsFeedViewCell:self joinClub:_clubVO];
}

- (void)_goLike {
	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:upvoteClubPhoto:)])
		[self.delegate clubNewsFeedViewCell:self upvoteClubPhoto:_clubVO];
}

- (void)_goReply {
	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:replyToClubPhoto:)])
		[self.delegate clubNewsFeedViewCell:self replyToClubPhoto:_clubVO];
}


#pragma mark - UI Presentation
static const CGSize kPhotoSize = {114.0f, 114.0f};

- (UIView *)_photoStackView {
	HONClubPhotoVO *clubPhotoVO = (HONClubPhotoVO *)[[_clubVO submissions] lastObject];
	
	NSMutableArray *emotionURLs = [NSMutableArray array];
	UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kPhotoSize.width, kPhotoSize.height)];
	
	for (HONEmotionVO *vo in [[HONClubAssistant sharedInstance] emotionsForClubPhoto:clubPhotoVO]) {
		//NSLog(@"EMOTION:[%d - %@]", vo.emotionID, vo.emotionName);
		[emotionURLs addObject:vo.largeImageURL];
		
		if ([emotionURLs count] >= 2)
			break;
	}
	
	CGFloat width = kPhotoSize.width + ([emotionURLs count] * 65.0);
//	holderView.frame = CGRectMake(59.0 + ((261.0 - width) * 0.5), 0.0, width, kPhotoSize.height);
	holderView.frame = CGRectMake(59.0, 0.0, width, kPhotoSize.height);
	
	
	UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kPhotoSize.width, kPhotoSize.height)];
	[holderView addSubview:photoImageView];
	[HONImagingDepictor maskImageView:photoImageView withMask:[UIImage imageNamed:@"timelinePhotoMask"]];
	
	void (^photoSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		photoImageView.image = image;
	};
	
	void (^photoFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[HONAppDelegate cleanImagePrefixURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeClubs completion:nil];
		photoImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapMediumSize];
	};
	
	[photoImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[clubPhotoVO.imagePrefix stringByAppendingString:kSnapMediumSuffix]]
															cachePolicy:kURLRequestCachePolicy
														timeoutInterval:[HONAppDelegate timeoutInterval]]
						  placeholderImage:nil
								   success:photoSuccessBlock
								   failure:photoFailureBlock];
	
	
	int ind = 1;
	for (NSString *url in emotionURLs) {
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0 + (ind * 65.0), 0.0, kPhotoSize.width, kPhotoSize.height)];
		[holderView addSubview:imageView];
		
		[HONImagingDepictor maskImageView:imageView withMask:[UIImage imageNamed:@"timelinePhotoMask"]];
		
		void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			imageView.image = image;
		};
		
		void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			//[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[HONAppDelegate cleanImagePrefixURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeClubs completion:nil];
			imageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapMediumSize];
		};
		
		[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]
														   cachePolicy:NSURLRequestReturnCacheDataElseLoad
													   timeoutInterval:[HONAppDelegate timeoutInterval]]
						 placeholderImage:nil
								  success:successBlock
								  failure:failureBlock];

		ind++;
	}

	
	[holderView reverseSubviews];
	return (holderView);
}


- (UIImageView *)_imageViewForEmotion:(HONEmotionVO *)emotionVO {
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 40.0)];
	[imageView setTag:emotionVO.emotionID];
	imageView.alpha = 0.0;
	
	[HONImagingDepictor maskImageView:imageView withMask:[UIImage imageNamed:@"emoticonMask"]];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		imageView.image = image;
		
		[UIView animateWithDuration:0.33 delay:0.0
			 usingSpringWithDamping:0.875 initialSpringVelocity:0.5
							options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent
		 
						 animations:^(void) {
							 imageView.alpha = 1.0;
						 } completion:^(BOOL finished) {
						 }];
	};
	
	[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:emotionVO.largeImageURL]
													   cachePolicy:NSURLRequestReturnCacheDataElseLoad
												   timeoutInterval:[HONAppDelegate timeoutInterval]]
					 placeholderImage:nil
							  success:imageSuccessBlock
							  failure:nil];
	
	return (imageView);
}

@end
