//
//  HONSuggestedFollowViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 11/25/2013 @ 13:37 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"

#import "HONSuggestedFollowViewCell.h"
#import "HONImageLoadingView.h"
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
@synthesize popularUserVO = _popularUserVO;


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
		_selfiesLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:13];
		_selfiesLabel.textColor = [HONAppDelegate honGreyTextColor];
		_selfiesLabel.backgroundColor = [UIColor clearColor];
		_selfiesLabel.textAlignment = NSTextAlignmentCenter;
		_selfiesLabel.text = @"0 Selfies";
		[self.contentView addSubview:_selfiesLabel];
		
		_followersLabel = [[UILabel alloc] initWithFrame:CGRectMake(106.0, 170.0, 107.0, 18.0)];
		_followersLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:13];
		_followersLabel.textColor = [HONAppDelegate honGreyTextColor];
		_followersLabel.backgroundColor = [UIColor clearColor];
		_followersLabel.textAlignment = NSTextAlignmentCenter;
		_followersLabel.text = @"0 Followers";
		[self.contentView addSubview:_followersLabel];
		
		_followingLabel = [[UILabel alloc] initWithFrame:CGRectMake(213.0, 170.0, 107.0, 18.0)];
		_followingLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:13];
		_followingLabel.textColor = [HONAppDelegate honGreyTextColor];
		_followingLabel.backgroundColor = [UIColor clearColor];
		_followingLabel.textAlignment = NSTextAlignmentCenter;
		_followingLabel.text = @"0 Following";
		[self.contentView addSubview:_followingLabel];
	}
	
	return (self);
}

- (void)setPopularUserVO:(HONPopularUserVO *)popularUserVO {
	_popularUserVO = popularUserVO;
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6.0, 5.0, 33.0, 33.0)];
	[self.contentView addSubview:avatarImageView];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		avatarImageView.image = image;
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RECREATE_IMAGE_SIZES" object:_userVO.avatarURL];
		avatarImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapThumbSize];
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_popularUserVO.imageURL stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						   placeholderImage:nil
									success:imageSuccessBlock
									failure:imageFailureBlock];
	
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(48.0, 11.0, 170.0, 20.0)];
	nameLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16];
	nameLabel.textColor = [HONAppDelegate honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _popularUserVO.username;
	[self.contentView addSubview:nameLabel];
	
	for (int i=0; i<2; i++) {
		UIImageView *borderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"suggestedFollowChallengeBorder"]];
		borderImageView.frame = CGRectOffset(borderImageView.frame, 15.0 + (i * (kSnapThumbSize.width + 15.0)), 58.0);
		[self.contentView addSubview:borderImageView];
		
		HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:borderImageView asLargeLoader:NO];
		[imageLoadingView startAnimating];
		[borderImageView addSubview:imageLoadingView];
	}
	
	[self _retrieveUser];
}

- (void)toggleSelected:(BOOL)isSelected {
	_followButton.alpha = (int)!isSelected;
	_followButton.hidden = isSelected;
	
	_checkButton.hidden = !isSelected;
}


#pragma mark - Data Calls
- (void)_retrieveUser {
	NSDictionary *params = @{@"action"	: [NSString stringWithFormat:@"%d", 5],
							 @"userID"	: [NSString stringWithFormat:@"%d", _popularUserVO.userID]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			//VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if ([result objectForKey:@"id"] != nil) {
				_userVO = [HONUserVO userWithDictionary:result];
				[self _retreiveSubscribees];
				
			} else {
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if ([error.description isEqualToString:kNetErrorNoConnection]) {
		}
	}];
}

- (void)_retreiveSubscribees {
	NSDictionary *params = @{@"userID"	: [NSString stringWithFormat:@"%d", _popularUserVO.userID]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIGetSubscribees, params);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	
	[httpClient postPath:kAPIGetSubscribees parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			//VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			_totalFollowing = [result count];
			[self _retrieveChallenges];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}

- (void)_retrieveChallenges {
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"action"		: [NSString stringWithFormat:@"%d", 9],
							 @"isPrivate"	: @"N",
							 @"username"	: _userVO.username,
							 @"p"			: [NSString stringWithFormat:@"%d", 1]};
	
	VolleyJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, params);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			//VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [result objectAtIndex:0]);
			_challenges = [NSMutableArray array];
			
			int cnt = 0;
			for (NSDictionary *dict in result) {
//				NSLog(@"CHALLENGE #%d:[%@]", (cnt + 1), [dict objectForKey:@"creator"]);
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:dict];
				[_challenges addObject:vo];
				
				if (cnt++ == 1)
					break;
			}
			
			cnt = 0;
			for (HONChallengeVO *vo in _challenges) {
				NSString *imgPrefix = @"";
				if (vo.creatorVO.userID == _popularUserVO.userID)
					imgPrefix = vo.creatorVO.imagePrefix;
				
				else {
					for (HONOpponentVO *opponentVO in vo.challengers) {
						if (opponentVO.userID == _popularUserVO.userID)
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
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
	}];
}


#pragma mark - Navigation
- (void)_goFollow {
	_checkButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_followButton.alpha = 0.0;
	} completion:^(BOOL finished) {
		_followButton.hidden = YES;
	}];
	
	[self.delegate followViewCell:self user:_popularUserVO toggleSelected:YES];
}

- (void)_goUnfollow {
	_followButton.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_followButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		_checkButton.hidden = YES;
	}];
	
	[self.delegate followViewCell:self user:_popularUserVO toggleSelected:NO];
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
