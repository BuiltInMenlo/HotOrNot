//
//  HONComposeViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/6/13 @ 12:01 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <AWSiOSSDKv2/AWSS3.h>
#import <AWSiOSSDKv2/AWSS3TransferManager.h>
#import <AWSiOSSDKv2/S3.h>

#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

#import "UIImage+fixOrientation.h"
#import "UIImage+ImageEffects.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+Operations.h"
#import "NSMutableDictionary+Replacements.h"
#import "NSString+DataTypes.h"
#import "NSString+Formatting.h"

#import "ImageFilter.h"
#import "MBProgressHUD.h"
#import "PCCandyStorePurchaseController.h"
#import "TSTapstream.h"

#import "HONComposeViewController.h"
#import "HONCameraOverlayView.h"
#import "HONStoreProductsViewController.h"
#import "HONAnimatedBGsViewController.h"
#import "HONComposeSubmitViewController.h"
#import "HONStoreTransactionObserver.h"
#import "HONTrivialUserVO.h"
#import "HONHeaderView.h"
#import "HONStickerSummaryView.h"
#import "HONStickerButtonsPickerView.h"

@interface HONComposeViewController () <HONAnimatedBGsViewControllerDelegate, HONCameraOverlayViewDelegate, HONStickerButtonsPickerViewDelegate, HONStickerSummaryViewDelegate, HONStoreProductsViewControllerDelegate, PCCandyStorePurchaseControllerDelegate>
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, assign, readonly) HONSelfieSubmitType selfieSubmitType;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONUserClubVO *userClubVO;
@property (nonatomic, strong) HONTrivialUserVO *trivialUserVO;
@property (nonatomic, strong) HONContactUserVO *contactUserVO;
@property (nonatomic, strong) NSMutableArray *selectedUsers;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONCameraOverlayView *cameraOverlayView;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) HONStickerSummaryView *stickerSummaryView;
@property (nonatomic, strong) HONStickerButtonsPickerView *stickerButtonsPickerView;
@property (nonatomic, strong) UIImage *processedImage;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *fileURL;
@property (nonatomic, strong) NSMutableDictionary *submitParams;
@property (nonatomic) BOOL isUploadComplete;
@property (nonatomic) BOOL isBlurred;
@property (nonatomic) int uploadCounter;
@property (nonatomic) int selfieAttempts;
@property (nonatomic, strong) HONStoreTransactionObserver *storeTransactionObserver;
@property (nonatomic, strong) AWSS3PutObjectRequest *por1;
@property (nonatomic, strong) AWSS3PutObjectRequest *por2;
@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadReq1;
@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadReq2;

@property (nonatomic, strong) NSMutableArray *subjectNames;
@property (nonatomic, strong) NSMutableArray *selectedEmotions;
@property (nonatomic, strong) NSMutableArray *emotionsPickerViews;
@property (nonatomic, strong) NSMutableArray *emotionsPickerButtons;
@property (nonatomic, strong) UIView *emotionsPickerHolderView;
@property (nonatomic, strong) UIView *tabButtonsHolderView;
@property (nonatomic, strong) UIImageView *bgSelectImageView;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIButton *cameraBackButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *nextButton;

@property (nonatomic, strong) UIImageView *maskImageView;
@property (nonatomic, strong) UIImageView *filteredImageView;
@property (nonatomic) CGPoint prevPt;
@property (nonatomic) CGPoint currPt;
@end


@implementation HONComposeViewController

- (id)init {
	if ((self = [super init])) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"STATUS - enter_step_0"];
		
		_totalType = HONStateMitigatorTotalTypeCompose;
		_viewStateType = HONStateMitigatorViewStateTypeCompose;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_reloadEmotionPicker:)
													 name:@"RELOAD_EMOTION_PICKER" object:nil];
		
		_selfieAttempts = 0;
		_filename = [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], [[HONClubAssistant sharedInstance] rndCoverImageURL]];
		
		_selectedEmotions = [NSMutableArray array];
		_subjectNames = [NSMutableArray array];
		_emotionsPickerViews = [NSMutableArray array];
		_emotionsPickerButtons = [NSMutableArray array];
	}
	
	return (self);
}

- (void)dealloc {
	_cameraOverlayView.delegate = nil;
	
	[super destroy];
}

- (id)initWithContact:(HONContactUserVO *)contactUserVO {
	NSLog(@"%@ - initWithContact", [self description]);
	if ((self = [self init])) {
		_contactUserVO = contactUserVO;
		_selfieSubmitType = HONSelfieSubmitTypeSearchContact;
	}
	
	return (self);
}

- (id)initWithUser:(HONTrivialUserVO *)trivialUserVO {
	NSLog(@"%@ - initWithUser", [self description]);
	if ((self = [self init])) {
		_trivialUserVO = trivialUserVO;
		_selfieSubmitType = HONSelfieSubmitTypeSearchUser;
	}
	
	return (self);
}

- (id)initWithClub:(HONUserClubVO *)clubVO {
	NSLog(@"%@ - initWithClub:[%d] (%@)", [self description], clubVO.clubID, clubVO.clubName);
	
	if ((self = [self init])) {
		_userClubVO = clubVO;
		_selfieSubmitType = HONSelfieSubmitTypeReply;
	}
	
	return (self);
}


- (id)initAsNewStatusUpdate {
	NSLog(@"%@ - initAsNewChallenge", [self description]);
	if ((self = [self init])) {
		_selfieSubmitType = HONSelfieSubmitTypeCreate;
	}
	
	return (self);
}


#pragma mark - Data Calls
- (void)_submitReplyStatusUpdate {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", @"Loading…");
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kProgressHUDMinDuration;
	_progressHUD.taskInProgress = YES;
	
	_selectedUsers = [NSMutableArray array];
	_selectedContacts = [NSMutableArray array];
	
	__block NSString *names = @"";
	NSMutableArray *participants = [NSMutableArray array];
	
	NSLog(@"activeMembers:%@", _userClubVO.activeMembers);
	NSLog(@"pendingMembers:%@", _userClubVO.pendingMembers);
	
	[_userClubVO.activeMembers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
		NSLog(@"activeMembers:%@", vo.dictionary);
		[_selectedUsers addObject:vo];
		[participants addObject:vo.username];
		names = [names stringByAppendingFormat:@"%@, ", vo.username];
	}];
	
	[_userClubVO.pendingMembers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
		NSLog(@"pendingMembers:%@", vo.dictionary);
		
		if ([vo.altID length] > 0)
			[_selectedContacts addObject:[HONContactUserVO contactFromTrivialUserVO:vo]];
		
		else
			[_selectedUsers addObject:vo];
		
		[participants addObject:vo.username];
		names = [names stringByAppendingFormat:@"%@, ", vo.username];
	}];
	
	names = [names stringByTrimmingFinalSubstring:@", "];
	
	NSLog(@"_selectedUsers:%@", _selectedUsers);
	NSLog(@"_selectedContacts:%@", _selectedContacts);
	
	NSLog(@"*^*|~|*|~|*|~|*|~|*|~|*|~| CLUB -=- (CREATE) |~|*|~|*|~|*|~|*|~|*|~|*^*");
	NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}];
	[dict setValue:[NSString stringWithFormat:@"%d_%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue], [NSDate elapsedUTCSecondsSinceUnixEpoch]] forKey:@"name"];
	_userClubVO = [HONUserClubVO clubWithDictionary:dict];
	
	[[HONAPICaller sharedInstance] createClubWithTitle:_userClubVO.clubName withDescription:_userClubVO.blurb withImagePrefix:_userClubVO.coverImagePrefix completion:^(NSDictionary *result) {
		_userClubVO = [HONUserClubVO clubWithDictionary:result];
		[_submitParams replaceObject:[@"" stringFromInt:_userClubVO.clubID] forExistingKey:@"club_id"];
		
		NSLog(@"*^*|~|*|~|*|~|*|~|*|~|*|~| SUBMITTING -=- [%@] |~|*|~|*|~|*|~|*|~|*|~|*^*", _submitParams);
		[[HONAPICaller sharedInstance] submitClubPhotoWithDictionary:_submitParams completion:^(NSDictionary *result) {
			if ([[result objectForKey:@"result"] isEqualToString:@"fail"]) {
				if (_progressHUD == nil)
					_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
				_progressHUD.minShowTime = kProgressHUDMinDuration;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
				_progressHUD.labelText = @"Error!";
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
				_progressHUD = nil;
				
			} else {
//				HONChallengeVO *challengeVO = [HONChallengeVO challengeWithDictionary:result];
//				[[HONClubAssistant sharedInstance] writeStatusUpdateAsSeenWithID:challengeVO.challengeID onCompletion:^(NSDictionary *result) {
				
					//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Send Club Reply Invites"
//													   withProperties:[self _trackingProps]];
				
					[[HONClubAssistant sharedInstance] sendClubInvites:_userClubVO toInAppUsers:_selectedUsers ToNonAppContacts:_selectedContacts onCompletion:^(BOOL success) {
						if (_progressHUD != nil) {
							[_progressHUD hide:YES];
							_progressHUD = nil;
						}
						
						[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:^(void) {
							[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
							[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUB_TIMELINE" object:@"Y"];
						}];
					}];
//				}];
			}
		}];
	}];
}


- (void)_uploadPhotos {
	_isUploadComplete = NO;
	_uploadCounter = 0;
	
	NSString *coords = [@"" stringFromCLLocation:[[HONDeviceIntrinsics sharedInstance] deviceLocation]];
	coords = [coords stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	_filename = [NSString stringWithFormat:@"%@/%@_%@_%d", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], [[[HONDeviceIntrinsics sharedInstance] identifierForVendorWithoutSeperators:YES] lowercaseString], coords, [NSDate elapsedUTCSecondsSinceUnixEpoch]];
	NSLog(@"FILE PATH:%@", _filename);
	
	UIImage *largeImage = _processedImage;//[[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:_processedImage toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)];
	UIImage *tabImage = _processedImage;//[[HONImageBroker sharedInstance] cropImage:largeImage toRect:CGRectFromSize(CGSizeMult(kSnapTabSize, 2.0))];// CGRectMake(0.0, 0.0, kSnapTabSize.width * 2.0, kSnapTabSize.height * 2.0)];
	
	NSString *largeURL = [[[_filename componentsSeparatedByString:@"/"] lastObject] stringByAppendingString:kSnapLargeSuffix];
	NSString *tabURL = [[[_filename componentsSeparatedByString:@"/"] lastObject] stringByAppendingString:kSnapLargeSuffix];
	
	
	BFTask *task = [BFTask taskWithResult:nil];
	[[task continueWithBlock:^id(BFTask *task) {
		NSData *data1 = UIImageJPEGRepresentation(largeImage, [HONAppDelegate compressJPEGPercentage]);
		[data1 writeToURL:[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:kSnapLargeSuffix]] atomically:YES];
		
		NSData *data2 = UIImageJPEGRepresentation(tabImage, [HONAppDelegate compressJPEGPercentage]);
		[data2 writeToURL:[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:kSnapTabSuffix]] atomically:YES];
		
		return (nil);
		
	}] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
		// done
//		NSLog(@"[BFTask mainThreadExecutor");
		return (nil);
	}];
	
	
	_uploadReq1 = [AWSS3TransferManagerUploadRequest new];
	_uploadReq1.bucket = @"hotornot-challenges";
	_uploadReq1.contentType = @"image/jpeg";
	_uploadReq1.key = largeURL;
	_uploadReq1.body = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:kSnapLargeSuffix]];
	_uploadReq1.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
		dispatch_sync(dispatch_get_main_queue(), ^{
//			NSLog(@"%lld", totalBytesSent);
		});
	};

	_uploadReq2 = [AWSS3TransferManagerUploadRequest new];
	_uploadReq2.bucket = @"hotornot-challenges";
	_uploadReq2.contentType = @"image/jpeg";
	_uploadReq2.key = tabURL;
	_uploadReq2.body = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:kSnapTabSuffix]];
	_uploadReq2.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
		dispatch_sync(dispatch_get_main_queue(), ^{
//			NSLog(@"%lld", totalBytesSent);
		});
	};

	
	AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
	[[transferManager upload:_uploadReq1] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
		if (task.error != nil) {
			if (task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused) {
				// failed
//				NSLog(@"[AWSS3TransferManager FAILED:[%@]", task.error.description);
			}
			
		} else {
//			NSLog(@"[AWSS3TransferManager COMPLETE:[%@]", _uploadReq1.key);
			_uploadReq1 = nil;
			if (++_uploadCounter == 2) {
				// complete
				
				_isUploadComplete = YES;
				if (_isUploadComplete) {
					if (_progressHUD != nil) {
						[_progressHUD hide:YES];
						_progressHUD = nil;
					}
			
					[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:_filename forBucketType:HONS3BucketTypeSelfies completion:^(NSObject *result) {
						if (_progressHUD != nil) {
							[_progressHUD hide:YES];
							_progressHUD = nil;
						}
					}];
				}
			}
		}
		
		return (nil);
	}];
	
	[[transferManager upload:_uploadReq2] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
		if (task.error != nil) {
			if (task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused) {
				// failed
//				NSLog(@"[AWSS3TransferManager FAILED:[%@]", task.error.description);
			}
			
		} else {
//			NSLog(@"[AWSS3TransferManager COMPLETE:[%@]", _uploadReq2.key);
			_uploadReq2 = nil;
			if (++_uploadCounter == 2) {
				// complete
				
				_isUploadComplete = YES;
				if (_isUploadComplete) {
					if (_progressHUD != nil) {
						[_progressHUD hide:YES];
						_progressHUD = nil;
					}
					
					[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:_filename forBucketType:HONS3BucketTypeSelfies completion:^(NSObject *result) {
						if (_progressHUD != nil) {
							[_progressHUD hide:YES];
							_progressHUD = nil;
						}
					}];
				}
			}
		}
		
		return (nil);
	}];

	
	
//	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
//	
//	@try {
//		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-challenges"]];
//		_por1 = [[S3PutObjectRequest alloc] initWithKey:largeURL inBucket:@"hotornot-challenges"];
//		_por1.delegate = self;
//		_por1.contentType = @"image/gif";
//		_por1.data = UIImageJPEGRepresentation(largeImage, [HONAppDelegate compressJPEGPercentage]);
//		[s3 putObject:_por1];
//		
//		_por2 = [[S3PutObjectRequest alloc] initWithKey:tabURL inBucket:@"hotornot-challenges"];
//		_por2.delegate = self;
//		_por2.contentType = @"image/gif";
//		_por2.data = UIImageJPEGRepresentation(tabImage, [HONAppDelegate compressJPEGPercentage] * 0.85);
//		[s3 putObject:_por2];
//		
//	} @catch (AmazonClientException *exception) {
//		NSLog(@"AWS FAIL:[%@]", exception.message);
//		
//		if (_progressHUD == nil)
//			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
//		
//		_progressHUD.minShowTime = kProgressHUDMinDuration;
//		_progressHUD.mode = MBProgressHUDModeCustomView;
//		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
//		_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
//		[_progressHUD show:NO];
//		[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
//		_progressHUD = nil;
//	}
}

- (void)_modifySubmitParamsAndSubmit:(NSArray *)subjectNames {
//	if ([subjectNames count] == 0) {
	if (![[HONGeoLocator sharedInstance] isWithinOrthodoxClub]) {
		[[[UIAlertView alloc] initWithTitle:@"Not in range!"
									message:[NSString stringWithFormat:@"Must be within %@ miles", [[[NSUserDefaults standardUserDefaults] objectForKey:@"orthodox_club"] objectForKey:@"radius"]]
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
		
	} else {
		_isPushing = YES;
		
		NSError *error;
		NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:subjectNames options:0 error:&error]
													 encoding:NSUTF8StringEncoding];
		
		_submitParams = [@{@"user_id"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
						   @"img_url"		: _filename,
						   @"club_id"		: [@"" stringFromInt:(_selfieSubmitType == HONSelfieSubmitTypeReply) ? _userClubVO.clubID : 0],
						   @"owner_id"		: [@"" stringFromInt:(_selfieSubmitType == HONSelfieSubmitTypeReply) ? _userClubVO.ownerID : 0],
						   @"subject"		: @"",
						   @"subjects"		: jsonString,
						   @"challenge_id"	: [@"" stringFromInt:0],
						   @"recipients"	: (_trivialUserVO != nil) ? [@"" stringFromInt:_trivialUserVO.userID] : (_contactUserVO != nil) ? (_contactUserVO.isSMSAvailable) ? _contactUserVO.mobileNumber : _contactUserVO.email : @"",
						   @"api_endpt"		: kAPICreateChallenge} mutableCopy];
		NSLog(@"|:|◊≈◊~~◊~~◊≈◊~~◊~~◊≈◊| SUBMIT PARAMS:[%@]", _submitParams);

		
//		if (_selfieSubmitType == HONSelfieSubmitTypeCreate) {
			//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Friend Picker"];
//			[self.navigationController pushViewController:[[HONComposeSubmitViewController alloc] initWithSubmitParameters:_submitParams] animated:NO];
 
//		} else {
			//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Submit Reply"
//												 withUserClub:_userClubVO];
			
//			[self _submitReplyStatusUpdate];
			
			
			NSLog(@"*^*|~|*|~|*|~|*|~|*|~|*|~| SUBMITTING -=- [%@] |~|*|~|*|~|*|~|*|~|*|~|*^*", _submitParams);
			[[HONAPICaller sharedInstance] submitClubPhotoWithDictionary:_submitParams completion:^(NSDictionary *result) {
				if ([[result objectForKey:@"result"] isEqualToString:@"fail"]) {
					if (_progressHUD == nil)
						_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
					_progressHUD.minShowTime = kProgressHUDMinDuration;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
					_progressHUD.labelText = @"Error!";
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
					_progressHUD = nil;
					
				} else {
					//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Send Club Reply Invites"
//													   withProperties:[self _trackingProps]];
					
					[[HONClubAssistant sharedInstance] sendClubInvites:_userClubVO toInAppUsers:_selectedUsers ToNonAppContacts:_selectedContacts onCompletion:^(BOOL success) {
						if (_progressHUD != nil) {
							[_progressHUD hide:YES];
							_progressHUD = nil;
						}
						
						[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:^(void) {
							[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
							[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUB_TIMELINE" object:@"Y"];
						}];
					}];
				}
			}];
//		}
	}
}

- (void)_cancelUpload {
	_isUploadComplete = NO;
	_uploadCounter = 0;
	
	if (_por1 != nil) {
		_por1 = nil;
	}
	
	if (_por2 != nil) {
		_por2 = nil;
	}
}

- (void)_uploadTimeout {
	[self _cancelUpload];
	
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	
	_progressHUD.minShowTime = kProgressHUDMinDuration;
	_progressHUD.mode = MBProgressHUDModeCustomView;
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
	_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
	[_progressHUD show:NO];
	[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
	_progressHUD = nil;
}


#pragma mark - Data Handling
- (NSDictionary *)_trackingProps {
	NSMutableArray *users = [NSMutableArray array];
	for (HONTrivialUserVO *vo in _selectedUsers)
		[users addObject:[[HONAnalyticsReporter sharedInstance] propertyForTrivialUser:vo]];
	
	NSMutableArray *contacts = [NSMutableArray array];
	for (HONContactUserVO *vo in _selectedContacts)
		[contacts addObject:[[HONAnalyticsReporter sharedInstance] propertyForContactUser:vo]];
	
	NSMutableDictionary *props = [NSMutableDictionary dictionary];
	[props setValue:[[HONAnalyticsReporter sharedInstance] propertyForUserClub:_userClubVO] forKey:@"clubs"];
	[props setValue:users forKey:@"members"];
	[props setValue:contacts forKey:@"contacts"];
	
	return ([props copy]);
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	if (touch.tapCount == 2) {
		if (_maskImageView != nil) {
			[_maskImageView removeFromSuperview];
			_maskImageView = nil;
		}
	}
	
	if (_maskImageView == nil) {
		_maskImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_maskImageView.frame = CGRectInset(_maskImageView.frame, -37.0, -68.0);
		_maskImageView.frame = CGRectOffset(_maskImageView.frame, 25.0, 20.0);
	}
	
	[self.view addSubview:_maskImageView];
	
	_prevPt = [touch locationInView:self.view];
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	_currPt = [touch locationInView:self.view];
	
	UIGraphicsBeginImageContext([UIScreen mainScreen].bounds.size);
	[_maskImageView.image drawInRect:[UIScreen mainScreen].bounds];
	CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
	CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 32.0);
	CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
	CGContextBeginPath(UIGraphicsGetCurrentContext());
	CGContextMoveToPoint(UIGraphicsGetCurrentContext(), _prevPt.x, _prevPt.y);
	CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), _currPt.x, _currPt.y);
	CGContextStrokePath(UIGraphicsGetCurrentContext());
	
	_maskImageView.frame = [UIScreen mainScreen].bounds;
	_maskImageView.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	_prevPt = _currPt;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	
	[_maskImageView removeFromSuperview];
	[[HONViewDispensor sharedInstance] maskView:_filteredImageView withMask:_maskImageView.image];
}



#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor blackColor];
	
	_isBlurred = false;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
	
	
	
	_emotionsPickerHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 221.0, 320.0, 221.0)];
//	[self.view addSubview:_emotionsPickerHolderView];
	
	_tabButtonsHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 44.0, 320.0, 44.0)];
//	[self.view addSubview:_tabButtonsHolderView];
	
	for (int i=0; i<5; i++) {
		HONStickerButtonsPickerView *pickerView = [[HONStickerButtonsPickerView alloc] initWithFrame:CGRectFromSize(CGSizeMake(320.0, _emotionsPickerHolderView.frame.size.height)) asGroupIndex:i];
		[_emotionsPickerViews addObject:pickerView];
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectMake(i * 64.0, 0.0, 64.0, 44.0);
		[button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"stickerTab-%02d_nonActive", (i+1)]] forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"stickerTab-%02d_Active", (i+1)]] forState:UIControlStateHighlighted];
		[button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"stickerTab-%02d_Selected", (i+1)]] forState:UIControlStateSelected];
		[button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"stickerTab-%02d_Selected", (i+1)]] forState:(UIControlStateHighlighted|UIControlStateSelected)];
		[button addTarget:self action:@selector(_goGroup:) forControlEvents:UIControlEventTouchUpInside];
		[button setSelected:(i == 0)];
		[button setTag:i];
		[_tabButtonsHolderView addSubview:button];
	}
	
	_stickerSummaryView = [[HONStickerSummaryView alloc] initAtPosition:CGPointMake(0.0, 297.0) withHeight:50.0];
	_stickerSummaryView.delegate = self;
//	[self.view addSubview:_stickerSummaryView];
	
	_stickerButtonsPickerView = (HONStickerButtonsPickerView *)[_emotionsPickerViews firstObject];
	_stickerButtonsPickerView.delegate = self;
	[_stickerButtonsPickerView cacheAllStickerContent];
	[_emotionsPickerHolderView addSubview:_stickerButtonsPickerView];
	
	__block NSMutableArray *cgIDs = [NSMutableArray array];
	[[[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypePaid] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSDictionary *dict = (NSDictionary *)obj;
		NSString *contentGroupID = [dict objectForKey:@"cg_id"];
		
		if (![cgIDs containsObject:contentGroupID]) {
			[cgIDs addObject:contentGroupID];
			if ([[HONStickerAssistant sharedInstance] isStickerPakPurchasedWithContentGroupID:contentGroupID])
				[_stickerButtonsPickerView appendPurchasedStickersWithContentGroupID:contentGroupID];
		}
	}];
	
	_previewImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
	_previewImageView.frame = CGRectInset(_previewImageView.frame, -37.0, -68.0);
	_previewImageView.frame = CGRectOffset(_previewImageView.frame, 25.0, 20.0);
	[self.view addSubview:_previewImageView];
	
	_filteredImageView = [[UIImageView alloc] initWithFrame:_previewImageView.frame];
//	_filteredImageView.frame = CGRectInset(_filteredImageView.frame, -37.0, -68.0);
//	_filteredImageView.frame = CGRectOffset(_filteredImageView.frame, 25.0, 20.0);
	[self.view addSubview:_filteredImageView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"header_compose", @"Preview")];
	[_headerView removeBackground];
	_headerView.hidden = YES;
	[self.view addSubview:_headerView];
	
	
	_cameraBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_cameraBackButton.frame = CGRectMake(0.0, 20.0, 44.0, 44.0);
	[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"cameraBackButton_nonActive"] forState:UIControlStateNormal];
	[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"cameraBackButton_Active"] forState:UIControlStateHighlighted];
	[_cameraBackButton addTarget:self action:@selector(_goCamera) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:_cameraBackButton];
	
	
	_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 44.0, 320.0, 44.0);
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"cameraSubmitButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"cameraSubmitButton_Active"] forState:UIControlStateHighlighted];
	[_submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	_submitButton.hidden = YES;
	[self.view addSubview:_submitButton];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_panGestureRecognizer.enabled = YES;
	[self showImagePickerForSourceType:([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:animated:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
	
	[_nextButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Navigation
- (void)_goCancel {
	NSLog(@"[*:*] _goCancel");
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"STATUS - exit"];
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Cancel"];
	[self _cancelUpload];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	[self dismissViewControllerAnimated:NO completion:^(void) {
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:^(void) {
		}];
	}];
}

- (void)_goSubmit {
	_isPushing = YES;
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"STATUS - submit"];
	[self _modifySubmitParamsAndSubmit:_subjectNames];
}

- (void)_goGroup:(id)sender {
	UIButton *button = (UIButton *)sender;
	
	int groupIndex = (int)button.tag;
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Change Emotion Group"
// 									   withProperties:@{@"index"	: [@"" stringFromInt:groupIndex]}];
	
	[self _changeToStickerGroupIndex:groupIndex];
}

- (void)_goCamera {
	[self showImagePickerForSourceType:([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)_goDelete {
//	HONEmotionVO *emotionVO = (HONEmotionVO *)[_selectedEmotions lastObject];
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Sticker Deleted"
//										  withEmotion:emotionVO];
	
	if ([_subjectNames count] > 0)
		[_subjectNames removeLastObject];
	
	if ([_subjectNames count] == 0) {
		[_subjectNames removeAllObjects];
		_subjectNames = nil;
		_subjectNames = [NSMutableArray array];
	}
	
//	[_composeDisplayView removeLastEmotion];
	[_headerView transitionTitle:([_subjectNames count] > 0) ? [_subjectNames lastObject] : @"Create"];
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	[super _goPanGesture:gestureRecognizer];
	
	if ([gestureRecognizer velocityInView:self.view].y >= 2000 || [gestureRecognizer velocityInView:self.view].x >= 2000) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Dismiss SWIPE"];
		
		[self _cancelUpload];
		[self dismissViewControllerAnimated:NO completion:^(void) {
		}];
	}
	
	if ([gestureRecognizer velocityInView:self.view].x <= -2000 && !_isPushing) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Next SWIPE"];
		[self _modifySubmitParamsAndSubmit:_subjectNames];
	}
}


#pragma mark - Notifications
- (void)_reloadEmotionPicker:(NSNotification *)notification {
//	HONEmotionsPickerView *pickerView = (HONEmotionsPickerView *)[_emotionsPickerViews firstObject];
//	[pickerView reload];
}


#pragma mark - UI Presentation
- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
	if (self.imagePickerController != nil)
		self.imagePickerController = nil;
	
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
	imagePickerController.view.backgroundColor = [UIColor whiteColor];
	imagePickerController.sourceType = sourceType;
	imagePickerController.delegate = self;
	
	if (sourceType == UIImagePickerControllerSourceTypeCamera) {
		float scale = ([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? ([[HONDeviceIntrinsics sharedInstance] isIOS8]) ? 1.65f : 1.55f : 1.25f;
		
		imagePickerController.showsCameraControls = NO;
		imagePickerController.cameraViewTransform = CGAffineTransformMakeTranslation(24.0, 90.0);
		imagePickerController.cameraViewTransform = CGAffineTransformScale(imagePickerController.cameraViewTransform, scale, scale);
		imagePickerController.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		
		_cameraOverlayView = [[HONCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_cameraOverlayView.delegate = self;
		imagePickerController.cameraOverlayView = _cameraOverlayView;
		
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	}
	
	self.imagePickerController = imagePickerController;
	[self presentViewController:self.imagePickerController animated:NO completion:^(void) {
	}];
}

- (void)_changeToStickerGroupIndex:(int)groupIndex {
	if (groupIndex != 4) {
		if (_stickerButtonsPickerView != nil)
			_stickerButtonsPickerView = nil;
		
		[_tabButtonsHolderView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			UIButton *btn = (UIButton *)obj;
			[btn setSelected:(btn.tag == groupIndex)];
		}];
	}
	
	[_emotionsPickerViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONStickerButtonsPickerView *pickerView = (HONStickerButtonsPickerView *)obj;
		
		if (pickerView.stickerGroupIndex == groupIndex) {
//			if (pickerView.stickerGroupIndex == 3) {
//				HONAnimatedBGsViewController *animatedBGsViewController = [[HONAnimatedBGsViewController alloc] init];
//				animatedBGsViewController.delegate = self;
//
//				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:animatedBGsViewController];
//				[navigationController setNavigationBarHidden:YES];
//				[self presentViewController:navigationController animated:YES completion:nil];
//
			if (pickerView.stickerGroupIndex == 4) {
				HONStoreProductsViewController *storeProductsViewController = [[HONStoreProductsViewController alloc] init];
				storeProductsViewController.delegate = self;
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:storeProductsViewController];
				[navigationController setNavigationBarHidden:YES];
				[self presentViewController:navigationController animated:[[HONAnimationOverseer sharedInstance] isSegueAnimationEnabledForModalViewController:storeProductsViewController] completion:nil];
				
			} else {
				for (UIView *view in _emotionsPickerHolderView.subviews) {
					((HONStickerButtonsPickerView *)view).delegate = nil;
					[view removeFromSuperview];
				}
				
				pickerView.frame = CGRectOffset(pickerView.frame, 0.0, 0.0);
				pickerView.delegate = self;
				[_emotionsPickerHolderView addSubview:pickerView];
				
				_stickerButtonsPickerView = pickerView;
				[UIView animateWithDuration:0.333 delay:0.000
					 usingSpringWithDamping:0.750 initialSpringVelocity:0.010
									options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent) animations:^(void) {
									 pickerView.frame = CGRectOffset(pickerView.frame, 0.0, 0.0);
								 } completion:^(BOOL finished) {
								 }];
			}
		}
	}];
}

- (void)_enableSubmitButton {
	[_nextButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - CameraOverlay Delegates
- (void)cameraOverlayViewShowCameraRoll:(HONCameraOverlayView *)cameraOverlayView {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Camera Roll"
//									 withProperties:@{@"state"	: @"open"}];
	
	self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)cameraOverlayViewChangeCamera:(HONCameraOverlayView *)cameraOverlayView {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Flip Camera"
//								   withCameraDevice:self.imagePickerController.cameraDevice];
	
	self.imagePickerController.cameraDevice = (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront) ? UIImagePickerControllerCameraDeviceRear : UIImagePickerControllerCameraDeviceFront;
	
	if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceRear)
		self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
}

- (void)cameraOverlayViewCloseCamera:(HONCameraOverlayView *)cameraOverlayView {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Close Camera"
//								   withCameraDevice:self.imagePickerController.cameraDevice];
	
	[self _cancelUpload];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	[self.imagePickerController dismissViewControllerAnimated:NO completion:^(void) {
		self.imagePickerController.delegate = nil;
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:^(void) {
		}];
	}];
}

- (void)cameraOverlayViewTakePhoto:(HONCameraOverlayView *)cameraOverlayView includeFilter:(BOOL)isFiltered {
	_isBlurred = isFiltered;
	//[[HONAnalyticsReporter sharedInstance] trackEvent:[NSString stringWithFormat:@"Camera Step - %@ Photo", (isFiltered) ? @"Blur" : @"Take"]];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"STATUS - take_photo"];
	
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", @"Loading…");
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kProgressHUDMinDuration;
	_progressHUD.taskInProgress = YES;
	
	[self.imagePickerController takePicture];
}


#pragma mark - StoreProductsViewController Delegates
- (void)storeProductsViewController:(HONStoreProductsViewController *)storeProductsViewController didDownloadProduct:(HONStoreProductVO *)storeProductVO {
	NSLog(@"[*:*] storeProductsViewController:didDownloadProduct:[%@ - %@]", storeProductVO.productID, storeProductVO.productName);
	
	[self _changeToStickerGroupIndex:0];
	
	HONStickerButtonsPickerView *pickerView = (HONStickerButtonsPickerView *)[_emotionsPickerViews firstObject];
	[pickerView scrollToLastPage];
	[pickerView appendPurchasedStickersWithContentGroupID:storeProductVO.contentGroupID];
}

- (void)storeProductsViewController:(HONStoreProductsViewController *)storeProductsViewController didPurchaseProduct:(HONStoreProductVO *)storeProductVO {
	NSLog(@"[*:*] storeProductsViewController:didPurchaseProduct:[%@ - %@]", storeProductVO.productID, storeProductVO.productName);
	
	[self _changeToStickerGroupIndex:0];
	
	HONStickerButtonsPickerView *pickerView = (HONStickerButtonsPickerView *)[_emotionsPickerViews firstObject];
	[pickerView scrollToLastPage];
	[pickerView appendPurchasedStickersWithContentGroupID:storeProductVO.contentGroupID];
}

#pragma mark - AnimatedBGsViewController Delegates
- (void)animatedBGViewController:(HONAnimatedBGsViewController *)viewController didSelectEmotion:(HONEmotionVO *)emotionVO {
	NSLog(@"[*:*] animatedBGViewController:didSelectEmotion:[%@][%@]", NSStringFromCGSize(emotionVO.animatedImageView.frame.size), emotionVO.smallImageURL);
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Animated BG Selected"
//										  withEmotion:emotionVO];
	
	_filename = [[emotionVO.smallImageURL componentsSeparatedByString:@"/"] lastObject];
//	[_composeDisplayView updatePreviewWithAnimatedImageView:emotionVO.animatedImageView];
	viewController.delegate = nil;
}


#pragma mark - StickerButtonsPickerView Delegates
- (void)stickerButtonsPickerView:(HONStickerButtonsPickerView *)stickerButtonsPickerView selectedEmotion:(HONEmotionVO *)emotionVO {
	NSLog(@"[*:*] emotionItemView:(%@) selectedEmotion:(%@ - {%@}) [*:*]", self.class, emotionVO.emotionName, (emotionVO.imageType == HONEmotionImageTypeGIF) ? @"GIF" : @"JPG");
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Sticker Selected"
//										  withEmotion:emotionVO];
	
//	dispatch_async(dispatch_get_main_queue(), ^{
//		if ([[HONStickerAssistant sharedInstance] candyBoxContainsContentGroupForContentGroupID:emotionVO.contentGroupID]) {
//			NSLog(@"Content in CandyBox --(%@)", emotionVO.contentGroupID);
//
////			PicoSticker *sticker = [[HONStickerAssistant sharedInstance] stickerFromCandyBoxWithContentID:emotionVO.emotionID];
////			[sticker use];
////			emotionVO.picoSticker = [[HONStickerAssistant sharedInstance] stickerFromCandyBoxWithContentID:emotionVO.emotionID];
////			[emotionVO.picoSticker use];
//
//		} else {
////			NSLog(@"Purchasing ContentGroup --(%@)", emotionVO.contentGroupID);
////			[[HONStickerAssistant sharedInstance] purchaseStickerPakWithContentGroupID:emotionVO.contentGroupID usingDelegate:self];
//		}
//	});
	
	if (stickerButtonsPickerView.stickerGroupIndex == 3) {
		_filename = [[emotionVO.smallImageURL componentsSeparatedByString:@"/"] lastObject];
		_filename = emotionVO.smallImageURL;
		NSLog(@"imgURL:[%@] filename:[%@]", emotionVO.smallImageURL, _filename);
		
		if (emotionVO.imageType == HONEmotionImageTypeGIF) {
//			[_composeDisplayView updatePreviewWithAnimatedImageView:emotionVO.animatedImageView];
		
		} else {
			_bgSelectImageView = [[UIImageView alloc] initWithFrame:CGRectFromSize(kSnapLargeSize)];
			[_bgSelectImageView setImageWithURL:[NSURL URLWithString:emotionVO.smallImageURL]];
//			[_composeDisplayView updatePreview:_bgSelectImageView.image];
		}
		
	} else {
		[_headerView transitionTitle:emotionVO.emotionName];
		[_selectedEmotions addObject:emotionVO];
		[_subjectNames addObject:emotionVO.emotionName];
//		[_composeDisplayView addEmotion:emotionVO];
		[_stickerSummaryView appendStickerAndSelect:emotionVO];
	}
	
	//[[HONAudioMaestro sharedInstance] cafPlaybackWithFilename:@"badminton_racket_fast_movement_swoosh_002"];
}

- (void)stickerButtonsPickerViewDidStartDownload:(HONStickerButtonsPickerView *)stickerButtonsPickerView {
	NSLog(@"[*:*] stickerButtonsPickerViewDidStartDownload:(%@) [*:*]", self.class);
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Download Sticker Group"
//										  withProperties:@{@"index"		: @(stickerButtonsPickerView.stickerGroupIndex)}];
	
	[stickerButtonsPickerView cacheAllStickerContent];
}

- (void)stickerButtonsPickerView:(HONStickerButtonsPickerView *)stickerButtonsPickerView didFinishDownloadingForContentGroupID:(NSString *)contentGroupID {
	NSLog(@"[*:*] stickerButtonsPickerView:didFinishDownloadingForContentGroupID:[%@]:(%@) [*:*]", self.class, contentGroupID);
	[[HONStickerAssistant sharedInstance] writeContentGroupCachedWithContentGroupID:contentGroupID];
}

- (void)stickerButtonsPickerView:(HONStickerButtonsPickerView *)stickerButtonsPickerView didChangeToPage:(int)page withDirection:(int)direction {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:[@"Camera Step - Stickerboard Swipe " stringByAppendingString:(direction == 1) ? @"Right" : @"Left"]];
}


#pragma mark - StickerSummaryView Delegates
- (void)stickerSummaryView:(HONStickerSummaryView *)stickerSummaryView deleteLastSticker:(HONEmotionVO *)emotionVO {
	NSLog(@"[*:*] stickerSummaryView:(%@) deleteLastSticker:[%@ - %@][*:*]", self.class, emotionVO.emotionID, emotionVO.emotionName);
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Sticker Deleted"
//										  withEmotion:emotionVO];
	
	if ([_subjectNames count] > 0)
		[_subjectNames removeLastObject];
	
	if ([_subjectNames count] == 0) {
		[_subjectNames removeAllObjects];
		_subjectNames = nil;
		_subjectNames = [NSMutableArray array];
	}
	
//	[_composeDisplayView removeLastEmotion];
	[_headerView transitionTitle:([_subjectNames count] > 0) ? [_subjectNames lastObject] : @"Compose"];
}

- (void)stickerSummaryView:(HONStickerSummaryView *)stickerSummaryView didSelectThumb:(HONEmotionVO *)emotionVO atIndex:(int)index {
	NSLog(@"[*:*] stickerSummaryView:(%@) didSelectThumb:[%@ - %@] atIndex:(%d) [*:*]", self.class, emotionVO.emotionID, emotionVO.emotionName, index);
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Selected Sticker Thumb"
//										  withEmotion:emotionVO];
	
//	[_composeDisplayView scrollToEmotion:emotionVO atIndex:index];
	
}


#pragma mark - CandyStorePurchaseController
- (void)purchaseController:(id)controller downloadedStickerWithId:(NSString *)contentId {
	NSLog(@"[*:*] purchaseController:downloadedStickerWithId:[%@]", contentId);
}

-(void)purchaseController:(id)controller downloadStickerWithIdFailed:(NSString *)contentId {
	NSLog(@"[*:*] purchaseController:downloadedStickerWithIdFailed:[%@]", contentId);
}

- (void)purchaseController:(id)controller purchasedStickerWithId:(NSString *)contentId userInfo:(NSDictionary *)userInfo {
	NSLog(@"[*:*] purchaseController:purchasedStickerWithId:[%@] userInfo:[%@]", contentId, userInfo);
}

- (void)purchaseController:(id)controller purchaseStickerWithIdFailed:(NSString *)contentId userInfo:(NSDictionary *)userInfo {
	NSLog(@"[*:*] purchaseController:purchaseStickerWithIdFailed:[%@] userInfo:[%@]", contentId, userInfo);
}

- (void)purchaseController:(id)controller downloadedStickerPackWithId:(NSString *)contentGroupId {
	NSLog(@"[*:*] purchaseController:downloadedStickerPackWithId:[%@]", contentGroupId);
}

- (void)purchaseController:(id)controller downloadStickerPackWithIdFailed:(NSString *)contentGroupId {
	NSLog(@"[*:*] purchaseController:downloadStickerPackWithIdFailed:[%@]", contentGroupId);
}

- (void)purchaseController:(id)controller purchasedStickerPackWithId:(NSString *)contentGroupId userInfo:(NSDictionary *)userInfo {
	NSLog(@"[*:*] purchaseController:downloadStickerPackWithIdFailed:[%@] userInfo:[%@]", contentGroupId, userInfo);
}

- (void)purchaseController:(id)controller purchaseStickerPackWithContentGroupFailed:(PCContentGroup *)contentGroup userInfo:(NSDictionary *)userInfo {
	NSLog(@"[*:*] purchaseController:purchaseStickerPackWithContentGroupFailed:[%@] userInfo:[%@]", contentGroup, userInfo);
}


#pragma mark - NavigationController Delegates
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	navigationController.navigationBar.barStyle = UIBarStyleDefault;
}


#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	BOOL isSourceImageMirrored = (picker.sourceType == UIImagePickerControllerSourceTypeCamera && picker.cameraDevice == UIImagePickerControllerCameraDeviceFront);
	
//	if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Camera Roll"
//										 withProperties:@{@"state"	: @"photo"}];
	
	if (_maskImageView != nil) {
		[_maskImageView removeFromSuperview];
		_maskImageView = nil;
	}
	
	_processedImage = [[HONImageBroker sharedInstance] prepForUploading:[info objectForKey:UIImagePickerControllerOriginalImage]];
	_processedImage = (_isBlurred) ? [_processedImage applyBlurWithRadius:32.0
																tintColor:[UIColor colorWithWhite:0.00 alpha:0.50]
													saturationDeltaFactor:1.0
																maskImage:nil] : _processedImage;
	NSLog(@"PROCESSED IMAGE:[%@]", NSStringFromCGSize(_processedImage.size));
	
	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectFromSize(kSnapLargeSize)];
	canvasView.clipsToBounds = YES;
	[self.view addSubview:canvasView];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-53.0, 0.0, 426.0, kSnapLargeSize.height)];
	imageView.image = _processedImage;
	[canvasView addSubview:imageView];
	
	_processedImage = [[HONImageBroker sharedInstance] createImageFromView:canvasView];
	_processedImage = (isSourceImageMirrored) ? [[HONImageBroker sharedInstance] mirrorImage:[[HONImageBroker sharedInstance] createImageFromView:canvasView]] : [[HONImageBroker sharedInstance] createImageFromView:canvasView];
	
	CIImage *filterInputImage = [CIImage imageWithCGImage:[[HONImageBroker sharedInstance] mirrorImage:_processedImage].CGImage];
	CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
	[filter setValue:filterInputImage forKey:kCIInputImageKey];
	[filter setValue:@(32) forKey:kCIInputScaleKey];
	CIImage *filterOutputImage = filter.outputImage;
	
	CIContext* ctx = [CIContext contextWithOptions:nil];
	CGImageRef createdImage = [ctx createCGImage:filterOutputImage fromRect:filterOutputImage.extent];
	
	UIImage *outputImage = [UIImage imageWithCGImage:createdImage scale:1.0 orientation:UIImageOrientationUpMirrored];
	CGImageRelease(createdImage);
	createdImage = nil;
	
	_previewImageView.image = _processedImage;
	
	[[HONViewDispensor sharedInstance] maskView:_filteredImageView withMask:_maskImageView.image];
	
	_filteredImageView.image = outputImage;
	[canvasView removeFromSuperview];
	
	
//	[_composeDisplayView updatePreview:[[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:_processedImage toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)]];
	
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	_headerView.hidden = NO;
	_submitButton.hidden = NO;
	[self dismissViewControllerAnimated:NO completion:^(void) {
		[self _uploadPhotos];
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"STATUS - enter_step_2"];
	}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	NSLog(@"imagePickerControllerDidCancel:[%@]", (self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) ? @"CAMERA" : @"LIBRARY");
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Camera Roll"
//									 withProperties:@{@"state"	: @"cancel"}];
	
	_isBlurred = NO;
	[self dismissViewControllerAnimated:NO completion:^(void) {
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
			[self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
		
		else {
			self.imagePickerController.delegate = nil;
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:^(void) {
			}];
		}
	}];
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - BG Action Sheet"
//										   withProperties:@{@"btn"	: (buttonIndex == 0) ? @"camera" : (buttonIndex == 1) ? @"camera roll" : (buttonIndex == 2) ? @"animations" : @"cancel"}];
		
		if (buttonIndex == 0) {
			[self showImagePickerForSourceType:([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary];
		
		} else if (buttonIndex == 1) {
			[self showImagePickerForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
		
		} else if (buttonIndex == 2) {
			HONAnimatedBGsViewController *animatedBGsViewController = [[HONAnimatedBGsViewController alloc] init];
			animatedBGsViewController.delegate = self;
			
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:animatedBGsViewController];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}
	}
}


#pragma mark - AWS Delegates
//- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
//	NSLog(@"\nAWS didCompleteWithResponse:\n%@", response);
//	
//	_uploadCounter++;
//	_isUploadComplete = (_uploadCounter == 2);
//	
//	if (_isUploadComplete) {
//		if (_progressHUD != nil) {
//			[_progressHUD hide:YES];
//			_progressHUD = nil;
//		}
//		
//		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:_filename forBucketType:HONS3BucketTypeSelfies completion:^(NSObject *result) {
//			if (_progressHUD != nil) {
//				[_progressHUD hide:YES];
//				_progressHUD = nil;
//			}
//		}];
//	}
//}
//
//- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
//	NSLog(@"AWS didFailWithError:\n%@", error);
//	
//	if (_progressHUD == nil)
//		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
//	_progressHUD.minShowTime = kProgressHUDMinDuration;
//	_progressHUD.mode = MBProgressHUDModeCustomView;
//	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
//	_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
//	[_progressHUD show:NO];
//	[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
//	_progressHUD = nil;
//}

@end