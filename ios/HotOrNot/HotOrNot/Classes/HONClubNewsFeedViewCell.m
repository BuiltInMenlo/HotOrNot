//
//  HONClubNewsFeedViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/25/2014 @ 11:00 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "UILabel+FormattedText.h"

#import "HONClubNewsFeedViewCell.h"
#import "HONClubPhotoVO.h"

@interface HONClubNewsFeedViewCell ()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic) BOOL *isCreateClubCell;
@end

@implementation HONClubNewsFeedViewCell
@synthesize timelineItemVO = _timelineItemVO;
@synthesize cellType = _cellType;
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

//- (void)setFrame:(CGRect)frame {
//	frame.size.height -= 10.0;
//	[super setFrame:frame];
//}


#pragma mark - Public APIs
- (void)setCellType:(HONClubNewsFeedCellType)cellType {
	_cellType = cellType;
}

- (void)setTimelineItemVO:(HONTimelineItemVO *)timelineItemVO {
	_timelineItemVO = timelineItemVO;
	self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(_timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreated) ? @"newsCellBG_normal" : @"viewCellBG_normal"]];
	
	NSString *emotions = @"";
	if (_timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreated) {
		for (NSString *subject in _timelineItemVO.clubPhotoVO.subjectNames) {
			emotions = [emotions stringByAppendingFormat:@"%@, ", subject];
		}
	
	if ([emotions length] > 0)
		emotions = [emotions substringToIndex:[emotions length] - 2];
	}
	
	NSString *titleCaption = (_timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreated) ? [NSString stringWithFormat:@"%@ is feeling %@", _timelineItemVO.clubPhotoVO.username, emotions] : _timelineItemVO.userClubVO.clubName;
	NSString *avatarPrefix = (_timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreated) ? _timelineItemVO.clubPhotoVO.avatarPrefix : _timelineItemVO.userClubVO.coverImagePrefix;
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:(_timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreated) ? CGRectMake(13.0, 19.0, 32.0, 32.0) : CGRectMake(7.0, 0.0, 64.0, 64.0)];
	avatarImageView.alpha = 0.0;
	[self.contentView addSubview:avatarImageView];
	
	[HONImagingDepictor maskImageView:avatarImageView withMask:[UIImage imageNamed:(_timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreated) ? @"avatarMask" : @"thumbMask"]];
	
	void (^avatarImageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		avatarImageView.image = image;
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^avatarImageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:avatarPrefix forBucketType:(_timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreated) ? HONS3BucketTypeAvatars : HONS3BucketTypeClubs completion:nil];
		
		avatarImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapThumbSize];
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[avatarPrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						   placeholderImage:nil
									success:avatarImageSuccessBlock
									failure:avatarImageFailureBlock];
	
	CGSize size = [titleCaption boundingRectWithSize:CGSizeMake(238.0, 37.0)
											 options:NSStringDrawingTruncatesLastVisibleLine
										  attributes:@{NSFontAttributeName:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16]}
											 context:nil].size;
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:(_timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreated) ? CGRectMake(59.0, 16.0, 238.0, 38.0) : CGRectMake(75.0, 22.0, 238.0, 20.0)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:(_timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreated) ? 16 : 14];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.numberOfLines = 2;
	titleLabel.text = titleCaption;
	[self.contentView addSubview:titleLabel];
	
	UIButton *createClubButton = [UIButton buttonWithType:UIButtonTypeCustom];
	createClubButton.frame = CGRectMake(247.0, 0.0, 64.0, 64.0);
	[createClubButton setBackgroundImage:[UIImage imageNamed:@"plusClubButton_nonActive"] forState:UIControlStateNormal];
	[createClubButton setBackgroundImage:[UIImage imageNamed:@"plusClubButton_Active"] forState:UIControlStateHighlighted];
	[createClubButton addTarget:self action:@selector(_goCreateClub) forControlEvents:UIControlEventTouchUpInside];
	createClubButton.hidden = (_timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreated || _timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreatedEmpty);
	[self.contentView addSubview:createClubButton];
	
	
	if (_timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreated) {
		[titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:16] range:NSMakeRange(0, [_timelineItemVO.clubPhotoVO.username length] + 1)];
		
		NSString *timeCaption = [NSString stringWithFormat:@"%@ in %@", [[HONDateTimeAlloter sharedInstance] intervalSinceDate:_timelineItemVO.userClubVO.updatedDate], _timelineItemVO.userClubVO.clubName];
		UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 65.0 - ((int)(size.width < 238.0) * 18.0), 238.0, 16.0)];
		timeLabel.backgroundColor = [UIColor clearColor];
		timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
		timeLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		timeLabel.text = timeCaption;
		[timeLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:12] range:[timeCaption rangeOfString:_timelineItemVO.userClubVO.clubName]];
		[self.contentView addSubview:timeLabel];
		
		UIView *photoStackView = [self _photoStackView];
		photoStackView.frame = CGRectOffset(photoStackView.frame, 0.0, 103.0 - ((int)(size.width < 238.0) * 9.0));
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
	holderView.frame = CGRectMake(51.0 + ((269.0 - width) * 0.5), 0.0, width, kPhotoSize.height);
	
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
