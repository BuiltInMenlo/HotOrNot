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
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, (_timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) ? 8.0 : 35.0, 48.0, 48.0)];
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
	
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(74.0, (_timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) ? 7.0 : 40.0, 200.0, 18.0)];
	titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:16];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = titleCaption;
	[self.contentView addSubview:titleLabel];
	
	UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y + 21.0, 200.0, 18.0)];
	subtitleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14];
	subtitleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	subtitleLabel.backgroundColor = [UIColor clearColor];
	subtitleLabel.text = subtitleCaption;
	[self.contentView addSubview:subtitleLabel];
	
	if (_timelineItemVO.timelineItemType != HONTimelineItemTypeSelfie) {
		UILabel *topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 2.0, 200.0, 18.0)];
		topicLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14];
		topicLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		topicLabel.backgroundColor = [UIColor clearColor];
		topicLabel.text = @"Nearby club";
		[self.contentView addSubview:topicLabel];
		
		UIButton *ctaButton = [UIButton buttonWithType:UIButtonTypeCustom];
		ctaButton.frame = CGRectMake(248.0, 22.0, 64.0, 64.0);
		[ctaButton setBackgroundImage:[UIImage imageNamed:@"addClubButton_nonActive"] forState:UIControlStateNormal];
		[ctaButton setBackgroundImage:[UIImage imageNamed:@"addClubButton_Active"] forState:UIControlStateHighlighted];
		[ctaButton addTarget:self action:@selector(_goCTA) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:ctaButton];
	}
	
	if (_timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) {
		UIImageView *selfieImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 54.0, 280.0, 261.0)];
		selfieImageView.alpha = 0.0;
		[self.contentView addSubview:selfieImageView];
		
		[HONImagingDepictor maskImageView:selfieImageView withMask:[UIImage imageNamed:@"avatarMask"]];
		
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
	}
}



#pragma mark - Navigation
- (void)_goCTA {
	if ([self.delegate respondsToSelector:@selector(clubTimelineViewCell:acceptInviteForClub:)])
		[self.delegate clubTimelineViewCell:self acceptInviteForClub:_timelineItemVO.userClubVO];
}


@end
