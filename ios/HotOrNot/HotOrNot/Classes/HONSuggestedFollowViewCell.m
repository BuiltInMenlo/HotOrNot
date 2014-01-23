//
//  HONSuggestedFollowViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 11/25/2013 @ 13:37 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONSuggestedFollowViewCell.h"
#import "HONAPICaller.h"
#import "HONColorAuthority.h"
#import "HONFontAllocator.h"
#import "HONImageLoadingView.h"
#import "HONChallengeVO.h"
#import "HONEmotionVO.h"
#import "HONUserVO.h"
#import "HONImagingDepictor.h"


@interface HONSuggestedFollowViewCell ()
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UILabel *selfiesLabel;
@property (nonatomic, strong) UILabel *followersLabel;
@property (nonatomic, strong) UILabel *followingLabel;
@property (nonatomic, strong) HONUserVO *userVO;
@property (nonatomic) int totalFollowing;
@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic, strong) NSArray *challengeOverlays;
@end

@implementation HONSuggestedFollowViewCell
@synthesize delegate = _delegate;
@synthesize trivialUserVO = _trivialUserVO;


+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"suggestedCellBackground"]];
		
		_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_checkButton.frame = CGRectMake(209.0, 76.0, 94.0, 44.0);
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"suggestedFollowOnButton_nonActive"] forState:UIControlStateNormal];
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"suggestedFollowOnButton_Active"] forState:UIControlStateHighlighted];
		[_checkButton addTarget:self action:@selector(_goUnfollow) forControlEvents:UIControlEventTouchUpInside];
		_checkButton.hidden = YES;
		[self.contentView addSubview:_checkButton];
		
		_followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_followButton.frame = _checkButton.frame;
		[_followButton setBackgroundImage:[UIImage imageNamed:@"suggestedFollowOffButton_nonActive"] forState:UIControlStateNormal];
		[_followButton setBackgroundImage:[UIImage imageNamed:@"suggestedFollowOffButton_Active"] forState:UIControlStateHighlighted];
		[_followButton addTarget:self action:@selector(_goFollow) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_followButton];
		
		_selfiesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 170.0, 107.0, 18.0)];
		_selfiesLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
		_selfiesLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		_selfiesLabel.backgroundColor = [UIColor clearColor];
		_selfiesLabel.textAlignment = NSTextAlignmentCenter;
		_selfiesLabel.text = @"0 Selfies";
		[self.contentView addSubview:_selfiesLabel];
		
		_followersLabel = [[UILabel alloc] initWithFrame:CGRectMake(106.0, 170.0, 107.0, 18.0)];
		_followersLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
		_followersLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		_followersLabel.backgroundColor = [UIColor clearColor];
		_followersLabel.textAlignment = NSTextAlignmentCenter;
		_followersLabel.text = @"0 Followers";
		[self.contentView addSubview:_followersLabel];
		
		_followingLabel = [[UILabel alloc] initWithFrame:CGRectMake(213.0, 170.0, 107.0, 18.0)];
		_followingLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
		_followingLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		_followingLabel.backgroundColor = [UIColor clearColor];
		_followingLabel.textAlignment = NSTextAlignmentCenter;
		_followingLabel.text = @"0 Following";
		[self.contentView addSubview:_followingLabel];
	}
	
	return (self);
}

- (void)setTrivialUserVO:(HONTrivialUserVO *)trivialUserVO {
	_trivialUserVO = trivialUserVO;
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6.0, 5.0, 33.0, 33.0)];
	[self.contentView addSubview:avatarImageView];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		avatarImageView.image = image;
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForURL:_userVO.avatarPrefix forAvatarBucket:YES completion:nil];
		
		avatarImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapThumbSize];
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_trivialUserVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						   placeholderImage:nil
									success:imageSuccessBlock
									failure:imageFailureBlock];
	
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(48.0, 11.0, 170.0, 20.0)];
	nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
	nameLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _trivialUserVO.username;
	[self.contentView addSubview:nameLabel];
	
	for (int i=0; i<2; i++) {
		UIImageView *borderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"suggestedFollowChallengeBorder"]];
		borderImageView.frame = CGRectOffset(borderImageView.frame, 15.0 + (i * (kSnapThumbSize.width + 15.0)), 58.0);
		[self.contentView addSubview:borderImageView];
		
		HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:borderImageView asLargeLoader:NO];
		[imageLoadingView startAnimating];
		[borderImageView addSubview:imageLoadingView];
	}
	
	[[HONAPICaller sharedInstance] retrieveUserByUserID:_trivialUserVO.userID completion:^(NSObject *result) {
		if ([(NSDictionary *)result objectForKey:@"id"] != nil) {
			_userVO = [HONUserVO userWithDictionary:(NSDictionary *)result];
			
			[[HONAPICaller sharedInstance] retrieveFollowingUsersForUserByUserID:_trivialUserVO.userID completion:^(NSObject *result){
				_totalFollowing = [(NSArray *)result count];
				
				[[HONAPICaller sharedInstance] retrieveChallengesForUserByUserID:_userVO.userID completion:^(NSObject *result){
					_challenges = [NSMutableArray array];
					
					int cnt = 0;
					for (NSDictionary *dict in (NSArray *)result) {
//						NSLog(@"CHALLENGE #%d:[%@]", (cnt + 1), [dict objectForKey:@"creator"]);
						HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:dict];
						[_challenges addObject:vo];
						
						if (cnt++ == 1)
							break;
					}
					
					cnt = 0;
					for (HONChallengeVO *vo in _challenges) {
						NSString *imgPrefix = @"";
						if (vo.creatorVO.userID == _trivialUserVO.userID)
							imgPrefix = vo.creatorVO.imagePrefix;
						
						else {
							for (HONOpponentVO *opponentVO in vo.challengers) {
								if (opponentVO.userID == _trivialUserVO.userID)
									imgPrefix = opponentVO.imagePrefix;
							}
						}
						
						UIImageView *challengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0 + (cnt * (kSnapThumbSize.width + 15.0)), 58.0, kSnapThumbSize.width, kSnapThumbSize.height)];
						[challengeImageView setImageWithURL:[NSURL URLWithString:[imgPrefix stringByAppendingString:kSnapThumbSuffix]] placeholderImage:nil];
						[self.contentView addSubview:challengeImageView];
						
						UIImageView *borderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"suggestedFollowChallengeBorder"]];
						borderImageView.frame = challengeImageView.frame;
						[self.contentView addSubview:borderImageView];
						
						cnt++;
					}
					
					[self _makeStats];
				}];
			}];
		}
	}];
}

- (void)toggleSelected:(BOOL)isSelected {
	_followButton.alpha = (int)!isSelected;
	_followButton.hidden = isSelected;
	
	_checkButton.hidden = !isSelected;
}


#pragma mark - Data Calls


#pragma mark - Navigation
- (void)_goFollow {
	_checkButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_followButton.alpha = 0.0;
	} completion:^(BOOL finished) {
		_followButton.hidden = YES;
	}];
	
	[self.delegate followViewCell:self user:_trivialUserVO toggleSelected:YES];
}

- (void)_goUnfollow {
	_followButton.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_followButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		_checkButton.hidden = YES;
	}];
	
	[self.delegate followViewCell:self user:_trivialUserVO toggleSelected:NO];
}


#pragma mark - UI Presentation
- (UIImageView *)_challengeImageForPrefix:(NSString *)imagePrefix {
	
	UIImageView *challengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(1.0, 1.0, kSnapThumbSize.width - 2.0, kSnapThumbSize.height - 2.0)];
	[challengeImageView setImageWithURL:[NSURL URLWithString:[imagePrefix stringByAppendingString:kSnapThumbSuffix]] placeholderImage:nil];
//	[borderImageView addSubview:challengeImageView];
	
	return (challengeImageView);
}

- (void)_makeStats {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	_selfiesLabel.text = [NSString stringWithFormat:@"%@ Selfie%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.totalVolleys]], (_userVO.totalVolleys == 1) ? @"" : @"s"];
	_followersLabel.text = [NSString stringWithFormat:@"%@ Follower%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[_userVO.friends count]]], ([_userVO.friends count] == 1) ? @"" : @"s"];
	_followingLabel.text = [NSString stringWithFormat:@"%@ Following", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_totalFollowing]]];
}


@end
