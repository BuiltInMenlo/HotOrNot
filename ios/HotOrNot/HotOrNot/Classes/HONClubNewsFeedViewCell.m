//
//  HONClubNewsFeedViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/25/2014 @ 11:00 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONClubNewsFeedViewCell.h"


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
	
//	if (_cellType == HONClubNewsFeedCellTypeCreateClub) {
//		UIButton *createClubButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		createClubButton.frame = CGRectMake(0.0, 0.0, 320.0, 46.0);
//		[createClubButton setBackgroundImage:[UIImage imageNamed:@"createClubButton_nonActive"] forState:UIControlStateNormal];
//		[createClubButton setBackgroundImage:[UIImage imageNamed:@"createClubButton_Active"] forState:UIControlStateHighlighted];
//		[createClubButton addTarget:self action:@selector(_goCreateClub) forControlEvents:UIControlEventTouchUpInside];
//		[self.contentView addSubview:createClubButton];
//	
//	} else if (_cellType == HONClubNewsFeedCellTypeConfirmClubs) {
//		UIButton *confirmClubsButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		confirmClubsButton.frame = CGRectMake(0.0, 0.0, 320.0, 46.0);
//		[confirmClubsButton setBackgroundImage:[UIImage imageNamed:@"confirmClubsButton_nonActive"] forState:UIControlStateNormal];
//		[confirmClubsButton setBackgroundImage:[UIImage imageNamed:@"confirmClubsButton_Active"] forState:UIControlStateHighlighted];
//		[confirmClubsButton addTarget:self action:@selector(_goCreateClub) forControlEvents:UIControlEventTouchUpInside];
//		[self.contentView addSubview:confirmClubsButton];
//	}
}

- (void)setTimelineItemVO:(HONTimelineItemVO *)timelineItemVO {
	_timelineItemVO = timelineItemVO;
//	self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(_timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) ? @"selfieRowBG" : @"nonSelfieRowBG"]];
	
	NSString *titleCaption = (_timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreated) ? [NSString stringWithFormat:@"%@ is feeling%@", _timelineItemVO.opponentVO.username, (_timelineItemVO.emotionVO != nil) ? [@" " stringByAppendingString:_timelineItemVO.emotionVO.emotionName] : @"…"] : _timelineItemVO.userClubVO.clubName;
	NSString *subtitleCaption = (_timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreated) ? [NSString stringWithFormat:@"%@ in %@", [HONAppDelegate timeSinceDate:_timelineItemVO.timestamp], _timelineItemVO.opponentVO.subjectName] : [NSString stringWithFormat:@"%@%d member%@", (_timelineItemVO.timelineItemType == HONTimelineItemTypeNearby) ? @"Nearby club, " : (_timelineItemVO.timelineItemType == HONTimelineItemTypeNearby) ? @"Suggested club, " : @"", _timelineItemVO.userClubVO.totalActiveMembers, ( _timelineItemVO.userClubVO.totalActiveMembers != 1) ? @"s" : @""];
	NSString *avatarPrefix = (_timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreated) ? _timelineItemVO.opponentVO.avatarPrefix : _timelineItemVO.userClubVO.coverImagePrefix;
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:(_timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreated) ? CGRectMake(15.0, 9.0, 48.0, 48.0) : CGRectMake(15.0, 9.0, 48.0, 48.0)];
	avatarImageView.alpha = 0.0;
	[self.contentView addSubview:avatarImageView];
	
	[HONImagingDepictor maskImageView:avatarImageView withMask:[UIImage imageNamed:@"avatarMask"]];
	
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
	
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:(_timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreated) ? CGRectMake(70.0, 15.0, 180.0, 17.0) : CGRectMake(70.0, 15.0, 180.0, 17.0)];//CGRectMake((_timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) ? 63.0 : 74.0, (_timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) ? 10.0 : 47.0, 200.0, 18.0)];
	titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:13];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = titleCaption;
	[self.contentView addSubview:titleLabel];
	
	UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y + 18.0, titleLabel.frame.size.width, 15.0)];
	subtitleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
	subtitleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	subtitleLabel.backgroundColor = [UIColor clearColor];
	subtitleLabel.text = subtitleCaption;
	[self.contentView addSubview:subtitleLabel];
	
	UIButton *createClubButton = [UIButton buttonWithType:UIButtonTypeCustom];
	createClubButton.frame = CGRectMake(257.0, 10.0, 44.0, 44.0);
	[createClubButton setBackgroundImage:[UIImage imageNamed:@"plusButton_nonActive"] forState:UIControlStateNormal];
	[createClubButton setBackgroundImage:[UIImage imageNamed:@"plusButton_Active"] forState:UIControlStateHighlighted];
	[createClubButton addTarget:self action:@selector(_goCreateClub) forControlEvents:UIControlEventTouchUpInside];
	createClubButton.hidden = (_timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreated);
	[self.contentView addSubview:createClubButton];

	
//	if (_timelineItemVO.timelineItemType != HONTimelineItemTypeSelfie) {
//		UILabel *topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 6.0, 200.0, 16.0)];
//		topicLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
//		topicLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
//		topicLabel.backgroundColor = [UIColor clearColor];
//		topicLabel.text = (_timelineItemVO.timelineItemType != HONTimelineItemTypeNearby) ? @"Nearby club" : @"Club Invite";
//		[self.contentView addSubview:topicLabel];
//		
//		UIButton *joinClubButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		joinClubButton.frame = CGRectMake(212.0, 42.0, 84.0, 44.0);
//		[joinClubButton setBackgroundImage:[UIImage imageNamed:@"joinClubButton_nonActive"] forState:UIControlStateNormal];
//		[joinClubButton setBackgroundImage:[UIImage imageNamed:@"joinClubButton_Active"] forState:UIControlStateHighlighted];
//		[joinClubButton addTarget:self action:@selector(_goJoinClub) forControlEvents:UIControlEventTouchUpInside];
//		[self.contentView addSubview:joinClubButton];
//	}
	
//	if (_timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) {
//		UIImageView *selfieImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 54.0, 280.0, 252.0)];
//		selfieImageView.alpha = 0.0;
//		[self.contentView addSubview:selfieImageView];
//		
//		[HONImagingDepictor maskImageView:selfieImageView withMask:[UIImage imageNamed:@"avatarMask"]];
//		
//		void (^selfieImageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//			selfieImageView.image = image;
//			[UIView animateWithDuration:0.25 animations:^(void) {
//				selfieImageView.alpha = 1.0;
//			} completion:nil];
//		};
//		
//		void (^selfieImageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
//			[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:_timelineItemVO.challengeVO.creatorVO.imagePrefix forBucketType:HONS3BucketTypeSelfies completion:nil];
//			
//			selfieImageView.backgroundColor = [UIColor lightGrayColor];
//			[UIView animateWithDuration:0.25 animations:^(void) {
//				selfieImageView.alpha = 1.0;
//			} completion:nil];
//		};
//		
//		
//		[selfieImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_timelineItemVO.challengeVO.creatorVO.imagePrefix stringByAppendingString:kSnapTabSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
//							   placeholderImage:nil
//										success:selfieImageSuccessBlock
//										failure:selfieImageFailureBlock];
//		
//		UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 267.0, 320.0, 44.0)];
//		[self.contentView addSubview:footerView];
//		
//		UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		likeButton.frame = CGRectMake(16.0, 2.0, 44.0, 44.0);
//		[likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive"] forState:UIControlStateNormal];
//		[likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active"] forState:UIControlStateHighlighted];
//		[likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
//		[footerView addSubview:likeButton];
//		
//		UILabel *likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(53.0, 9.0, 160.0, 28.0)];
//		likesLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:11];
//		likesLabel.textColor = [UIColor whiteColor];
//		likesLabel.backgroundColor = [UIColor clearColor];
//		likesLabel.shadowColor = [UIColor blackColor];
//		likesLabel.shadowOffset = CGSizeMake(0.0, 1.0);
//		likesLabel.text = [NSString stringWithFormat:@"Likes (%d)", MIN(_timelineItemVO.userClubVO.totalEntries, 999)];
//		[footerView addSubview:likesLabel];
//		
//		UIButton *like2Button = [UIButton buttonWithType:UIButtonTypeCustom];
//		like2Button.frame = likesLabel.frame;
//		[like2Button addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
//		[footerView addSubview:like2Button];
//		
//		UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		replyButton.frame = CGRectMake(103.0, 0.0, 44.0, 44.0);
//		[replyButton setBackgroundImage:[UIImage imageNamed:@"replySelfieButton_nonActive"] forState:UIControlStateNormal];
//		[replyButton setBackgroundImage:[UIImage imageNamed:@"replySelfieButton_Active"] forState:UIControlStateHighlighted];
//		[replyButton addTarget:self action:@selector(_goReply) forControlEvents:UIControlEventTouchUpInside];
//		[footerView addSubview:replyButton];
//		
//		UILabel *repliesLabel = [[UILabel alloc] initWithFrame:CGRectMake(145.0, 9.0, 160.0, 28.0)];
//		repliesLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:11];
//		repliesLabel.textColor = [UIColor whiteColor];
//		repliesLabel.backgroundColor = [UIColor clearColor];
//		repliesLabel.shadowColor = [UIColor blackColor];
//		repliesLabel.shadowOffset = CGSizeMake(0.0, 1.0);
//		repliesLabel.text = [NSString stringWithFormat:@"Replies (%d)", MIN(_timelineItemVO.userClubVO.totalActiveMembers, 999)];
//		[footerView addSubview:repliesLabel];
//		
//		UIButton *reply2Button = [UIButton buttonWithType:UIButtonTypeCustom];
//		replyButton.frame = repliesLabel.frame;
//		[replyButton addTarget:self action:@selector(_goReply) forControlEvents:UIControlEventTouchUpInside];
//		[footerView addSubview:reply2Button];
//		
//		UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		moreButton.frame = CGRectMake(254.0, 2.0, 44.0, 44.0);
//		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive"] forState:UIControlStateNormal];
//		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active"] forState:UIControlStateHighlighted];
//		[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
//		[footerView addSubview:moreButton];
//	}
}



#pragma mark - Navigation
- (void)_goCreateClub {
	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:createClubWithProtoVO:)])
		[self.delegate clubNewsFeedViewCell:self createClubWithProtoVO:_timelineItemVO.userClubVO];
}

- (void)_goJoinClub {
	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:acceptInviteForClub:)])
		[self.delegate clubNewsFeedViewCell:self joinClub:_timelineItemVO.userClubVO];
}

- (void)_goLike {
//	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:likeClubChallenge:)])
//		[self.delegate clubNewsFeedViewCell:self likeClubChallenge:_timelineItemVO.challengeVO];
}

- (void)_goReply {
//	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:replyClubChallenge:)])
//		[self.delegate clubNewsFeedViewCell:self likeClubChallenge:_timelineItemVO.challengeVO];
}

- (void)_goMore {
//	if ([self.delegate respondsToSelector:@selector(clubNewsFeedViewCell:moreClubChallenge:)])
//		[self.delegate clubNewsFeedViewCell:self likeClubChallenge:_timelineItemVO.challengeVO];
}


@end
