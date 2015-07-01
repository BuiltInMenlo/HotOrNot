//
//  GSMessenger.h
//  HotOrNot
//
//  Created by BIM  on 6/30/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "GSMessengerProperties.h"
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

@class GSMessenger;
@protocol GSMessengerDelegate <NSObject>
@required
@optional
- (void)didCloseMessenger;
- (void)didSelectMessengerWithType:(GSMessengerType)messengerType;
- (void)didSkipMessenger;
@end
@interface GSMessenger : NSObject <GSCollectionViewControllerDelegate> {
@private
	
	NSArray *_supportedTypes;
	NSMutableArray *_selectedTypes;
	
	GSCollectionViewController *_gsViewController;
	id<GSCollectionViewControllerDelegate> _vcDelegate;
}

+ (GSMessenger *)sharedInstance;

+ (NSArray *)selectedMessengerTypes;
+ (NSArray *)supportedMessengerTypes;

- (void)addAllMessengerTypes;
- (void)addMessengerType:(GSMessengerType)messengerType;
- (void)addMessengerTypes:(NSArray *)messengerTypes;
- (void)showMessengersWithViewController:(UIViewController *)viewController;

@property (nonatomic, assign) id<GSMessengerDelegate> delegate;
@end
