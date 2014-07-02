//
//  PCCandyStoreCategory.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 25/11/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCCandyStoreCategory : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *mainTag;
@property (nonatomic, strong) NSArray *childTags;
@property (nonatomic, assign) BOOL selected;

-(id)initWithName:(NSString *)name tag:(NSString *)tag childTags:(NSArray *)childTags;

@end
