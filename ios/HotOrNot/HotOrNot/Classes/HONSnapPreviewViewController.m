//
//  HONSnapPreviewViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 7/22/13 @ 5:33 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+ImageEffects.h"

#import "HONSnapPreviewViewController.h"
#import "HONImageLoadingView.h"
#import "HONUserVO.h"
#import "HONEmotionVO.h"
#import "HONHeaderView.h"
#import "HONImagingDepictor.h"
#import "HONFollowersViewController.h"
#import "HONFollowingViewController.h"
#import "HONUserProfileGridView.h"
#import "HONUserProfileViewController.h"

@interface HONSnapPreviewViewController () <HONSnapPreviewViewControllerDelegate, HONParticipantGridViewDelegate>
//@property (nonatomic, copy) imageLoadComplete_t heroCompleteBlock;
//@property (nonatomic, copy) imageLoadFailure_t heroFailureBlock;

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) UIView *imageHolderView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIView *releaseHolderView;
@property (nonatomic, strong) UIView *buttonHolderView;
@property (nonatomic, strong) UIView *nameHolderView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *profileHolderView;
@property (nonatomic, strong) UIImageView *uploadingImageView;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONChallengeVO *newestChallengeVO;
@property (nonatomic, strong) HONOpponentVO *opponentVO;
@property (nonatomic, strong) HONUserVO *userVO;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic) BOOL isVerify;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic, strong) UIView *avatarHolderView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *subscribersLabel;
@property (nonatomic, strong) UILabel *subscribeesLabel;
@property (nonatomic, strong) UILabel *volleysLabel;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) UIView *gridHolderView;
@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic, strong) NSMutableArray *challengeImages;
@property (nonatomic, retain) HONUserProfileViewController *userProfileViewController;
@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
@property (nonatomic, strong) HONUserProfileGridView *profileGridView;
@property (nonatomic, strong) UIButton *subscribeButton;
@property (nonatomic) int challengeCounter;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic) BOOL isRoot;
@property (nonatomic) BOOL hasVisitedProfile;
@property (nonatomic, strong) UIImageView *blurredImageView;
@end


@implementation HONSnapPreviewViewController
@synthesize delegate = _delegate;
//- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
//    self.completionBlock = ^{
//        if () {
//            if (failure) {
//
//            }
//        } else {
//            if (success) {
//
//            }
//        }
//    };
//#pragma clang diagnostic pop
//}

//static void (^heroSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image);
//
//void (^heroSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//	
//static void imageLoadComplete_t(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//    AFNetworkReachabilityStatus status = AFNetworkReachabilityStatusForFlags(flags);
//    AFNetworkReachabilityStatusBlock block = (__bridge AFNetworkReachabilityStatusBlock)info;
//    if (block) {
//        block(status);
//    }
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingReachabilityDidChangeNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:status] forKey:AFNetworkingReachabilityNotificationStatusItem]];
//    });
//}




- (id)initWithVerifyChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_challengeVO = vo;
		_opponentVO = vo.creatorVO;
		_isVerify = YES;
		_isRoot = YES;
		_hasVisitedProfile = NO;
	}
	
	return (self);
}

- (id)initWithOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO asRoot:(BOOL)isFirst {
	if ((self = [super init])) {
		_opponentVO = opponentVO;
		_challengeVO = challengeVO;
		_isVerify = NO;
		_isRoot = isFirst;
		_hasVisitedProfile = NO;
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotate {
	return (NO);
}


#pragma mark - Data Calls
- (void)_retrieveUser:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 5], @"action",
							[NSString stringWithFormat:@"%d", userID], @"userID",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
//			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			_userVO = [HONUserVO userWithDictionary:userResult];
			
			NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
			[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
			
			_subscribersLabel.text = [NSString stringWithFormat:@"%@ follower%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[_userVO.friends count]]], ([_userVO.friends count] == 1) ? @"" : @"s"];
			_volleysLabel.text = [NSString stringWithFormat:@"%@ volley%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.totalVolleys]], (_userVO.totalVolleys == 1) ? @"" : @"s"];
			_likesLabel.text = [NSString stringWithFormat:@"%@ like%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]], (_userVO.votes == 1) ? @"" : @"s"];
			
			[self _retreiveSubscribees];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}

- (void)_retreiveSubscribees {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", _opponentVO.userID], @"userID", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIGetSubscribees);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	
	[httpClient postPath:kAPIGetSubscribees parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
//			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
			[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
			
			_subscribeesLabel.text = [NSString stringWithFormat:@"%@ following", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[result count]]]];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}


- (void)_retrieveChallenges {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[params setObject:[NSString stringWithFormat:@"%d", 9] forKey:@"action"];
	[params setObject:@"N" forKey:@"isPrivate"];
	[params setObject:_userVO.username forKey:@"username"];
	[params setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"p"];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *challengesResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], challengesResult);
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], [challengesResult objectAtIndex:0]);
			
			_challenges = [NSMutableArray array];
			
			for (NSDictionary *serverList in challengesResult) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
				
				if (vo != nil) {
					[_challenges addObject:vo];
				}
			}
			
			_isRefreshing = NO;
//			[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
			_scrollView.contentSize = CGSizeMake(320.0, MAX([UIScreen mainScreen].bounds.size.height + 1.0, 660.0 + (kSnapThumbSize.height * (([_challenges count] / 4) + 1))));
			[self _makeGrid];
			[self _addEmoticon];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
	}];
}

- (void)_flagUser:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 10], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", userID], @"targetID",
							[NSString stringWithFormat:@"%d", 0], @"approves",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}

- (void)_upvoteChallenge:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 6], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
							[NSString stringWithFormat:@"%d", userID], @"challengerID",
							_opponentVO.imagePrefix, @"imgURL",
							nil];
	
	NSLog(@"PARAMS:[%@]", params);
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
//			NSDictionary *voteResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
	}];
}

- (void)_addFriend:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", userID], @"target",
							@"0", @"auto", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIAddFriend);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIAddFriend parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			if (result != nil)
				[HONAppDelegate writeSubscribeeList:result];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}

- (void)_removeFriend:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", userID], @"target", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIRemoveFriend);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIRemoveFriend parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			if (result != nil)
				[HONAppDelegate writeSubscribeeList:result];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}

- (void)_verifyUser:(int)userID asLegit:(BOOL)isApprove {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 10], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", userID], @"targetID",
							[NSString stringWithFormat:@"%d", (int)isApprove], @"approves",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			if (isApprove) {
				int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"verifyAction_total"] intValue];
				[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++total] forKey:@"verifyAction_total"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				if (total == 0 && [HONAppDelegate switchEnabledForKey:@"verify_share"]) {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SHARE Volley with your friends?"
																		message:@"Get more subscribers now, tap OK."
																	   delegate:self
															  cancelButtonTitle:@"Cancel"
															  otherButtonTitles:@"OK", nil];
					[alertView setTag:0];
					[alertView show];
					
				}
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
	}];
}

- (void)_loadForVerify {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	NSMutableString *imageURL = [_opponentVO.imagePrefix mutableCopy];
	[imageURL replaceOccurrencesOfString:@".jpg" withString:@"Large_640x1136.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imageURL length])];
	NSLog(@"VERIFY LOADING:[%@]", imageURL);
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		[_uploadingImageView stopAnimating];
		_imageView.image = image;
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_imageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RECREATE_IMAGE_SIZES" object:imageURL];
	};
	
	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, (568.0 - self.view.frame.size.height) * -0.5, 320.0, 568.0)];
	[_imageHolderView addSubview:_imageView];
	_imageView.alpha = 0.0;
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
					  placeholderImage:nil
							   success:successBlock
							   failure:failureBlock];
	
	//	NSLog(@"VERIFY -- ORIGINAL:[%d] DIFF:[%f] IMG:[%@] DATA:[%@]\n", isOriginalImageAvailable, diff, imageURL, _opponentVO.dictionary);
}

- (void)_loadForChallenge {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	NSString *imageURL = [NSString stringWithFormat:@"%@Large_640x1136.jpg", _opponentVO.imagePrefix];
	NSLog(@"CHALLENGE LOADING:[%@]", imageURL);
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		[_uploadingImageView stopAnimating];
		_imageView.image = image;
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_imageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RECREATE_IMAGE_SIZES" object:imageURL];
	};

	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, (568.0 - self.view.frame.size.height) * -0.5, 320.0, 568.0)];
	[_imageHolderView addSubview:_imageView];
	_imageView.alpha = 0.0;
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
					  placeholderImage:nil
							   success:successBlock
							   failure:failureBlock];
	
	//	NSLog(@"CHALLENGE -- ORIGINAL:[%d] DIFF:[%f] IMG:[%@] DATA:[%@]\n", isOriginalImageAvailable, diff, imageURL, _opponentVO.dictionary);
}



#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	_uploadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 23.0), 54.0, 14.0)];
	_uploadingImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"cameraUpload_001"],
										   [UIImage imageNamed:@"cameraUpload_002"],
										   [UIImage imageNamed:@"cameraUpload_003"], nil];
	_uploadingImageView.animationDuration = 0.5f;
	_uploadingImageView.animationRepeatCount = 0;
	[_uploadingImageView startAnimating];
	[self.view addSubview:_uploadingImageView];
	
	_imageHolderView = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:_imageHolderView];
	
	NSMutableString *imageURL = [_opponentVO.imagePrefix mutableCopy];
	
	if (_isVerify)
		[imageURL replaceOccurrencesOfString:@".jpg" withString:@"Large_640x1136.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imageURL length])];
	
	else
		imageURL = [NSMutableString stringWithFormat:@"%@Large_640x1136.jpg", _opponentVO.imagePrefix];
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		[_uploadingImageView stopAnimating];
		_imageView.image = image;
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_imageView.alpha = 1.0;
		} completion:^(BOOL finished) {
			_closeButton.hidden = NO;
			[UIView animateWithDuration:0.33 animations:^(void) {
				_buttonHolderView.alpha = 1.0;
			}];
		}];
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RECREATE_IMAGE_SIZES" object:imageURL];
		[UIView animateWithDuration:0.33 animations:^(void) {
			_buttonHolderView.alpha = 1.0;
		}];
	};
	
	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, (568.0 - self.view.frame.size.height) * -0.5, 320.0, 568.0)];
	[_imageHolderView addSubview:_imageView];
	_imageView.alpha = 0.0;
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
					  placeholderImage:nil
							   success:successBlock
							   failure:failureBlock];
	
	NSLog(@"%@ --> HERO:[%@] DATA:[%@]\n", (_isVerify) ? @"VERIFY" : @"OPPONENT", imageURL, _opponentVO.dictionary);
	
	BOOL isFriend = NO;
	for (HONUserVO *vo in [HONAppDelegate subscribeeList]) {
		if (vo.userID == _opponentVO.userID) {
			isFriend = YES;
			break;
		}
	}
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height)];
	_scrollView.pagingEnabled = NO;
	_scrollView.showsVerticalScrollIndicator = YES;
	_scrollView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_scrollView];
	
//	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
//	lpGestureRecognizer.minimumPressDuration = 0.25;
//	[_scrollView addGestureRecognizer:lpGestureRecognizer];
	
	_profileHolderView = [[UIView alloc] initWithFrame:self.view.bounds];
	_profileHolderView.hidden = YES;
	_profileHolderView.alpha = 0.0;
	[_scrollView addSubview:_profileHolderView];
	
	_closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_closeButton.frame = self.view.frame;
	_closeButton.hidden = YES;
	[_closeButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchDown];
	[_scrollView addSubview:_closeButton];
	
	_nameHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 26.0, 320.0, 64.0)];
	[_scrollView addSubview:_nameHolderView];
	
	UILabel *participantLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0, 0.0, 290.0, 19.0)];
	participantLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:17];
	participantLabel.textColor = [UIColor whiteColor];
	participantLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
	participantLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	participantLabel.backgroundColor = [UIColor clearColor];
	participantLabel.text = _opponentVO.username;
	[_nameHolderView addSubview:participantLabel];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 19.0, 270.0, 23.0)];
	subjectLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
	subjectLabel.textColor = [UIColor whiteColor];
	subjectLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
	subjectLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _opponentVO.subjectName;
	subjectLabel.hidden = _isVerify;
	[_nameHolderView addSubview:subjectLabel];
	
	CGSize heroSize = [participantLabel.text boundingRectWithSize:CGSizeMake(250.0, participantLabel.frame.size.height)
														 options:NSStringDrawingTruncatesLastVisibleLine
													  attributes:@{NSFontAttributeName:participantLabel.font}
														 context:nil].size;
	participantLabel.frame = CGRectMake(participantLabel.frame.origin.x, participantLabel.frame.origin.y, heroSize.width, heroSize.height);
	
	CGSize subjectSize = [subjectLabel.text boundingRectWithSize:CGSizeMake(250.0, subjectLabel.frame.size.height)
													  options:NSStringDrawingTruncatesLastVisibleLine
												   attributes:@{NSFontAttributeName:subjectLabel.font}
													  context:nil].size;
	subjectLabel.frame = CGRectMake(subjectLabel.frame.origin.x, subjectLabel.frame.origin.y, subjectSize.width, subjectSize.height);
	
	BOOL isEmotionFound = NO;
	
	if (!_isVerify) {
		HONEmotionVO *emotionVO = [self _emotionForParticipant:_opponentVO];
		isEmotionFound = (emotionVO != nil);
		
		participantLabel.frame = CGRectOffset(participantLabel.frame, ((int)isEmotionFound) * 34.0, 0.0);
		subjectLabel.frame = CGRectOffset(subjectLabel.frame, ((int)isEmotionFound) * 34.0, 0.0);
		
		if (isEmotionFound) {
			UIImageView *emoticonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-1.0, 0.0, 43.0, 43.0)];
			[emoticonImageView setImageWithURL:[NSURL URLWithString:emotionVO.imageLargeURL] placeholderImage:nil];
			[_nameHolderView addSubview:emoticonImageView];
		}
	}
	
	UIButton *profileTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
	profileTextButton.frame = CGRectMake(9.0 + (((int)isEmotionFound) * 34.0), 0.0, MAX(heroSize.width, (!_isVerify) ? subjectSize.width : heroSize.width), participantLabel.frame.size.height + (((int)!_isVerify) * subjectLabel.frame.size.height + 2.0));
	[profileTextButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
	[_nameHolderView addSubview:profileTextButton];
	
	
	_buttonHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height * 0.5) - 23.0, 320.0, 74.0)];
	_buttonHolderView.alpha = 0.0;
	[_scrollView addSubview:_buttonHolderView];
	
	
	UIButton *upvoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	upvoteButton.frame = CGRectMake(24.0, 0.0, 74.0, 74.0);
	[upvoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive"] forState:UIControlStateNormal];
	[upvoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active"] forState:UIControlStateHighlighted];
	[upvoteButton addTarget:self action:@selector(_goUpvote) forControlEvents:UIControlEventTouchUpInside];
	[_buttonHolderView addSubview:upvoteButton];
	
	UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
	profileButton.frame = CGRectMake(122.0, 0.0, 74.0, 74.0);
	[profileButton setBackgroundImage:[UIImage imageNamed:@"profileButton_nonActive"] forState:UIControlStateNormal];
	[profileButton setBackgroundImage:[UIImage imageNamed:@"profileButton_nonActive"] forState:UIControlStateHighlighted];
	profileButton.alpha = 0.33;
	profileButton.hidden = _isVerify;
	[_buttonHolderView addSubview:profileButton];
	
	if (_isRoot) {
		[profileButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
		[profileButton setBackgroundImage:[UIImage imageNamed:@"subscribeButton_Active"] forState:UIControlStateHighlighted];
		profileButton.alpha = 1.0;
	}
	
	UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
	flagButton.frame = CGRectMake(222.0, 0.0, 74.0, 74.0);
	[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_nonActive"] forState:UIControlStateNormal];
	[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_Active"] forState:UIControlStateHighlighted];
	[flagButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
	flagButton.hidden = _isVerify;
	[_buttonHolderView addSubview:flagButton];
	
	
	UIButton *approveButton = [UIButton buttonWithType:UIButtonTypeCustom];
	approveButton.frame = CGRectMake(121.0, 0.0, 74.0, 74.0);
	[approveButton setBackgroundImage:[UIImage imageNamed:@"largeYay_nonActive"] forState:UIControlStateNormal];
	[approveButton setBackgroundImage:[UIImage imageNamed:@"largeYay_Active"] forState:UIControlStateHighlighted];
	[approveButton addTarget:self action:@selector(_goApprove) forControlEvents:UIControlEventTouchUpInside];
	approveButton.hidden = !_isVerify;
	[_buttonHolderView addSubview:approveButton];
	
	UIButton *dispproveButton = [UIButton buttonWithType:UIButtonTypeCustom];
	dispproveButton.frame = CGRectMake(222.0, 0.0, 74.0, 74.0);
	[dispproveButton setBackgroundImage:[UIImage imageNamed:@"largeNay_nonActive"] forState:UIControlStateNormal];
	[dispproveButton setBackgroundImage:[UIImage imageNamed:@"largeNay_Active"] forState:UIControlStateHighlighted];
	[dispproveButton addTarget:self action:@selector(_goDisprove) forControlEvents:UIControlEventTouchUpInside];
	dispproveButton.hidden = !_isVerify;
	[_buttonHolderView addSubview:dispproveButton];
	
	_avatarHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 325.0)];
	_avatarHolderView.clipsToBounds = YES;
	[_profileHolderView addSubview:_avatarHolderView];
	
	HONImageLoadingView *imageLoading2View = [[HONImageLoadingView alloc] initInViewCenter:_avatarHolderView];
	[_avatarHolderView addSubview:imageLoading2View];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Public APIs
- (void)showControls {
	_imageView.image = [_imageView.image applyBlurWithRadius:16.0 tintColor:[UIColor colorWithWhite:0.0 alpha:0.75] saturationDeltaFactor:1.0 maskImage:nil];
	
	_closeButton.hidden = NO;
	[UIView animateWithDuration:0.33 animations:^(void) {
		_buttonHolderView.alpha = 1.0;
	}];
	
	int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"preview_total"] intValue];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++total] forKey:@"preview_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if (total == 0) {
		_tutorialImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
		_tutorialImageView.userInteractionEnabled = YES;
		_tutorialImageView.hidden = YES;
		_tutorialImageView.alpha = 0.0;
		
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = _tutorialImageView.frame;
		[closeButton addTarget:self action:@selector(_goRemoveTutorial) forControlEvents:UIControlEventTouchDown];
		[_tutorialImageView addSubview:closeButton];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_tutorialImageView.alpha = 1.0;
		}];
		
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_tutorialImageView];
	}
}


#pragma mark - Navigation
- (void)_goDone {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Close"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
	
	BOOL isFriend = NO;
	if (![[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID) {
		for (HONUserVO *vo in [HONAppDelegate subscribeeList]) {
			if (vo.userID == _userVO.userID) {
				isFriend = YES;
				break;
			}
		}
	}
		
//	int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"preview_total"] intValue];
//	if (!isFriend && total < [HONAppDelegate profileSubscribeThreshold]) {
//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
//															message:[NSString stringWithFormat:@"Want to subscribe to @%@'s updates?", _userVO.username]
//														   delegate:self
//												  cancelButtonTitle:@"No"
//												  otherButtonTitles:@"Yes", nil];
//		[alertView setTag:3];
//		[alertView show];
//		
//	} else
		[self.delegate snapPreviewViewControllerClose:self];
}

- (void)_goUpvote {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Upvote"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	[self _upvoteChallenge:_opponentVO.userID];
	[self.delegate snapPreviewViewControllerUpvote:self opponent:_opponentVO forChallenge:_challengeVO];
	
	int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"like_total"] intValue];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++total] forKey:@"like_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if (total == 0 && [HONAppDelegate switchEnabledForKey:@"like_share"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SHARE Volley with your friends?"
															message:@"Get more subscribers now, tap OK."
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"OK", nil];
		[alertView setTag:4];
		[alertView show];
	}
}

- (void)_goProfile {
//	NSLog(@"USER:[%@]", _userVO.dictionary);
	
	[[Mixpanel sharedInstance] track:@"Volley Preview - User Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	_blurredImageView = [[UIImageView alloc] initWithImage:[HONImagingDepictor createBlurredScreenShot]];
	_blurredImageView.alpha = 0.0;
	[self.view addSubview:_blurredImageView];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blurredImageView.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
	
	_userProfileViewController = [[HONUserProfileViewController alloc] initWithBackground:_blurredImageView];
	_userProfileViewController.userID = _opponentVO.userID;
	[self.view addSubview:_userProfileViewController.view];
	_hasVisitedProfile = YES;
	
//	NSMutableString *avatarImageURL = [_opponentVO.avatarURL mutableCopy];
//	[avatarImageURL replaceOccurrencesOfString:@".jpg" withString:@"Large_640x1136.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [avatarImageURL length])];
//	[avatarImageURL replaceOccurrencesOfString:@"Large_640x1136Large_640x1136.jpg" withString:@"Large_640x1136.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [avatarImageURL length])];
//	NSLog(@"PROFILE LOADING:[%@]\n[%@]", _opponentVO.avatarURL, avatarImageURL);
//	
//	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//		_avatarImageView.image = image;
//		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
//			_avatarImageView.alpha = 1.0;
//		} completion:^(BOOL finished) {
//			_closeButton.hidden = NO;
//			[UIView animateWithDuration:0.33 animations:^(void) {
//				_buttonHolderView.alpha = 1.0;
//			}];
//		}];
//	};
//	
//	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"RECREATE_IMAGE_SIZES" object:[NSString stringWithFormat:@"%@Large_640x1136.jpg", avatarImageURL]];
//		
//		_closeButton.hidden = NO;
//		[UIView animateWithDuration:0.33 animations:^(void) {
//			_buttonHolderView.alpha = 1.0;
//		}];
//	};
//	
//	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -122.0, 320.0, 568.0)];
//	_avatarImageView.alpha = 0.0;
//	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:avatarImageURL] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
//							placeholderImage:nil
//									 success:imageSuccessBlock
//									 failure:imageFailureBlock];
//	[_avatarHolderView addSubview:_avatarImageView];
//	
//	UIImageView *verifiedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verifiedUser"]];
//	verifiedImageView.frame = CGRectOffset(verifiedImageView.frame, 114.0, 46.0);
//	verifiedImageView.hidden = ([HONAppDelegate ageForDate:_userVO.birthday] > 19);
//	[_avatarImageView addSubview:verifiedImageView];
//	
//	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
//	
//	_subscribersLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0, 350.0, 260.0, 28.0)];
//	_subscribersLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:24];
//	_subscribersLabel.textColor = [UIColor whiteColor];
//	_subscribersLabel.backgroundColor = [UIColor clearColor];
//	[_profileHolderView addSubview:_subscribersLabel];
//	
//	_subscribeesLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0, 390.0, 260.0, 28.0)];
//	_subscribeesLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:24];
//	_subscribeesLabel.textColor = [UIColor whiteColor];
//	_subscribeesLabel.backgroundColor = [UIColor clearColor];
//	[_profileHolderView addSubview:_subscribeesLabel];
//	
//	_volleysLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0, 430.0, 260.0, 28.0)];
//	_volleysLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:24];
//	_volleysLabel.textColor = [UIColor whiteColor];
//	_volleysLabel.backgroundColor = [UIColor clearColor];
//	[_profileHolderView addSubview:_volleysLabel];
//	
//	_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0, 470.0, 260.0, 28.0)];
//	_likesLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:24];
//	_likesLabel.textColor = [UIColor whiteColor];
//	_likesLabel.backgroundColor = [UIColor clearColor];
//	[_profileHolderView addSubview:_likesLabel];
//	
//	UIButton *subscribersButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	subscribersButton.frame = _subscribersLabel.frame;
//	[subscribersButton addTarget:self action:@selector(_goSubscribers) forControlEvents:UIControlEventTouchUpInside];
//	[_profileHolderView addSubview:subscribersButton];
//	
//	UIButton *subscribeesButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	subscribeesButton.frame = _subscribeesLabel.frame;
//	[subscribeesButton addTarget:self action:@selector(_goSubscribees) forControlEvents:UIControlEventTouchUpInside];
//	[_profileHolderView addSubview:subscribeesButton];
//	
//	UIButton *volleysButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	volleysButton.frame = _volleysLabel.frame;
//	[volleysButton addTarget:self action:@selector(_goVolleys) forControlEvents:UIControlEventTouchUpInside];
//	[_profileHolderView addSubview:volleysButton];
//	
//	[self _retrieveUser:_opponentVO.userID];
//	
//	
//	UIButton *verifiedButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	verifiedButton.frame = CGRectMake(0.0, 20.0, 44.0, 44.0);
//	[verifiedButton setBackgroundImage:[UIImage imageNamed:(_userVO.isVerified) ? @"verifyIcon_nonActive" : @"nonVerifyIcon_nonActive"] forState:UIControlStateNormal];
//	[verifiedButton setBackgroundImage:[UIImage imageNamed:(_userVO.isVerified) ? @"verifyIcon_Active" : @"nonVerifyIcon_Active"] forState:UIControlStateHighlighted];
////	[verifiedButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
//	
//	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	doneButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
//	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
//	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
//	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
//	
//	HONHeaderView *headerView = [[HONHeaderView alloc] initAsModalWithTitle:_userVO.username];
//	[headerView addSubview:verifiedButton];
//	[headerView addButton:doneButton];
//	headerView.alpha = 0.0;
//	[self.view addSubview:headerView];
//	
//	
//	_profileHolderView.hidden = NO;
//	[UIView animateWithDuration:0.33 animations:^(void) {
//		_buttonHolderView.alpha = 0.0;
//	} completion:^(BOOL finished) {
//		[UIView animateWithDuration:0.33 animations:^(void) {
//			headerView.alpha = 1.0;
//			_profileHolderView.alpha = 1.0;
//		}];
//	}];
//	
//	
//	BOOL isFriend = NO;
//	for (HONUserVO *vo in [HONAppDelegate subscribeeList]) {
//		if (vo.userID == _userVO.userID) {
//			isFriend = YES;
//			break;
//		}
//	}
//	
//	if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _userVO.userID) {
//		_subscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		_subscribeButton.frame = CGRectMake(0.0, 0.0, 95.0, 44.0);
//		[_subscribeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//		[_subscribeButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateHighlighted];
//		[_subscribeButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16.0]];
//		[_subscribeButton setTitle:(isFriend) ? @"Unfollow" : @"Follow" forState:UIControlStateNormal];
//		
//		[_subscribeButton addTarget:self action:(isFriend) ? @selector(_goUnsubscribe) : @selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
//		_subscribeButton.frame = CGRectMake(0.0, 0.0, (isFriend) ? 64.0 : 47.0, 44.0);
//		
//		UIButton *shareFooterButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		shareFooterButton.frame = CGRectMake(0.0, 0.0, 80.0, 44.0);
//		[shareFooterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//		[shareFooterButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateHighlighted];
//		[shareFooterButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontMedium] fontWithSize:16.0]];
//		[shareFooterButton setTitle:@"Share" forState:UIControlStateNormal];
//		[shareFooterButton addTarget:self action:@selector(_goShareUser) forControlEvents:UIControlEventTouchUpInside];
//		
//		UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		flagButton.frame = CGRectMake(0.0, 0.0, 31.0, 44.0);
//		[flagButton setTitleColor:[UIColor colorWithRed:0.733 green:0.380 blue:0.392 alpha:1.0] forState:UIControlStateNormal];
//		[flagButton setTitleColor:[UIColor colorWithRed:0.325 green:0.169 blue:0.174 alpha:1.0] forState:UIControlStateHighlighted];
//		[flagButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16.0]];
//		[flagButton setTitle:@"Flag" forState:UIControlStateNormal];
//		[flagButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
//		
//		UIToolbar *footerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 44.0, 320.0, 44.0)];
//		[footerToolbar setBarStyle:UIBarStyleBlackTranslucent];
//		[footerToolbar setItems:[NSArray arrayWithObjects:
//								 [[UIBarButtonItem alloc] initWithCustomView:_subscribeButton],
//								 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
//								 [[UIBarButtonItem alloc] initWithCustomView:shareFooterButton],
//								 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
//								 [[UIBarButtonItem alloc] initWithCustomView:flagButton], nil]];
//		[self.view addSubview:footerToolbar];
//	
//	}
//	
//	[self _retrieveChallenges];
}

- (void)_goFlag {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Flag"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:@"This person will be flagged for review"
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes, flag user", nil];
	
	[alertView setTag:0];
	[alertView show];
}

- (void)_goSubscribe {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Subscribe%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"friend", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:[NSString stringWithFormat:@"You will receive Volley updates from @%@", _userVO.username]
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:1];
	[alertView show];
}

- (void)_goUnsubscribe {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Unsubscribe"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"friend", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:[NSString stringWithFormat:@"You will no longer receive Volley updates from @%@", _userVO.username]
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:2];
	[alertView show];
}

- (void)_goShareUser {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Share"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Share on Twitter", @"Share on Instagram", nil];
	[actionSheet setTag:0];
	[actionSheet showInView:self.view];
}

- (void)_goApprove {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Approve"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Verify & follow user", @"Verify user only", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet setTag:1];
	[actionSheet showInView:self.view];
}

- (void)_goDisprove {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Disprove"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:[NSString stringWithFormat:@"This user does not look %d - %d", [HONAppDelegate ageRangeAsSeconds:NO].location, [HONAppDelegate ageRangeAsSeconds:NO].length], nil];
	
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet setTag:2];
	[actionSheet showInView:self.view];
}

- (void)_goRemoveTutorial {
	[UIView animateWithDuration:0.25 animations:^(void) {
		if (_tutorialImageView != nil) {
			_tutorialImageView.alpha = 0.0;
		}
	} completion:^(BOOL finished) {
		if (_tutorialImageView != nil) {
			[_tutorialImageView removeFromSuperview];
			_tutorialImageView = nil;
		}
	}];
}

- (void)_goTapHoldAlert {
	[[[UIAlertView alloc] initWithTitle:@"Tap and hold to view full screen!"
								message:@""
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}


- (void)_goSubscribers {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONFollowersViewController alloc] initWithUserID:_opponentVO.userID]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goSubscribees {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONFollowingViewController alloc] initWithUserID:_opponentVO.userID]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goVolleys {
	[_scrollView scrollRectToVisible:CGRectMake(0.0, _scrollView.frame.size.height, 320.0, _gridHolderView.frame.size.height) animated:YES];
}


#pragma mark - UI Presentation
- (void)_addEmoticon {
	HONEmotionVO *emotionVO = [self _latestEmotionVO];
	BOOL isEmotionFound = (emotionVO != nil);
	
	if (isEmotionFound) {
		UIImageView *emoticonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(1.0, 278.0, 43.0, 43.0)];
		[emoticonImageView setImageWithURL:[NSURL URLWithString:emotionVO.imageLargeURL] placeholderImage:nil];
		[_scrollView addSubview:emoticonImageView];
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(11.0 + (((int)isEmotionFound) * 32.0), 288.0, 250.0, 22.0)];
		subjectLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
		subjectLabel.textColor = [UIColor whiteColor];
		subjectLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		subjectLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.text = _newestChallengeVO.subjectName;
		[_scrollView addSubview:subjectLabel];
	}
}

- (void)_makeGrid {
	_profileGridView = [[HONUserProfileGridView alloc] initAtPos:498.0 forChallenges:_challenges asPrimaryOpponent:_opponentVO];
	_profileGridView.delegate = self;
	[_scrollView addSubview:_profileGridView];
	
	
	
	
	
	
//    _challengeImages = [NSMutableArray new];
//    NSInteger gridCount = 0;
//    for (HONChallengeVO *vo in _challenges) {
//        if( _userVO.userID == vo.creatorVO.userID ){
//            gridCount++;
//            NSMutableArray *dataArray = [NSMutableArray new];
//            [dataArray addObject:vo.creatorVO];
//            [dataArray addObject:vo];
//            [_challengeImages addObject:dataArray];
//        }
//        for (HONOpponentVO *challenger in vo.challengers) {
//            if( _userVO.userID == challenger.userID ){
//                gridCount++;
//                NSMutableArray *dataArray = [NSMutableArray new];
//                [dataArray addObject:challenger];
//                [dataArray addObject:vo];
//                [_challengeImages addObject:dataArray];
//            }
//        }
//    }
//	_gridHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 529.0, 320.0, kSnapThumbSize.height * (( (int) gridCount / 4) + 1))];
//	_gridHolderView.backgroundColor = [UIColor clearColor];
//	[_scrollView addSubview:_gridHolderView];
//	
//	_challengeCounter = 0;
//	for (HONChallengeVO *vo in _challenges) {
//        if( _userVO.userID == vo.creatorVO.userID ){
//            [self _makeGridElement:vo.creatorVO];
//        }
//        for (HONOpponentVO *challenger in vo.challengers) {
//            if( _userVO.userID == challenger.userID ){
//                [self _makeGridElement:challenger];
//            }
//        }
//	}
}

//-(void)_makeGridElement:(HONOpponentVO *)challenger {
//    CGPoint pos = CGPointMake(kSnapThumbSize.width * (_challengeCounter % 4), kSnapThumbSize.height * (_challengeCounter / 4));
//    
//    UIView *imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(pos.x, pos.y, kSnapThumbSize.width, kSnapThumbSize.height)];
//    [_gridHolderView addSubview:imageHolderView];
//    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapThumbSize.width, kSnapThumbSize.height)];
//    imageView.userInteractionEnabled = YES;
//    [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@Small_160x160.jpg", challenger.imagePrefix]] placeholderImage:nil];
//    [imageHolderView addSubview:imageView];
//    
//    UIButton *tapHoldButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    tapHoldButton.frame = imageView.frame;
//    [tapHoldButton addTarget:self action:@selector(_goTapHoldAlert) forControlEvents:UIControlEventTouchUpInside];
//    [imageHolderView addSubview:tapHoldButton];
//    _challengeCounter++;
//}

//-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
//	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
//		CGPoint touchPoint = [lpGestureRecognizer locationInView:_scrollView];
//		
//		HONChallengeVO *challengeVO = nil;
//		HONOpponentVO *opponentVO = nil;
//		
//		if (CGRectContainsPoint(_gridHolderView.frame, touchPoint)) {
//			int col = touchPoint.x / (kSnapThumbSize.width + 1.0);
//			int row = (touchPoint.y - _gridHolderView.frame.origin.y) / (kSnapThumbSize.height + 1.0);
//			
//            int idx = (row * 4) + col;
//            if(idx < [_challengeImages count]){
//                opponentVO = [_challengeImages objectAtIndex:idx][0];
//                challengeVO = [_challengeImages objectAtIndex:idx][1];
//            }
//		}
//		
//		if (opponentVO != nil) {
//			[[Mixpanel sharedInstance] track:@"Profile - Show Photo Detail"
//								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
//											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
//											  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
//											  [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username], @"opponent",
//											  nil]];
//			
//			_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithOpponent:opponentVO forChallenge:challengeVO asRoot:(_opponentVO.userID != opponentVO.userID)];
//			_snapPreviewViewController.delegate = self;
//			
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
//		}
//		
//	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
//		[_snapPreviewViewController showControls];
//	}
//}


#pragma mark - Data Tally
- (HONEmotionVO *)_emotionForParticipant:(HONOpponentVO *)opponentVO {
	NSLog(@"_emotionForParticipant:[%@]", opponentVO.subjectName);
	
	BOOL isEmotionFound = NO;
	HONEmotionVO *emotionVO;
	
	for (HONEmotionVO *vo in [HONAppDelegate composeEmotions]) {
//		NSLog(@"CHECKING:[%@]><[%@]", opponentVO.subjectName, vo.hastagName);
		if ([vo.hastagName isEqualToString:opponentVO.subjectName]) {
			emotionVO = [HONEmotionVO emotionWithDictionary:vo.dictionary];
			isEmotionFound = YES;
			break;
		}
	}
	
	if (!isEmotionFound) {
		for (HONEmotionVO *vo in [HONAppDelegate replyEmotions]) {
//			NSLog(@"CHECKING:[%@]><[%@]", opponentVO.subjectName, vo.hastagName);
			if ([vo.hastagName isEqualToString:opponentVO.subjectName]) {
				emotionVO = [HONEmotionVO emotionWithDictionary:vo.dictionary];
				isEmotionFound = YES;
				break;
			}
		}
	}
	
	return (emotionVO);
}

- (HONEmotionVO *)_latestEmotionVO {
	_newestChallengeVO = _challengeVO;
	
//	if ([_challenges count] > 0) {
//		_newestChallengeVO = (HONChallengeVO *)[_challenges lastObject];
//		HONOpponentVO *newestOpponentVO = (_userVO.userID == _newestChallengeVO.creatorVO.userID) ? _newestChallengeVO.creatorVO : nil;
//		NSLog(@"newestChallenge:[%@]", _newestChallengeVO.dictionary);
//		
//		for (HONOpponentVO *vo in _newestChallengeVO.challengers) {
//			NSLog(@"opponent:[%@]", vo.dictionary);
//			if (_userVO.userID == vo.userID) {
//				newestOpponentVO = vo;
//				break;
//			}
//		}
//	}
	
	BOOL isEmotionFound = NO;
	HONEmotionVO *emotionVO;
	for (HONEmotionVO *vo in [HONAppDelegate composeEmotions]) {
		if ([vo.hastagName isEqualToString:_newestChallengeVO.subjectName]) {
			emotionVO = [HONEmotionVO emotionWithDictionary:vo.dictionary];
			isEmotionFound = YES;
			break;
		}
	}
	
	for (HONEmotionVO *vo in [HONAppDelegate replyEmotions]) {
		if ([vo.hastagName isEqualToString:_newestChallengeVO.subjectName]) {
			emotionVO = [HONEmotionVO emotionWithDictionary:vo.dictionary];
			isEmotionFound = YES;
			break;
		}
	}
	
	return ((isEmotionFound) ? emotionVO : nil);
}


#pragma mark - GridView Delegates
- (void)participantGridView:(HONBasicParticipantGridView *)participantGridView showPreview:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Profile - Show Photo Detail"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username], @"opponent",
									  nil]];
	
	_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithOpponent:opponentVO forChallenge:challengeVO asRoot:(_opponentVO.userID != opponentVO.userID)];
	_snapPreviewViewController.delegate = self;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
}

- (void)participantGridView:(HONBasicParticipantGridView *)participantGridView showProfile:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Show Profile%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d", opponentVO.userID], @"userID", nil]];
	
	if ([HONAppDelegate hasTakenSelfie]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
		
		HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithBackground:nil];
		userPofileViewController.userID = opponentVO.userID;
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
		[navigationController setNavigationBarHidden:YES];
		[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_noSelfie_t", nil)
															message:NSLocalizedString(@"alert_noSelfie_m", nil)
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"Take Photo", nil];
		[alertView setTag:2];
		[alertView show];
	}
}


#pragma mark - SnapPreview Delegates
- (void)snapPreviewViewControllerClose:(HONSnapPreviewViewController *)snapPreviewViewController {
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
}

- (void)snapPreviewViewControllerUpvote:(HONSnapPreviewViewController *)snapPreviewViewController opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_opponentVO = opponentVO;
	
	[[Mixpanel sharedInstance] track:@"Volley Preview - Upvote"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
	
	UIImageView *heartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heartAnimation"]];
	heartImageView.frame = CGRectOffset(heartImageView.frame, 4.0, ([UIScreen mainScreen].bounds.size.height * 0.5) - 43.0);
	[self.view addSubview:heartImageView];
	
	[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		heartImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[heartImageView removeFromSuperview];
	}];
	
	[self _upvoteChallenge:_opponentVO.userID];
}

- (void)snapPreviewViewControllerFlag:(HONSnapPreviewViewController *)snapPreviewViewController opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_opponentVO = opponentVO;
	
	[[Mixpanel sharedInstance] track:@"Volley Preview - Flag"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:@"This person will be flagged for review"
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes, flag user", nil];
	
	[alertView setTag:0];
	[alertView show];
	
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Flag %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
										  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
			[self _flagUser:_opponentVO.userID];
			[self.delegate snapPreviewViewControllerFlag:self opponent:_opponentVO forChallenge:_challengeVO];
		}
	
	} else if (alertView.tag == 1) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Subscribe %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		if (buttonIndex == 1) {
			[self _addFriend:_userVO.userID];
			[_subscribeButton setTitle:@"Unfollow" forState:UIControlStateNormal];
			_subscribeButton.frame = CGRectMake(0.0, 0.0, 64.0, 44.0);
			[_subscribeButton removeTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
			[_subscribeButton addTarget:self action:@selector(_goUnsubscribe) forControlEvents:UIControlEventTouchUpInside];
		}
	
	} else if (alertView.tag == 2) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Unsubscribe %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
			[self _removeFriend:_userVO.userID];
			[_subscribeButton setTitle:@"Follow" forState:UIControlStateNormal];
			_subscribeButton.frame = CGRectMake(0.0, 0.0, 47.0, 44.0);
			[_subscribeButton removeTarget:self action:@selector(_goUnsubscribe) forControlEvents:UIControlEventTouchUpInside];
			[_subscribeButton addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		}
	
	} else if (alertView.tag == 3) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Close Subscribe %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		if (buttonIndex == 1) {
			[self _addFriend:_userVO.userID];
			[_subscribeButton setTitle:@"Unfollow" forState:UIControlStateNormal];
//			[_subscribeButton addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		}
		
		[self.delegate snapPreviewViewControllerClose:self];
	
	} else if (alertView.tag == 4) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Share %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SELF" object:(_avatarImageView.image.size.width >= 1936.0) ? [HONImagingDepictor scaleImage:_avatarImageView.image toSize:CGSizeMake(960.0, 1280.0)] : _avatarImageView.image];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[[NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"]], [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]]],
																									@"image"			: _avatarImageView.image,
																									@"url"				: @"",
																									@"mp_event"			: @"Volley Preview - Share",
																									@"view_controller"	: self}];
		}
	}
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 1) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - %@", (buttonIndex == 0) ? @"Approve & Follow" : (buttonIndex == 1) ? @"Approve" : @" Cancel"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
		
		if (buttonIndex == 0) {
			[self _addFriend:_opponentVO.userID];
			[self _verifyUser:_opponentVO.userID asLegit:YES];
			
		} else if (buttonIndex == 1) {
			[self _verifyUser:_opponentVO.userID asLegit:YES];
		}
		
		[self.delegate snapPreviewViewControllerClose:self];
		
	} else if (actionSheet.tag == 2) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Disprove %@", (buttonIndex == 0) ? @"Confirm" : @"Cancel"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
		
		if (buttonIndex == 0) {
			[[[UIAlertView alloc] initWithTitle:@""
										message:[NSString stringWithFormat:@"@%@ has been flagged & notified!", _opponentVO.username]
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
			
			[self _verifyUser:_opponentVO.userID asLegit:NO];
		}
		
		[self.delegate snapPreviewViewControllerClose:self];
	}
}

@end