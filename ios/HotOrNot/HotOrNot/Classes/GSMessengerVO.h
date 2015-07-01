//
//  GSMessengerVO.h
//  HotOrNot
//
//  Created by BIM  on 6/30/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSMessengerVO : NSObject
+ (GSMessengerVO *)messengerWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int messengerID;
@property (nonatomic, retain) NSString *messengerName;
@property (nonatomic, retain) NSString *imagePrefix;
@property (nonatomic, retain) UIImage *normalImage;
@property (nonatomic, retain) UIImage *hilightedImage;
@property (nonatomic, retain) UIImage *selectedImage;
@property (nonatomic) BOOL sortOrder;
@property (nonatomic) BOOL isEnabled;
@end
