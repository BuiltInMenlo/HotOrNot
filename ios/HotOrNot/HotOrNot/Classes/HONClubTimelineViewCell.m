//
//  HONClubTimelineViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/25/2014 @ 11:00 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONClubTimelineViewCell.h"


@interface HONClubTimelineViewCell ()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@end

@implementation HONClubTimelineViewCell
@synthesize timelineItemVO = _timelineItemVO;
@synthesize delegate = _delegate;


+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}

- (void)setFrame:(CGRect)frame {
	frame.size.height -= 10.0;
	[super setFrame:frame];
}


#pragma mark - Public APIs
- (void)setTimelineItemVO:(HONTimelineItemVO *)timelineItemVO {
	_timelineItemVO = timelineItemVO;
	self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(_timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) ? @"selfieRowBG" : @"nonSelfieRowBG"]];
	
	NSString *titleCaption = (_timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) ? [NSString stringWithFormat:@"%@ is feeling%@", _timelineItemVO.challengeVO.creatorVO.username, (_timelineItemVO.emotionVO != nil) ? [@" " stringByAppendingString:_timelineItemVO.emotionVO.emotionName] : @"…"] : _timelineItemVO.userClubVO.clubName;
	NSString *subtitleCaption = (_timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) ? [NSString stringWithFormat:@"%@ in %@", [HONAppDelegate timeSinceDate:_timelineItemVO.timestamp], _timelineItemVO.challengeVO.subjectName] : [NSString stringWithFormat:@"%d member%@", _timelineItemVO.userClubVO.totalActiveMembers, ( _timelineItemVO.userClubVO.totalActiveMembers != 1) ? @"s" : @""];
	NSString *avatarPrefix = (_timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) ? _timelineItemVO.challengeVO.creatorVO.avatarPrefix : _timelineItemVO.userClubVO.coverImagePrefix;
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(19.0, (_timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) ? 10.0 : (_timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) ? 35.0 : 41.0, (_timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) ? 35.0 : 48.0, (_timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) ? 35.0 : 48.0)];
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
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:avatarPrefix forBucketType:(_timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) ? HONS3BucketTypeAvatars : HONS3BucketTypeClubs completion:nil];
		
		avatarImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapThumbSize];
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[avatarPrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						   placeholderImage:nil
									success:avatarImageSuccessBlock
									failure:avatarImageFailureBlock];
	
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) ? 63.0 : 74.0, (_timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) ? 10.0 : 47.0, 200.0, 18.0)];
	titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = titleCaption;
	[self.contentView addSubview:titleLabel];
	
	UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y + 17.0, 200.0, 16.0)];
	subtitleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
	subtitleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	subtitleLabel.backgroundColor = [UIColor clearColor];
	subtitleLabel.text = subtitleCaption;
	[self.contentView addSubview:subtitleLabel];
	
	if (_timelineItemVO.timelineItemType != HONTimelineItemTypeSelfie) {
		UILabel *topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 6.0, 200.0, 16.0)];
		topicLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
		topicLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		topicLabel.backgroundColor = [UIColor clearColor];
		topicLabel.text = (_timelineItemVO.timelineItemType != HONTimelineItemTypeNearby) ? @"Nearby club" : @"Club Invite";
		[self.contentView addSubview:topicLabel];
		
		UIButton *ctaButton = [UIButton buttonWithType:UIButtonTypeCustom];
		ctaButton.frame = CGRectMake(212.0, 42.0, 84.0, 44.0);
		[ctaButton setBackgroundImage:[UIImage imageNamed:@"joinClubButton_nonActive"] forState:UIControlStateNormal];
		[ctaButton setBackgroundImage:[UIImage imageNamed:@"joinClubButton_Active"] forState:UIControlStateHighlighted];
		[ctaButton addTarget:self action:@selector(_goCTA) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:ctaButton];
	}
	
	if (_timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) {
		UIImageView *selfieImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 54.0, 280.0, 252.0)];
		selfieImageView.alpha = 0.0;
		[self.contentView addSubview:selfieImageView];
		
//		[HONImagingDepictor maskImageView:selfieImageView withMask:[UIImage imageNamed:@"avatarMask"]];
		
		void (^selfieImageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			selfieImageView.image = image;
			[UIView animateWithDuration:0.25 animations:^(void) {
				selfieImageView.alpha = 1.0;
			} completion:nil];
		};
		
		void (^selfieImageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:_timelineItemVO.challengeVO.creatorVO.imagePrefix forBucketType:HONS3BucketTypeSelfies completion:nil];
			
			selfieImageView.backgroundColor = [UIColor lightGrayColor];
			[UIView animateWithDuration:0.25 animations:^(void) {
				selfieImageView.alpha = 1.0;
			} completion:nil];
		};
		
		
		[selfieImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_timelineItemVO.challengeVO.creatorVO.imagePrefix stringByAppendingString:kSnapTabSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							   placeholderImage:nil
										success:selfieImageSuccessBlock
										failure:selfieImageFailureBlock];
		
		UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 267.0, 320.0, 44.0)];
		[self.contentView addSubview:footerView];
		
		UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		likeButton.frame = CGRectMake(16.0, 2.0, 44.0, 44.0);
		[likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive"] forState:UIControlStateNormal];
		[likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active"] forState:UIControlStateHighlighted];
		[likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		[footerView addSubview:likeButton];
		
		UILabel *likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(53.0, 9.0, 160.0, 28.0)];
		likesLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:11];
		likesLabel.textColor = [UIColor whiteColor];
		likesLabel.backgroundColor = [UIColor clearColor];
		likesLabel.shadowColor = [UIColor blackColor];
		likesLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		likesLabel.text = [NSString stringWithFormat:@"Likes (%d)", MIN(_timelineItemVO.userClubVO.totalEntries, 999)];
		[footerView addSubview:likesLabel];
		
		UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
		replyButton.frame = CGRectMake(103.0, 0.0, 44.0, 44.0);
		[replyButton setBackgroundImage:[UIImage imageNamed:@"replySelfieButton_nonActive"] forState:UIControlStateNormal];
		[replyButton setBackgroundImage:[UIImage imageNamed:@"replySelfieButton_Active"] forState:UIControlStateHighlighted];
//		[replyButton addTarget:self action:@selector(_goReply) forControlEvents:UIControlEventTouchUpInside];
		[footerView addSubview:replyButton];
		
		UILabel *repliesLabel = [[UILabel alloc] initWithFrame:CGRectMake(145.0, 9.0, 160.0, 28.0)];
		repliesLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:11];
		repliesLabel.textColor = [UIColor whiteColor];
		repliesLabel.backgroundColor = [UIColor clearColor];
		repliesLabel.shadowColor = [UIColor blackColor];
		repliesLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		repliesLabel.text = [NSString stringWithFormat:@"Replies (%d)", MIN(_timelineItemVO.userClubVO.totalActiveMembers, 999)];
		[footerView addSubview:repliesLabel];
		
		UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
		moreButton.frame = CGRectMake(254.0, 2.0, 44.0, 44.0);
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive"] forState:UIControlStateNormal];
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active"] forState:UIControlStateHighlighted];
//		[moreButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
		[footerView addSubview:moreButton];

	}
}



#pragma mark - Navigation
- (void)_goCTA {
	if ([self.delegate respondsToSelector:@selector(clubTimelineViewCell:acceptInviteForClub:)])
		[self.delegate clubTimelineViewCell:self acceptInviteForClub:_timelineItemVO.userClubVO];
}

- (void)_goLike {
	if ([self.delegate respondsToSelector:@selector(clubTimelineViewCell:likeClubChallenge:)])
		[self.delegate clubTimelineViewCell:self likeClubChallenge:_timelineItemVO.challengeVO];
}

- (void)_goReply {
	if ([self.delegate respondsToSelector:@selector(clubTimelineViewCell:replyClubChallenge:)])
		[self.delegate clubTimelineViewCell:self likeClubChallenge:_timelineItemVO.challengeVO];
}

- (void)_goMore {
	if ([self.delegate respondsToSelector:@selector(clubTimelineViewCell:moreClubChallenge:)])
		[self.delegate clubTimelineViewCell:self likeClubChallenge:_timelineItemVO.challengeVO];
}


@end
