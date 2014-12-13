//
//  HONComposeImageVO.h
//  HotOrNot
//
//  Created by BIM  on 12/12/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "FLAnimatedImage.h"

#import "HONBaseVO.h"

typedef NS_ENUM(NSUInteger, HONComposeImageType) {
	HONComposeImageTypeTypeAnimated = 0,
	HONComposeImageTypeTypeStatic
};


extern NSString * const kComposeImageURLSuffix160;
extern NSString * const kComposeImageURLSuffix214;
extern NSString * const kComposeImageURLSuffix320;
extern NSString * const kComposeImageURLSuffix640;

extern NSString * const kComposeImageAnimatedFileExtension;
extern NSString * const kComposeImageStaticFileExtension;


@interface HONComposeImageVO : HONBaseVO
+ (HONComposeImageVO *)composeImageWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic) int composeImageID;
@property (nonatomic, retain) NSString *composeImageName;
@property (nonatomic) HONComposeImageType imageType;
@property (nonatomic, retain) NSString *urlPrefix;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) FLAnimatedImage *animatedImage;
@property (nonatomic) int score;
@property (nonatomic, retain) NSDate *addedDate;
@end
