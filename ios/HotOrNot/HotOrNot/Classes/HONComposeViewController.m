//
//  HONComposeViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/6/13 @ 12:01 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

#import "NSMutableDictionary+Replacements.h"
#import "NSString+DataTypes.h"
#import "UIImage+fixOrientation.h"
#import "UIImage+ImageEffects.h"
#import "UIImageView+AFNetworking.h"

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
#import "HONComposeDisplayView.h"
#import "HONStickerSummaryView.h"
#import "HONStickerButtonsPickerView.h"

@interface HONComposeViewController () <AmazonServiceRequestDelegate, HONAnimatedBGsViewControllerDelegate, HONCameraOverlayViewDelegate, HONComposeDisplayViewDelegate, HONStickerButtonsPickerViewDelegate, HONStickerSummaryViewDelegate, HONStoreProductsViewControllerDelegate, PCCandyStorePurchaseControllerDelegate>
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, assign, readonly) HONSelfieSubmitType selfieSubmitType;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONUserClubVO *userClubVO;
@property (nonatomic, strong) HONTrivialUserVO *trivialUserVO;
@property (nonatomic, strong) HONContactUserVO *contactUserVO;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONCameraOverlayView *cameraOverlayView;
@property (nonatomic, strong) HONComposeDisplayView *composeDisplayView;
@property (nonatomic, strong) HONStickerSummaryView *stickerSummaryView;
@property (nonatomic, strong) HONStickerButtonsPickerView *stickerButtonsPickerView;
@property (nonatomic, strong) UIImage *processedImage;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSMutableDictionary *submitParams;
@property (nonatomic) BOOL isUploadComplete;
@property (nonatomic) BOOL isBlurred;
@property (nonatomic) int uploadCounter;
@property (nonatomic) int selfieAttempts;
@property (nonatomic, strong) HONStoreTransactionObserver *storeTransactionObserver;
@property (nonatomic, strong) S3PutObjectRequest *por1;
@property (nonatomic, strong) S3PutObjectRequest *por2;

@property (nonatomic, strong) NSMutableArray *subjectNames;
@property (nonatomic, strong) NSMutableArray *selectedEmotions;
@property (nonatomic, strong) NSMutableArray *emotionsPickerViews;
@property (nonatomic, strong) NSMutableArray *emotionsPickerButtons;
@property (nonatomic, strong) UIView *emotionsPickerHolderView;
@property (nonatomic, strong) UIView *tabButtonsHolderView;
@property (nonatomic, strong) UIImageView *bgSelectImageView;

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *nextButton;
@end


@implementation HONComposeViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeCompose;
		_viewStateType = HONStateMitigatorViewStateTypeCompose;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_reloadEmotionPicker:)
													 name:@"RELOAD_EMOTION_PICKER" object:nil];
		
		_selfieAttempts = 0;
		_filename = [[HONClubAssistant sharedInstance] rndCoverImageURL];
		
		_selectedEmotions = [NSMutableArray array];
		_subjectNames = [NSMutableArray array];
		_emotionsPickerViews = [NSMutableArray array];
		_emotionsPickerButtons = [NSMutableArray array];
	}
	
	return (self);
}

- (void)dealloc {
	_por1.delegate = nil;
	_por2.delegate = nil;
	_cameraOverlayView.delegate = nil;
	_composeDisplayView.delegate = nil;
	
	[super destroy];
}

- (id)initWithContact:(HONContactUserVO *)contactUserVO {
	NSLog(@"%@ - initWithContact", [self description]);
	if ((self = [self init])) {
		_contactUserVO = contactUserVO;
		_selfieSubmitType = HONSelfieSubmitTypeCreate;
	}
	
	return (self);
}

- (id)initWithUser:(HONTrivialUserVO *)trivialUserVO {
	NSLog(@"%@ - initWithUser", [self description]);
	if ((self = [self init])) {
		_trivialUserVO = trivialUserVO;
		_selfieSubmitType = HONSelfieSubmitTypeCreate;
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
- (void)_retrieveClubWithClubID:(int)clubID ownerID:(int)ownerID {
	_userClubVO = [[HONClubAssistant sharedInstance] fetchClubWithClubID:clubID];
	
	NSMutableArray *selectedUsers = [NSMutableArray array];
	NSMutableArray *selectedContacts = [NSMutableArray array];
	if ([[HONClubAssistant sharedInstance] fetchClubWithClubID:clubID] == nil) {
		[[HONAPICaller sharedInstance] retrieveClubByClubID:clubID withOwnerID:ownerID completion:^(NSDictionary *result) {
			_userClubVO = [HONUserClubVO clubWithDictionary:result];
		}];
		
	} else {
		_userClubVO = [[HONClubAssistant sharedInstance] fetchClubWithClubID:clubID];
	}
	
	
	[[HONAPICaller sharedInstance] retrieveClubByClubID:clubID withOwnerID:ownerID completion:^(NSDictionary *result) {
		_userClubVO = [HONUserClubVO clubWithDictionary:result];
		
		NSLog(@"%d <> %d", [[_submitParams objectForKey:@"club_id"] intValue], _userClubVO.clubID);
		if ([[_submitParams objectForKey:@"club_id"] intValue] == _userClubVO.clubID) {
			
			__block NSString *names = @"";
			__block HONClubPhotoVO *clubPhotoVO = nil;
			NSMutableArray *participants = [NSMutableArray array];
			[_userClubVO.activeMembers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
				[selectedUsers addObject:vo];
				[participants addObject:vo.username];
				names = [names stringByAppendingFormat:@"%@, ", vo.username];
			}];
			
			[_userClubVO.pendingMembers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONContactUserVO *contactUserVO = (HONContactUserVO *)obj;
				HONTrivialUserVO *trivialUserVO = [HONTrivialUserVO userFromContactUserVO:(HONContactUserVO *)obj];

				[selectedContacts addObject:contactUserVO];
				[participants addObject:trivialUserVO.username];
				names = [names stringByAppendingFormat:@"%@, ", trivialUserVO.username];
			}];
//				HONTrivialUserVO *trivialUserVO = (HONTrivialUserVO *)obj;
//				
//				[selectedContacts addObject:[HONContactUserVO contactWithDictionary:trivialUserVO.dictionary]];
//				[participants addObject:trivialUserVO.username];
//				names = [names stringByAppendingFormat:@"%@, ", trivialUserVO.username];
//			}];
			
			names = ([names rangeOfString:@", "].location != NSNotFound) ? [names substringToIndex:[names length] - 2] : names;
			
			[[HONAnalyticsReporter sharedInstance] trackEvent:[NSString stringWithFormat:@"Camera Step - %@", (_selfieSubmitType == HONSelfieSubmitTypeCreate) ? @"Friend Picker" : @"Submit Reply"]
												 withUserClub:_userClubVO];
			
			NSLog(@"*^*|~|*|~|*|~|*|~|*|~|*|~| CLUB -=- (CREATE) |~|*|~|*|~|*|~|*|~|*|~|*^*");
			NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}];
			[dict setValue:[NSString stringWithFormat:@"%d_%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue], (int)[[[HONDateTimeAlloter sharedInstance] utcNowDate] timeIntervalSince1970]] forKey:@"name"];
			_userClubVO = [HONUserClubVO clubWithDictionary:dict];
			
			[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"CREATING CLUB [%@]", _userClubVO.clubName]
										message:[NSString stringWithFormat:@"%@", names]
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
			
			
			[[HONAPICaller sharedInstance] createClubWithTitle:_userClubVO.clubName withDescription:_userClubVO.blurb withImagePrefix:_userClubVO.coverImagePrefix completion:^(NSDictionary *result) {
				_userClubVO = [HONUserClubVO clubWithDictionary:result];
				[_submitParams replaceObject:[@"" stringFromInt:_userClubVO.clubID] forExistingKey:@"club_id"];
				
				NSLog(@"*^*|~|*|~|*|~|*|~|*|~|*|~| SUBMITTING -=- [%@] |~|*|~|*|~|*|~|*|~|*|~|*^*", _submitParams);
				[[HONAPICaller sharedInstance] submitClubPhotoWithDictionary:_submitParams completion:^(NSDictionary *result) {
					if ([[result objectForKey:@"result"] isEqualToString:@"fail"]) {
						if (_progressHUD == nil)
							_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
						_progressHUD.minShowTime = kHUDTime;
						_progressHUD.mode = MBProgressHUDModeCustomView;
						_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
						_progressHUD.labelText = @"Error!";
						[_progressHUD show:NO];
						[_progressHUD hide:YES afterDelay:kHUDErrorTime];
						_progressHUD = nil;
						
					} else {
						clubPhotoVO = [HONClubPhotoVO clubPhotoWithDictionary:result];
						[[HONClubAssistant sharedInstance] writeStatusUpdateAsSeenWithID:clubPhotoVO.challengeID];
						
						NSMutableArray *users = [NSMutableArray array];
						for (HONTrivialUserVO *vo in selectedUsers)
							[users addObject:[[HONAnalyticsReporter sharedInstance] propertyForTrivialUser:vo]];
						
						NSMutableArray *contacts = [NSMutableArray array];
						for (HONContactUserVO *vo in selectedContacts)
							[contacts addObject:[[HONAnalyticsReporter sharedInstance] propertyForContactUser:vo]];
						
						[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Send Club Reply Invites"
														   withProperties:@{@"clubs"	: [[HONAnalyticsReporter sharedInstance] propertyForUserClub:_userClubVO],
																			@"members"	: users,
																			@"contacts"	: contacts}];
					
						[[HONClubAssistant sharedInstance] sendClubInvites:_userClubVO toInAppUsers:selectedUsers ToNonAppContacts:selectedContacts onCompletion:^(BOOL success) {
							if (_selfieSubmitType == HONSelfieSubmitTypeCreate) {
								_isPushing = YES;
								[self.navigationController pushViewController:[[HONComposeSubmitViewController alloc] initWithSubmitParameters:_submitParams] animated:NO];
								
							} else {
								[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
									[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUB_TIMELINE" object:@"Y"];
								}];
							}
						}];
					}
				}];
			}];
		}
	}];
}


- (void)_uploadPhotos {
	_isUploadComplete = NO;
	_uploadCounter = 0;
	
	_filename = [NSString stringWithFormat:@"%@_%d", [[[HONDeviceIntrinsics sharedInstance] identifierForVendorWithoutSeperators:YES] lowercaseString], (int)[[NSDate date] timeIntervalSince1970]];
	NSLog(@"FILE PREFIX: %@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], _filename);
	
	UIImage *largeImage = [[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:_processedImage toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)];
	UIImage *tabImage = [[HONImageBroker sharedInstance] cropImage:largeImage toRect:CGRectMake(0.0, 0.0, kSnapTabSize.width * 2.0, kSnapTabSize.height * 2.0)];
	
	NSString *largeURL = [_filename stringByAppendingString:kSnapLargeSuffix];
	NSString *tabURL = [_filename stringByAppendingString:kSnapLargeSuffix];
	
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	
	@try {
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-challenges"]];
		_por1 = [[S3PutObjectRequest alloc] initWithKey:largeURL inBucket:@"hotornot-challenges"];
		_por1.delegate = self;
		_por1.contentType = @"image/gif";
		_por1.data = UIImageJPEGRepresentation(largeImage, [HONAppDelegate compressJPEGPercentage]);
		[s3 putObject:_por1];
		
		_por2 = [[S3PutObjectRequest alloc] initWithKey:tabURL inBucket:@"hotornot-challenges"];
		_por2.delegate = self;
		_por2.contentType = @"image/gif";
		_por2.data = UIImageJPEGRepresentation(tabImage, [HONAppDelegate compressJPEGPercentage] * 0.85);
		[s3 putObject:_por2];
		
	} @catch (AmazonClientException *exception) {
		NSLog(@"AWS FAIL:[%@]", exception.message);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}
}

- (void)_modifySubmitParamsAndSubmit:(NSArray *)subjectNames {
	if ([subjectNames count] == 0) {
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_noemotions_title", @"No Emotions Selected!")
									message:NSLocalizedString(@"alert_noemotions_msg", @"You need to choose some emotions to make a status update.")
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
		
	} else {
		_isPushing = YES;
		
		NSError *error;
		NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:subjectNames options:0 error:&error]
													 encoding:NSUTF8StringEncoding];
		
		_submitParams = [@{@"user_id"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
						   @"img_url"		: [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], _filename],
						   @"club_id"		: [@"" stringFromInt:(_selfieSubmitType == HONSelfieSubmitTypeReply) ? _userClubVO.clubID : 0],
						   @"owner_id"		: [@"" stringFromInt:(_selfieSubmitType == HONSelfieSubmitTypeReply) ? _userClubVO.ownerID : 0],
						   @"subject"		: @"",
						   @"subjects"		: jsonString,
						   @"challenge_id"	: [@"" stringFromInt:0],
						   @"recipients"		: (_trivialUserVO != nil) ? [@"" stringFromInt:_trivialUserVO.userID] : (_contactUserVO != nil) ? (_contactUserVO.isSMSAvailable) ? _contactUserVO.mobileNumber : _contactUserVO.email : @"",
						   @"api_endpt"		: kAPICreateChallenge} mutableCopy];
		NSLog(@"|:|◊≈◊~~◊~~◊≈◊~~◊~~◊≈◊| SUBMIT PARAMS:[%@]", _submitParams);
		
//		[self.navigationController pushViewController:[[HONStatusUpdateSubmitViewController alloc] initWithSubmitParameters:_submitParams] animated:YES];


		if (_selfieSubmitType != HONSelfieSubmitTypeReply) {
			_isPushing = YES;
			[self.navigationController pushViewController:[[HONComposeSubmitViewController alloc] initWithSubmitParameters:_submitParams] animated:NO];
 
		
		} else {
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Submit Reply"
											   withUserClub:_userClubVO];
			
			[self _retrieveClubWithClubID:[[_submitParams objectForKey:@"club_id"] intValue] ownerID:[[_submitParams objectForKey:@"owner_id"] intValue]];
		}
	}
}

- (void)_cancelUpload {
	_isUploadComplete = NO;
	_uploadCounter = 0;
	
	if (_por1 != nil) {
		[_por1.urlConnection cancel];
		_por1 = nil;
	}
	
	if (_por2 != nil) {
		[_por2.urlConnection cancel];
		_por2 = nil;
	}
}

- (void)_uploadTimeout {
	[self _cancelUpload];
	
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.mode = MBProgressHUDModeCustomView;
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
	_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
	[_progressHUD show:NO];
	[_progressHUD hide:YES afterDelay:kHUDErrorTime];
	_progressHUD = nil;
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_isBlurred = false;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	
	
	_composeDisplayView = [[HONComposeDisplayView alloc] initWithFrame:self.view.frame];
	_composeDisplayView.delegate = self;
	[self.view addSubview:_composeDisplayView];
	
	_emotionsPickerHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 221.0, 320.0, 221.0)];
	[self.view addSubview:_emotionsPickerHolderView];
	
	_tabButtonsHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 44.0, 320.0, 44.0)];
	[self.view addSubview:_tabButtonsHolderView];
	
	for (int i=0; i<5; i++) {
		HONStickerButtonsPickerView *pickerView = [[HONStickerButtonsPickerView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, _emotionsPickerHolderView.frame.size.height) asGroupIndex:i];
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
	
	_stickerSummaryView = [[HONStickerSummaryView alloc] initAtPosition:CGPointMake(0.0, 297.0)];
	_stickerSummaryView.delegate = self;
	[self.view addSubview:_stickerSummaryView];
	
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
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Create"];
	[self.view addSubview:_headerView];
	
	_closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_closeButton.frame = CGRectMake(-2.0, 1.0, 44.0, 44.0);
	[_closeButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
	[_closeButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
	[_closeButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:_closeButton];
	
	_nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_nextButton.frame = CGRectMake(282.0, 1.0, 44.0, 44.0);
	[_nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_nonActive"] forState:UIControlStateNormal];
	[_nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_Active"] forState:UIControlStateHighlighted];
	[_nextButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:_nextButton];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_panGestureRecognizer.enabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:animated:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
	[_nextButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Navigation
- (void)_goCancel {
	NSLog(@"[*:*] _goCancel");
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Cancel"];
	[self _cancelUpload];
	[self dismissViewControllerAnimated:NO completion:^(void) {
	}];
}

- (void)_goSubmit {
	_isPushing = YES;
	[self _modifySubmitParamsAndSubmit:_subjectNames];
}

- (void)_goGroup:(id)sender {
	UIButton *button = (UIButton *)sender;
	
	int groupIndex = button.tag;
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Change Emotion Group"
 									   withProperties:@{@"index"	: [@"" stringFromInt:groupIndex]}];
	
	[self _changeToStickerGroupIndex:groupIndex];
}

- (void)_goDelete {
	HONEmotionVO *emotionVO = (HONEmotionVO *)[_selectedEmotions lastObject];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Sticker Deleted"
										  withEmotion:emotionVO];
	
	if ([_subjectNames count] > 0)
		[_subjectNames removeLastObject];
	
	if ([_subjectNames count] == 0) {
		[_subjectNames removeAllObjects];
		_subjectNames = nil;
		_subjectNames = [NSMutableArray array];
	}
	
	[_composeDisplayView removeLastEmotion];
	[_headerView transitionTitle:([_subjectNames count] > 0) ? [_subjectNames lastObject] : @"Create"];
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	[super _goPanGesture:gestureRecognizer];
	
	if ([gestureRecognizer velocityInView:self.view].y >= 2000 || [gestureRecognizer velocityInView:self.view].x >= 2000) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Dismiss SWIPE"];
		
		[self _cancelUpload];
		[self dismissViewControllerAnimated:YES completion:^(void) {
		}];
	}
	
	if ([gestureRecognizer velocityInView:self.view].x <= -2000 && !_isPushing) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Next SWIPE"];
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
	}
	
	self.imagePickerController = imagePickerController;
	[self presentViewController:self.imagePickerController animated:YES completion:^(void) {
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
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Camera Roll"
									 withProperties:@{@"state"	: @"open"}];
	
	self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)cameraOverlayViewChangeCamera:(HONCameraOverlayView *)cameraOverlayView {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Flip Camera"
								   withCameraDevice:self.imagePickerController.cameraDevice];
	
	self.imagePickerController.cameraDevice = (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront) ? UIImagePickerControllerCameraDeviceRear : UIImagePickerControllerCameraDeviceFront;
	
	if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceRear)
		self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
}

- (void)cameraOverlayViewCloseCamera:(HONCameraOverlayView *)cameraOverlayView {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Close Camera"
								   withCameraDevice:self.imagePickerController.cameraDevice];
	
	[self _cancelUpload];
	[self.imagePickerController dismissViewControllerAnimated:YES completion:^(void) {
		self.imagePickerController.delegate = nil;
	}];
}

- (void)cameraOverlayViewTakePhoto:(HONCameraOverlayView *)cameraOverlayView includeFilter:(BOOL)isFiltered {
	_isBlurred = isFiltered;
	[[HONAnalyticsReporter sharedInstance] trackEvent:[NSString stringWithFormat:@"Camera Step - %@ Photo", (isFiltered) ? @"Blur" : @"Take"]];
	
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", @"Loading…");
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
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
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Animated BG Selected"
										  withEmotion:emotionVO];
	
	_filename = [[emotionVO.smallImageURL componentsSeparatedByString:@"/"] lastObject];
	[_composeDisplayView updatePreviewWithAnimatedImageView:emotionVO.animatedImageView];
	viewController.delegate = nil;
}


#pragma mark - ComposeDisplayView Delegates
- (void)composeDisplayView:(HONComposeDisplayView *)composeDisplayView deleteLastSticker:(HONEmotionVO *)emotionVO {
	NSLog(@"[*:*] composeDisplayView:deleteLastSticker:(%@ - %@) [*:*]", emotionVO.emotionID, emotionVO.emotionName);
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Sticker Deleted"
										  withEmotion:emotionVO];
	
	if ([_subjectNames count] > 0)
		[_subjectNames removeLastObject];
	
	if ([_subjectNames count] == 0) {
		[_subjectNames removeAllObjects];
		_subjectNames = nil;
		_subjectNames = [NSMutableArray array];
	}
	
	[_composeDisplayView removeLastEmotion];
	[_headerView transitionTitle:([_subjectNames count] > 0) ? [_subjectNames lastObject] : @"Create"];
}

- (void)composeDisplayViewGoFullScreen:(HONComposeDisplayView *)pickerDisplayView {
	NSLog(@"[*:*] composeDisplayViewGoFullScreen:(%@) [*:*]", self.class);
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Hide Stickerboard"];
	
	[_tabButtonsHolderView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UIButton *btn = (UIButton *)obj;
		[btn setSelected:NO];
	}];
	
	for (UIView *view in _emotionsPickerHolderView.subviews) {
		((HONStickerButtonsPickerView *)view).delegate = nil;
		[UIView animateWithDuration:0.333 delay:0.000
			 usingSpringWithDamping:0.800 initialSpringVelocity:0.010
							options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction)
						 animations:^(void) {
							 view.frame = CGRectOffset(view.frame, 0.0, 64.0);
						 } completion:^(BOOL finished) {
							 view.frame = CGRectOffset(view.frame, 0.0, -64.0);
							 [view removeFromSuperview];
						 }];
	}
}

- (void)composeDisplayViewShowCamera:(HONComposeDisplayView *)pickerDisplayView {
	NSLog(@"[*:*] composeDisplayViewShowCamera");
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Open Camera"];
	
	_isBlurred = NO;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Take Photo", @"Camera Roll", @"Animations", nil];
	[actionSheet setTag:0];
	[actionSheet showInView:self.view];
}

- (void)composeDisplayView:(HONComposeDisplayView *)pickerDisplayView scrolledEmotionsToIndex:(int)index fromDirection:(int)dir {
//	NSLog(@"[*:*] composeDisplayView:(%@) scrolledEmotionsToIndex:(%d/%d) fromDirection:(%d) [*:*]", self.class, index, MIN(MAX(0, index), [_selectedEmotions count] - 1), dir);
	
	if ([_subjectNames count] == 0) {
		[_headerView transitionTitle:@""];
		
	} else {
		int ind = MIN(MAX(0, index), [_subjectNames count] - 1);
		if (![_headerView.title isEqualToString:[_subjectNames objectAtIndex:ind]])
			[_headerView transitionTitle:[_subjectNames objectAtIndex:ind]];
	}
}


#pragma mark - StickerButtonsPickerView Delegates
- (void)stickerButtonsPickerView:(HONStickerButtonsPickerView *)stickerButtonsPickerView selectedEmotion:(HONEmotionVO *)emotionVO {
	NSLog(@"[*:*] emotionItemView:(%@) selectedEmotion:(%@) [*:*]", self.class, emotionVO.emotionName);
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Sticker Selected"
										  withEmotion:emotionVO];
	
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
		NSString *imgURL = [NSString stringWithFormat:@"https://s3.amazonaws.com/hotornot-challenges/%@Large_640x1136.%@", emotionVO.emotionName, @"gif"];// (emotionVO.imageType == HONEmotionImageTypeGIF) ? @"gif" : @"jpg"];
		NSLog(@"imgURL:[%@]", imgURL);
		_filename = [[imgURL componentsSeparatedByString:@"/"] lastObject];
		
		_bgSelectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapLargeSize.width, kSnapLargeSize.height)];
		[_bgSelectImageView setImageWithURL:[NSURL URLWithString:imgURL]];
		
		if (emotionVO.imageType == HONEmotionImageTypeGIF)
			[_composeDisplayView updatePreviewWithAnimatedImageView:emotionVO.animatedImageView];
		
		else
			[_composeDisplayView updatePreview:_bgSelectImageView.image];
		
	} else {
		[_headerView transitionTitle:emotionVO.emotionName];
		[_selectedEmotions addObject:emotionVO];
		[_subjectNames addObject:emotionVO.emotionName];
		[_composeDisplayView addEmotion:emotionVO];
		[_stickerSummaryView appendSticker:emotionVO];
	}
	
	//[[HONAudioMaestro sharedInstance] cafPlaybackWithFilename:@"badminton_racket_fast_movement_swoosh_002"];
}

- (void)stickerButtonsPickerViewDidStartDownload:(HONStickerButtonsPickerView *)stickerButtonsPickerView {
	NSLog(@"[*:*] stickerButtonsPickerViewDidStartDownload:(%@) [*:*]", self.class);
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Download Sticker Group"
										  withProperties:@{@"index"		: @(stickerButtonsPickerView.stickerGroupIndex)}];
	
	[stickerButtonsPickerView cacheAllStickerContent];
}

- (void)stickerButtonsPickerView:(HONStickerButtonsPickerView *)stickerButtonsPickerView didChangeToPage:(int)page withDirection:(int)direction {
	[[HONAnalyticsReporter sharedInstance] trackEvent:[@"Camera Step - Stickerboard Swipe " stringByAppendingString:(direction == 1) ? @"Right" : @"Left"]];
}


#pragma mark - StickerSummaryView Delegates
- (void)stickerSummaryView:(HONStickerSummaryView *)stickerSummaryView deleteLastSticker:(HONEmotionVO *)emotionVO {
	NSLog(@"[*:*] stickerSummaryView:(%@) deleteLastSticker:[%@ - %@][*:*]", self.class, emotionVO.emotionID, emotionVO.emotionName);
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Sticker Deleted"
										  withEmotion:emotionVO];
	
	if ([_subjectNames count] > 0)
		[_subjectNames removeLastObject];
	
	if ([_subjectNames count] == 0) {
		[_subjectNames removeAllObjects];
		_subjectNames = nil;
		_subjectNames = [NSMutableArray array];
	}
	
	[_composeDisplayView removeLastEmotion];
	[_headerView transitionTitle:([_subjectNames count] > 0) ? [_subjectNames lastObject] : @"Compose"];
}

- (void)stickerSummaryView:(HONStickerSummaryView *)stickerSummaryView didSelectThumb:(HONEmotionVO *)emotionVO atIndex:(int)index {
	NSLog(@"[*:*] stickerSummaryView:(%@) didSelectThumb:[%@ - %@] atIndex:(%d) [*:*]", self.class, emotionVO.emotionID, emotionVO.emotionName, index);
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Selected Sticker Thumb"
										  withEmotion:emotionVO];
	
	[_composeDisplayView scrollToEmotion:emotionVO atIndex:index];
	
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
	
	if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Camera Roll"
										 withProperties:@{@"state"	: @"photo"}];
	
	_processedImage = [[HONImageBroker sharedInstance] prepForUploading:[info objectForKey:UIImagePickerControllerOriginalImage]];
	_processedImage = (_isBlurred) ? [_processedImage applyBlurWithRadius:32.0
																tintColor:[UIColor colorWithWhite:0.00 alpha:0.50]
													saturationDeltaFactor:1.0
																maskImage:nil] : _processedImage;
	NSLog(@"PROCESSED IMAGE:[%@]", NSStringFromCGSize(_processedImage.size));
	
	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _processedImage.size.width, _processedImage.size.height)];
	[canvasView addSubview:[[UIImageView alloc] initWithImage:_processedImage]];
	
	_processedImage = (isSourceImageMirrored) ? [[HONImageBroker sharedInstance] mirrorImage:[[HONImageBroker sharedInstance] createImageFromView:canvasView]] : [[HONImageBroker sharedInstance] createImageFromView:canvasView];
	[_composeDisplayView updatePreview:[[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:_processedImage toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)]];
	
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	[self dismissViewControllerAnimated:YES completion:^(void) {
		[self _uploadPhotos];
	}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	NSLog(@"imagePickerControllerDidCancel:[%@]", (self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) ? @"CAMERA" : @"LIBRARY");
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Camera Roll"
									 withProperties:@{@"state"	: @"cancel"}];
	
	_isBlurred = NO;
	[self dismissViewControllerAnimated:YES completion:^(void) {
	}];
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - BG Action Sheet"
										   withProperties:@{@"btn"	: (buttonIndex == 0) ? @"camera" : (buttonIndex == 1) ? @"camera roll" : (buttonIndex == 2) ? @"animations" : @"cancel"}];
		
		if (buttonIndex == 0) {
			[self showImagePickerForSourceType:([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary];
		
		} else if (buttonIndex == 1) {
			[self showImagePickerForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
		
		} else if (buttonIndex == 2) {
			HONAnimatedBGsViewController *animatedBGsViewController = [[HONAnimatedBGsViewController alloc] init];
			animatedBGsViewController.delegate = self;
			
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:animatedBGsViewController];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	}
}


#pragma mark - AWS Delegates
- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
	NSLog(@"\nAWS didCompleteWithResponse:\n%@", response);
	
	_uploadCounter++;
	_isUploadComplete = (_uploadCounter == 2);
	
	if (_isUploadComplete) {
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsCloudFront], _filename] forBucketType:HONS3BucketTypeSelfies completion:^(NSObject *result) {
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
		}];
	}
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"AWS didFailWithError:\n%@", error);
	
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.mode = MBProgressHUDModeCustomView;
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
	_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
	[_progressHUD show:NO];
	[_progressHUD hide:YES afterDelay:kHUDErrorTime];
	_progressHUD = nil;
}

@end
