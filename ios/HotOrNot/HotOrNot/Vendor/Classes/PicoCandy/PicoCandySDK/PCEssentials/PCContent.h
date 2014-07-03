//
//  PCContent.h
//  PCEssentials
//
//  Created by PicoCandy Pte Ltd on 16/11/13.
//  Copyright (c) 2013 PicoCandy. All rights reserved.
//

#import "PCModelObject.h"
#import "PCContentPrice.h"
#import "PCBrand.h"

extern NSString * const kContentMIMETypeImagePNG;
extern NSString * const kContentMIMETypeImageJPEG;
extern NSString * const kContentMIMETypeImageGIF;

typedef enum {
    kPCContentSmallImageSize=1,
    kPCContentMediumImageSize,
    kPCContentLargeImageSize
} kPCContentImageSize;


@interface PCContent : PCModelObject

@property (nonatomic, strong) NSString *content_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *instructions;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *file_type;
@property (nonatomic, strong) NSString *entity_length;
@property (nonatomic, strong, readonly) NSString *small_image;
@property (nonatomic, strong, readonly) NSString *medium_image;
@property (nonatomic, strong, readonly) NSString *large_image;
@property (nonatomic, strong) NSNumber *brand_id;
@property (nonatomic, strong) PCBrand *brand;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, assign) BOOL downloaded;
@property (nonatomic, strong) NSArray  *content_options;
@property (nonatomic, strong) NSString *content_url;

-(NSURL *)urlForImageSize:(kPCContentImageSize)imageSize;

@end
