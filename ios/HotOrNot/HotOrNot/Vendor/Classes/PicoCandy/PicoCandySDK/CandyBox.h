//
//  CandyBox.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 8/11/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>

#ifndef __PC_BUILD_FOR_CORE_SDK__
/**
 * Name of notification that is called when CandyBox input panel is appearing
 */
extern NSString * const PCCandyBoxInputPanelWillAppear;
/**
 * Name of notification that is called when CandyBox input panel has appeared
 */
extern NSString * const PCCandyBoxInputPanelDidAppear;
/**
 * Name of notification that is called when CandyBox input panel is disappearing
 */
extern NSString * const PCCandyBoxInputPanelWillDisappear;
/**
 * Name of notification that is called when CandyBox input panel has disappeared
 */
extern NSString * const PCCandyBoxInputPanelDidDisappear;
/**
 * Name of notification that is called when a sticker in CandyBox input panel has been selected
 */
extern NSString * const PCCandyBoxInputPanelStickerSelected;
#endif

/**
 * Main class for managing tasks related to current user's CandyBox,
 * which is the main repository for storing and retrieving user's downloaded stickers.
 */
@interface CandyBox : NSObject

/**
 * Use this property to check if CandyBox is connected to PicoCandy servers.
 */
@property (nonatomic, readonly) BOOL connected;

#ifndef __PC_BUILD_FOR_CORE_SDK__
/**
 * Use this property to check if CandyBox input panel is displayed.
 */
@property (nonatomic, readonly) BOOL inputPanelDisplayed;
/**
 * Change this property to alter the size of input panel displayed.
 * @deprecated Deprecated from PicoCandy SDK v0.21 onwards. Use CandyBox#setPanelSize:orientation: method instead.
 */
@property (nonatomic, assign) CGSize panelSize DEPRECATED_ATTRIBUTE;
#endif
/**
 * Singleton instance of CandyBox. All operations involving CandyBox should go through this instance.
 * @return Singleton instance of CandyBox class
 */
+(CandyBox *)shared;

#ifndef __PC_BUILD_FOR_CORE_SDK__
/**
 * Call this method to present sticker input panel. This will overlay other visible views by adding input panel to top of view stack in KeyWindow
 */
-(void)launchInputPanel;

/**
 * Call this method to present sticker input panel. This will overlay other visible views by adding input panel to top of view stack in KeyWindow
 * @deprecated This method is deprecated from PicoCandy SDK v0.21 onwards. Use CandyBox#launchInputPanel method instead.
 */
-(void)launchInputPanelWithSize:(CGSize)size DEPRECATED_ATTRIBUTE;

/**
 * Call this method to dismiss sticker input panel.
 */
-(void)dismissInputPanel;
#endif

-(void)processURL:(NSURL *)url withRequiredAction:(NSString *)action param:(NSString *)param query:(NSDictionary *)query;

/**
 * Use this method to fetch current user's stickers. Returns array of CandyBoxContent objects, filted by date/time sticker was downloaded.
 * @return Array of CandyBoxContent objects, filtered by date/time sticker was downloaded
 */
-(NSArray *)contents;

/**
 * Use this method to fetch current user's stickers. Returns array of CandyBoxContent objects, filted by date/time sticker was used.
 * @return Array of CandyBoxContent objects, filtered by date/time sticker was downloaded
 */
-(NSArray *)recentContents;

/**
 * Use this method to fetch current user's stickers. Returns array of CandyBoxContent objects, filtered by stickers favourited by current user.
 * @return Array of CandyBoxContent objects, filtered by stickers favourited by current user
 */
-(NSArray *)favouriteContents;

/**
 * Use this method to fetch current user's stickers with Tag. Returns array of CandyBoxContent objects that matches the tag.
 * @return Array of CandyBoxContent objects, that matches the tag of current user
 */
-(NSArray *)contentsWithTag:(NSString *)tag;

/**
 * Use this method to fetch all sticker packs purchased by user
 */
-(NSDictionary *)contentGroups;

-(BOOL)markContentAsRecentlyUsed:(NSString *)contentId;

-(BOOL)removeContentFromRecentlyUsed:(NSString *)contentId;

-(BOOL)markContent:(NSString *)contentId asFavourite:(BOOL)isFav;

-(BOOL)deleteContentWithContentId:(NSString *)contentId;

#ifndef __PC_BUILD_FOR_CORE_SDK__
/**
 * Use this method to set input panel size for various interface orientations
 * @param panelSize Required size of input panel displayed
 * @param orientation Target interface orientation
 */
-(void)setPanelSize:(CGSize)panelSize orientation:(UIInterfaceOrientation)orientation;
#endif

@end

/**
 * Content object returned from contents downloaded from PicoCandy servers
 */
@interface CandyBoxContent : NSObject
/**
 * NSDate representing creation date & time of CandyBox content
 */
@property (nonatomic, copy) NSDate *createdAt;
/**
 * File name of sticker image
 */
@property (nonatomic, copy) NSString *fileName;
/**
 * URL to download sticker image from
 */
@property (nonatomic, copy) NSURL *remoteURL;
/**
 * URL pointed to location of sticker image within current app's directory
 */
@property (nonatomic, copy) NSURL *localURL;
/**
 * Unique ID of content
 */
@property (nonatomic, copy) NSString *contentId;
/**
 * Unique ID of content group that content belongs to.
 * Set to nil if not belong to any group.
 */
@property (nonatomic, copy) NSString *contentGroupId;
/**
 * File type of sticker image
 */
@property (nonatomic, copy) NSString *fileType;
/**
 * NSDate representing date & time CandyBox content was last used
 */
@property (nonatomic, copy) NSDate *usedAt;
/**
 * Boolean flag to indicate if content is favorited by user
 */
@property (nonatomic, assign) BOOL favourite;
/**
 * NSDate representing date & time CandyBox content was last updated
 */
@property (nonatomic, copy) NSDate *updatedAt;

/**
 *  NSArray array consistings the tags of content
*/
@property (nonatomic, copy) NSArray *tags;

/**
 * Returns a NSDictionary summary of all properties in CandyBoxContent instance.
 * @return NSDictionary summary of all properties in CandyBoxContent instance
 */
-(NSDictionary *)contentInfo;

@end
