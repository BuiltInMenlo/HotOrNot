//
//  GSMessenger.h
//  HotOrNot
//
//  Created by BIM  on 6/30/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "GSMessengerShareProperties.h"
#import "GSCollectionViewController.h"

extern NSString * const kFBMessengerKey;
extern NSString * const kKakaoTalkKey;
extern NSString * const kKikKey;
extern NSString * const kLineKey;
extern NSString * const kSMSKey;
extern NSString * const kWhatsAppKey;
extern NSString * const kWeChatKey;
extern NSString * const kHikeKey;
extern NSString * const kViberKey;
extern NSString * const kOTHERKey;

@class GSMessengerShare;
@protocol GSMessengerShareDelegate <NSObject>
@required
@optional
- (void)didCloseMessengerShare;
- (void)didSelectMessengerWithType:(GSMessengerShareType)messengerType;
- (void)didSkipMessengerShare;
@end
@interface GSMessengerShare : NSObject <GSCollectionViewControllerDelegate> {
@private
	
	NSArray *_supportedTypes;
	NSMutableArray *_selectedTypes;
	
	GSCollectionViewController *_gsViewController;
	id<GSCollectionViewControllerDelegate> _vcDelegate;
}

+ (GSMessengerShare *)sharedInstance;

+ (NSArray *)selectedMessengerTypes;
+ (NSArray *)supportedMessengerTypes;

- (void)addAllMessengerShareTypes;
- (void)addMessengerShareType:(GSMessengerShareType)messengerShareType;
- (void)addMessengerShareTypes:(NSArray *)messengerShareTypes;
- (void)overrrideWithOutboundURL:(NSString *)outboundURL;
- (void)showMessengerSharePickerOnViewController:(UIViewController *)viewController;
- (void)dismissMessengerSharePicker;

@property (nonatomic, assign) id<GSMessengerShareDelegate> delegate;
@end
