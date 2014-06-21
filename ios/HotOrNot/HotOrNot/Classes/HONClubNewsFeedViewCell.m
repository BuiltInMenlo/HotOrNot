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

#import "HONClubNewsFeedViewCell.h"
#import "HONClubPhotoVO.h"

@interface HONClubNewsFeedViewCell ()
@property (nonatomic, strong) HONClubPhotoVO *photoVO;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic) HONClubNewsFeedCellType clubNewsFeedCellType;
@end

@implementation HONClubNewsFeedViewCell
@synthesize timelineItemVO = _timelineItemVO;
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
	
	_clubNewsFeedCellType = (_clubVO.clubEnrollmentType == HONClubEnrollmentTypeMember) ? HONClubNewsFeedCellTypeMember : HONClubNewsFeedCellTypeNonMember;
	self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) ? @"newsCellBG_normal" : @"viewCellBG_normal"]];
	
	NSString *emotions = @"";
	if (_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) {
		_photoVO = (HONClubPhotoVO *)[_clubVO.submissions lastObject];
		for (NSString *subject in _photoVO.subjectNames) {
			emotions = [emotions stringByAppendingFormat:@"%@, ", subject];
		}
		
		if ([emotions length] > 0)
			emotions = [emotions substringToIndex:[emotions length] - 2];
	}
	
	NSString *titleCaption = (_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) ? [NSString stringWithFormat:@"%@ is feeling %@", _photoVO.username, emotions] : _clubVO.clubName;
	NSString *avatarPrefix = (_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) ? _photoVO.avatarPrefix : _clubVO.coverImagePrefix;
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:(_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) ? CGRectMake(13.0, 19.0, 32.0, 32.0) : CGRectMake(10.0, 10.0, 44.0, 44.0)];
	avatarImageView.alpha = 0.0;
	[self.contentView addSubview:avatarImageView];
	
	UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	avatarButton.frame = avatarImageView.frame;
	[avatarButton addTarget:self action:@selector(_goUserProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:avatarButton];
	
	[HONImagingDepictor maskImageView:avatarImageView withMask:[UIImage imageNamed:(_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) ? @"avatarMask" : @"thumbMask"]];
	
	void (^avatarImageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		avatarImageView.image = image;
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^avatarImageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:avatarPrefix forBucketType:(_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) ? HONS3BucketTypeAvatars : HONS3BucketTypeClubs completion:nil];
		
		avatarImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapThumbSize];
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[avatarPrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						   placeholderImage:nil
									success:avatarImageSuccessBlock
									failure:avatarImageFailureBlock];
	
	CGSize maxSize = CGSizeMake(238.0, 38.0);
	CGSize size = [titleCaption boundingRectWithSize:maxSize
											 options:NSStringDrawingTruncatesLastVisibleLine
										  attributes:@{NSFontAttributeName:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16]}
											 context:nil].size;
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:(_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) ? CGRectMake(59.0, 14.0, maxSize.width, 22.0 + ((int)(size.width > maxSize.width) * 25.0)) : CGRectMake(75.0, 22.0, 238.0, 20.0)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = (_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) ? [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16] : [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.numberOfLines = 1 + ((int)(size.width > maxSize.width));
	titleLabel.text = titleCaption;
	[self.contentView addSubview:titleLabel];
	
	if (_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) {
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
			
			int cnt = 0;
			NSString *subtitleCaption = @"";
			for (HONClubPhotoVO *vo in [[_clubVO.submissions reverseObjectEnumerator] allObjects]) {
				NSString *caption = [subtitleCaption stringByAppendingFormat:@"%@, & %d more", vo.username, ([_clubVO.submissions count] - cnt)];
				size = [caption boundingRectWithSize:subtitleLabel.frame.size
											 options:NSStringDrawingTruncatesLastVisibleLine
										  attributes:@{NSFontAttributeName:subtitleLabel.font}
											 context:nil].size;
				
				if (size.width >= subtitleLabel.frame.size.width)
					break;
				
				subtitleCaption = [subtitleCaption stringByAppendingFormat:@"%@, ", vo.username];
				cnt++;
			}
			
			subtitleCaption = [subtitleCaption substringToIndex:[subtitleCaption length] - 2];
			int remaining = [_clubVO.submissions count] - cnt;
			
			if (remaining > 0)
				subtitleCaption = [subtitleCaption stringByAppendingFormat:@", & %d more", remaining];
			
			subtitleLabel.text = subtitleCaption;
		}
	}
	
	UIButton *createClubButton = [UIButton buttonWithType:UIButtonTypeCustom];
	createClubButton.frame = CGRectMake(247.0, 0.0, 64.0, 64.0);
	[createClubButton setBackgroundImage:[UIImage imageNamed:@"plusClubButton_nonActive"] forState:UIControlStateNormal];
	[createClubButton setBackgroundImage:[UIImage imageNamed:@"plusClubButton_Active"] forState:UIControlStateHighlighted];
	[createClubButton addTarget:self action:(_clubVO.clubEnrollmentType == HONClubEnrollmentTypeAutoGen) ? @selector(_goCreateClub) : @selector(_goJoinClub) forControlEvents:UIControlEventTouchUpInside];
	createClubButton.hidden = (_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember);
	[self.contentView addSubview:createClubButton];
	
	
	if (_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) {
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
		
		UIView *photoStackView = [self _photoStackView];
		photoStackView.frame = CGRectOffset(photoStackView.frame, 0.0, 103.0 - ((int)(size.width < maxSize.width) * 9.0));
		[self.contentView addSubview:photoStackView];
		
		UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		likeButton.frame = CGRectMake(54.0, 227.0, 124.0, 64.0);
		[likeButton setBackgroundImage:[UIImage imageNamed:@"newsLikeButton_nonActive"] forState:UIControlStateNormal];
		[likeButton setBackgroundImage:[UIImage imageNamed:@"newsLikeButton_Active"] forState:UIControlStateHighlighted];
		[likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:likeButton];
		
		UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
		replyButton.frame = CGRectMake(184.0, 227.0, 124.0, 64.0);
		[replyButton setBackgroundImage:[UIImage imageNamed:@"newsReplyButton_nonActive"] forState:UIControlStateNormal];
		[replyButton setBackgroundImage:[UIImage imageNamed:@"newsReplyButton_Active"] forState:UIControlStateHighlighted];
		[replyButton addTarget:self action:@selector(_goReply) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:replyButton];
	}
}

- (void)setTimelineItemVO:(HONTimelineItemVO *)timelineItemVO {
	_timelineItemVO = timelineItemVO;
	
	_clubNewsFeedCellType = (_timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreated && _timelineItemVO.userClubVO.clubEnrollmentType == HONClubEnrollmentTypeMember) ? HONClubNewsFeedCellTypeMember : HONClubNewsFeedCellTypeNonMember;
	self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) ? @"newsCellBG_normal" : @"viewCellBG_normal"]];
	
	NSString *emotions = @"";
	if (_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) {
		for (NSString *subject in _timelineItemVO.clubPhotoVO.subjectNames) {
			emotions = [emotions stringByAppendingFormat:@"%@, ", subject];
		}
	
		if ([emotions length] > 0)
			emotions = [emotions substringToIndex:[emotions length] - 2];
	}
	
	NSString *titleCaption = (_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) ? [NSString stringWithFormat:@"%@ is feeling %@", _timelineItemVO.clubPhotoVO.username, emotions] : _timelineItemVO.userClubVO.clubName;
	NSString *avatarPrefix = (_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) ? _timelineItemVO.clubPhotoVO.avatarPrefix : _timelineItemVO.userClubVO.coverImagePrefix;
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:(_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) ? CGRectMake(13.0, 19.0, 32.0, 32.0) : CGRectMake(10.0, 10.0, 44.0, 44.0)];
	avatarImageView.alpha = 0.0;
	[self.contentView addSubview:avatarImageView];
	
	UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	avatarButton.frame = avatarImageView.frame;
	[avatarButton addTarget:self action:@selector(_goUserProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:avatarButton];
	
	[HONImagingDepictor maskImageView:avatarImageView withMask:[UIImage imageNamed:(_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) ? @"avatarMask" : @"thumbMask"]];
	
	void (^avatarImageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		avatarImageView.image = image;
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^avatarImageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:avatarPrefix forBucketType:(_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) ? HONS3BucketTypeAvatars : HONS3BucketTypeClubs completion:nil];
		
		avatarImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapThumbSize];
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[avatarPrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						   placeholderImage:nil
									success:avatarImageSuccessBlock
									failure:avatarImageFailureBlock];
	
	CGSize maxSize = CGSizeMake(238.0, 38.0);
	CGSize size = [titleCaption boundingRectWithSize:maxSize
											 options:NSStringDrawingTruncatesLastVisibleLine
										  attributes:@{NSFontAttributeName:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16]}
											 context:nil].size;
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:(_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) ? CGRectMake(59.0, 14.0, maxSize.width, 22.0 + ((int)(size.width > maxSize.width) * 25.0)) : CGRectMake(75.0, 22.0, 238.0, 20.0)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = (_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) ? [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16] : [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.numberOfLines = 1 + ((int)(size.width > maxSize.width));
	titleLabel.text = titleCaption;
	[self.contentView addSubview:titleLabel];
	
	if (_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) {
		NSMutableParagraphStyle *paragraphStyle  = [[NSMutableParagraphStyle alloc] init];
		paragraphStyle.minimumLineHeight = 22.0;
		paragraphStyle.maximumLineHeight = paragraphStyle.minimumLineHeight;
		
		titleLabel.text = @"";
		titleLabel.attributedText = [[NSAttributedString alloc] initWithString:titleCaption attributes:@{NSParagraphStyleAttributeName	: paragraphStyle}];
	
	} else {
		if (_timelineItemVO.userClubVO.clubEnrollmentType == HONClubEnrollmentTypePending) {
			titleLabel.frame = CGRectOffset(titleLabel.frame, 0.0, -12.0);
			
			UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 30.0, 180.0, 16.0)];
			subtitleLabel.backgroundColor = [UIColor clearColor];
			subtitleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
			subtitleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
			[self.contentView addSubview:subtitleLabel];
			
			int cnt = 0;
			NSString *subtitleCaption = @"";
			for (HONClubPhotoVO *vo in [[_timelineItemVO.userClubVO.submissions reverseObjectEnumerator] allObjects]) {
				NSString *caption = [subtitleCaption stringByAppendingFormat:@"%@, & %d more", vo.username, ([_timelineItemVO.userClubVO.submissions count] - cnt)];
				size = [caption boundingRectWithSize:subtitleLabel.frame.size
											 options:NSStringDrawingTruncatesLastVisibleLine
										  attributes:@{NSFontAttributeName:subtitleLabel.font}
											 context:nil].size;
				
				if (size.width >= subtitleLabel.frame.size.width)
					break;
				
				subtitleCaption = [subtitleCaption stringByAppendingFormat:@"%@, ", vo.username];
				cnt++;
			}
			
			subtitleCaption = [subtitleCaption substringToIndex:[subtitleCaption length] - 2];
			int remaining = [_timelineItemVO.userClubVO.submissions count] - cnt;
			
			if (remaining > 0)
				subtitleCaption = [subtitleCaption stringByAppendingFormat:@", & %d more", remaining];
			
			subtitleLabel.text = subtitleCaption;
		}
	}
	
	UIButton *createClubButton = [UIButton buttonWithType:UIButtonTypeCustom];
	createClubButton.frame = CGRectMake(247.0, 0.0, 64.0, 64.0);
	[createClubButton setBackgroundImage:[UIImage imageNamed:@"plusClubButton_nonActive"] forState:UIControlStateNormal];
	[createClubButton setBackgroundImage:[UIImage imageNamed:@"plusClubButton_Active"] forState:UIControlStateHighlighted];
	[createClubButton addTarget:self action:(_timelineItemVO.userClubVO.clubEnrollmentType == HONClubEnrollmentTypeAutoGen) ? @selector(_goCreateClub) : @selector(_goJoinClub) forControlEvents:UIControlEventTouchUpInside];
	createClubButton.hidden = (_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember);
	[self.contentView addSubview:createClubButton];
	
	
	if (_clubNewsFeedCellType == HONClubNewsFeedCellTypeMember) {
		[titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:16] range:[titleCaption rangeOfString:_timelineItemVO.clubPhotoVO.username]];
		
		
//		NSLog(@"LABEL:[%@] BOUNDS:[%@]", NSStringFromCGRect(titleLabel.frame), NSStringFromCGRect([titleLabel boundingRectForCharacterRange:[titleCaption rangeOfString:_timelineItemVO.clubPhotoVO.username]]));
		
		UIButton *usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
		usernameButton.frame = [titleLabel boundingRectForCharacterRange:[titleCaption rangeOfString:_timelineItemVO.clubPhotoVO.username]];
		[usernameButton addTarget:self action:@selector(_goUserProfile) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:usernameButton];
		
		NSString *timeCaption = [NSString stringWithFormat:@"%@ in %@", [[HONDateTimeAlloter sharedInstance] intervalSinceDate:_timelineItemVO.userClubVO.updatedDate], _timelineItemVO.userClubVO.clubName];
		_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 68.0 - ((int)(size.width < maxSize.width) * 25.0), 238.0, 16.0)];
		_timeLabel.backgroundColor = [UIColor clearColor];
		_timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
		_timeLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		_timeLabel.text = timeCaption;
		[_timeLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:12] range:[timeCaption rangeOfString:_timelineItemVO.userClubVO.clubName]];
		[self.contentView addSubview:_timeLabel];
		
		UIView *photoStackView = [self _photoStackView];
		photoStackView.frame = CGRectOffset(photoStackView.frame, 0.0, 103.0 - ((int)(size.width < maxSize.width) * 9.0));
		[self.contentView addSubview:photoStackView];

		UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		likeButton.frame = CGRectMake(54.0, 227.0, 124.0, 64.0);
		[likeButton setBackgroundImage:[UIImage imageNamed:@"newsLikeButton_nonActive"] forState:UIControlStateNormal];
		[likeButton setBackgroundImage:[UIImage imageNamed:@"newsLikeButton_Active"] forState:UIControlStateHighlighted];
		[likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:likeButton];
		
		UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
		replyButton.frame = CGRectMake(184.0, 227.0, 124.0, 64.0);
		[replyButton setBackgroundImage:[UIImage imageNamed:@"newsReplyButton_nonActive"] forState:UIControlStateNormal];
		[replyButton setBackgroundImage:[UIImage imageNamed:@"newsReplyButton_Active"] forState:UIControlStateHighlighted];
		[replyButton addTarget:self action:@selector(_goReply) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:replyButton];
	}
}


#pragma mark - Navigation
- (void)_goCreateClub {
	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:createClubWithProtoVO:)])
		[self.delegate clubNewsFeedViewCell:self createClubWithProtoVO:_timelineItemVO.userClubVO];
}

- (void)_goUserProfile {
	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:showUserProfileForClubPhoto:)])
		[self.delegate clubNewsFeedViewCell:self showUserProfileForClubPhoto:_timelineItemVO.clubPhotoVO];
}

- (void)_goJoinClub {
	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:joinClub:)])
		[self.delegate clubNewsFeedViewCell:self joinClub:_timelineItemVO.userClubVO];
}

- (void)_goLike {
	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:upvoteClubPhoto:)])
		[self.delegate clubNewsFeedViewCell:self upvoteClubPhoto:_timelineItemVO.userClubVO];
}

- (void)_goReply {
	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:replyToClubPhoto:)])
		[self.delegate clubNewsFeedViewCell:self replyToClubPhoto:_timelineItemVO.userClubVO];
}


#pragma mark - UI Presentation
static const CGSize kPhotoSize = {114.0f, 114.0f};

- (UIView *)_photoStackView {
	NSArray *clubPhotos = _timelineItemVO.userClubVO.submissions;
	
	
	NSMutableArray *submissionPrefixes = [NSMutableArray arrayWithObject:((HONClubPhotoVO *)[clubPhotos lastObject]).imagePrefix];
	UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kPhotoSize.width, kPhotoSize.height)];
	
	if ([clubPhotos count] == 2)
		[submissionPrefixes addObject:((HONClubPhotoVO *)[clubPhotos firstObject]).imagePrefix];
	
	if ([clubPhotos count] > 2) {
		[submissionPrefixes addObject:((HONClubPhotoVO *)[clubPhotos objectAtIndex:[clubPhotos count] - 2]).imagePrefix];
		[submissionPrefixes addObject:((HONClubPhotoVO *)[clubPhotos firstObject]).imagePrefix];
	}
	
	CGFloat width = kPhotoSize.width + (([submissionPrefixes count] - 1) * 65.0);
	holderView.frame = CGRectMake(51.0 + ((260.0 - width) * 0.5), 0.0, width, kPhotoSize.height);
	
	for (int i=[submissionPrefixes count]-1; i>=0; i--) {
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0 + (i * 65.0), 0.0, kPhotoSize.width, kPhotoSize.height)];
		[holderView addSubview:avatarImageView];
		
		void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			avatarImageView.image = image;
			[HONImagingDepictor maskImageView:avatarImageView withMask:[UIImage imageNamed:@"timelinePhotoMask"]];
		};
		
		void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			//[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:_challengeVO.creatorVO.avatarPrefix forBucketType:HONS3BucketTypeAvatars completion:nil];
			avatarImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapMediumSize];
		};
		
		[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[submissionPrefixes objectAtIndex:i] stringByAppendingString:kSnapMediumSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							   placeholderImage:nil
										success:successBlock
										failure:failureBlock];
	}
	
	return (holderView);
}


@end
