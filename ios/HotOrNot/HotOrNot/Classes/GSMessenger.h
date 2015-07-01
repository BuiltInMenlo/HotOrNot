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
	GSCollectionViewController *viewController;
	
	NSArray *_supportedTypes;
	NSMutableArray *_selectedTypes;
}

+ (GSMessenger *)sharedInstance;

- (void)addMessengerType:(GSMessengerType)messengerType;
@end
