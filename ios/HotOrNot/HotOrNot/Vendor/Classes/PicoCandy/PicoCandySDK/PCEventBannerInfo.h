//
//  PCCandyStoreBannerInfo.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 6/12/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCEssentials/PCEssentials.h"

@interface PCEventBannerInfo : PCModelObject

@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) CGSize maxSize;

@end
