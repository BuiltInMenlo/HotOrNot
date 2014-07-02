//
//  PicoSticker.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 13/12/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PicoStickerDownloadSuccessBlock)(id sticker);
typedef void (^PicoStickerDownloadFailureBlock)();

@class CandyBoxContent, PCContent;

@protocol PicoStickerDelegate <NSObject>

-(void)picoSticker:(id)sticker tappedWithContentId:(NSString *)contentId;

@end

/**
 * A subclass of UIImageView with additional helper methods to help load sticker image from app's documents directory, or from PicoCandy servers.
 */
@interface PicoSticker : UIImageView

/**
 * Initializes PicoSticker instance with NSURL pointing to location of sticker image in remote server
 * @param url NSURL pointing to location of sticker image in remote server
 */
-(id)initWithURL:(NSURL *)url;

/**
 * Initializes PicoSticker instance with CandyBoxContent instance containing information about sticker content
 * @param content CandyBoxContent instance containing information about sticker content
 */
-(id)initWithContent:(CandyBoxContent *)content;

/**
 * Initializes PicoSticker instance with PCContent instance containing information about sticker content
 * @param content PCContent instance containing information about sticker content
 */
-(id)initWithPCContent:(PCContent *)content;

/**
 * Set to YES to display an UIActivityIndicator on top of sticker image while it is being downloaded from server
 */
@property (nonatomic, assign) BOOL displayIndicator;

/**
 * NSURL object containing link to download sticker from PicoCandy's servers
 */
@property (nonatomic, readonly) NSURL *downloadURL;

/**
 * Path to location of sticker stored in device's file system
 */
@property (nonatomic, readonly) NSString *imagePath;

/**
 * File type of image contained in this PicoSticker instance. Possible values are png, gif or jpg.
 */
@property (nonatomic, readonly) NSString *fileType;

/**
 * CandyBoxContent object used to initialize this PicoSticker instance. Can only be used if instance is initialized with PicoSticker#initWithContent: method
 */
@property (nonatomic, readonly) CandyBoxContent *candyBoxContent;

/**
 * PCContent object used to initialize this PicoSticker instance. Can only be used if instance is initialized with PicoSticker#initWithPCContent: method
 */
@property (nonatomic, readonly) PCContent *pcContent;

/**
 * Assign a placeholder image as the default image while content is being fetched or downloaded
 */
@property (nonatomic, strong) UIImage *placeHolderImage;

/**
 * Assign a delegate to handle user interaction events (Touch, etc) received by PicoSticker instance
 */
@property (nonatomic, strong) id<PicoStickerDelegate> delegate;

/**
 * Downloads sticker image from PicoCandy's servers, based on URL given in downloadURL property
 */
-(void)downloadWithSuccess:(PicoStickerDownloadSuccessBlock)success fail:(PicoStickerDownloadFailureBlock)fail;

/**
 * Fetches local sticker image from device's file system, based on path given in imagePath property
 * @return Returns YES if image is loaded successfully
 */
-(BOOL)loadImageFromFileSystem;

/**
 * Informs server that PicoSticker object is being used (e.g. posted to chat room by user, selected by user for image editing etc)
 */
-(void)use;

@end
