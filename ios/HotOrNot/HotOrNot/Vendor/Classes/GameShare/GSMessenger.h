//
//  GSMessenger.h
//  HotOrNot
//
//  Created by BIM  on 6/30/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "GSMessengerProperties.h"
#import "GSCollectionViewController.h"

@interface GSMessenger : NSObject {
@private
	
	NSArray *_supportedTypes;
	NSMutableArray *_selectedTypes;
	
	GSCollectionViewController *_gsViewController;
	id<GSCollectionViewControllerDelegate> _delegate;
}

+ (GSMessenger *)sharedInstance;

- (void)addAllMessengerTypes;
- (void)addMessengerTypes:(NSArray *)messengerTypes;
- (void)addMessengerType:(GSMessengerType)messengerType;
- (void)setDelegate:(id<GSCollectionViewControllerDelegate>)delegate;
- (void)showMessengersWithViewController:(UIViewController *)viewController;
- (void)showMessengersWithViewController:(UIViewController *)viewController usingDelegate:(id<GSCollectionViewControllerDelegate>)delegate;
@end
