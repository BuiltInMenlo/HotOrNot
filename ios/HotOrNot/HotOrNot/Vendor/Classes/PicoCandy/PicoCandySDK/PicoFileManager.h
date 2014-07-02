//
//  PicoFileManager.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 2/12/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PicoFileManager : NSObject

+(PicoFileManager *)sharedManager;

+(NSURL *)applicationDocumentsDirectory;

+(NSURL *)sdkDocumentsDirectory;

/**
 * This method just returns the URL to main Candy Box folder. To find folder for user's candy box, use candyBoxDirectoryForUser: method.
 * @return URL to main Candy Box folder
 */
+(NSURL *)candyBoxDirectory;

/**
 * Returns the URL to user's Candy Box folder.
 * @param userIdentifier ID for identifying user
 * @return URL to user's Candy Box folder
 */
+(NSURL *)candyBoxDirectoryForUser:(NSString *)userIdentifier;

/**
 * Retrieves full list of file urls in target directory
 * @param directory Target directory to scan files for
 * @param extensions Array of file extensions to filter results with. Set to nil if not required.
 * @return Array of URLs for files in target directory
 */
+(NSArray *)urlsForFilesInDirectory:(NSURL *)directory withExtensions:(NSArray *)extensions;

-(NSURL*)urlForContentFileNamed:(NSString *)name withExtension:(NSString *)extension withStoreUserId:(NSString *)userId;

-(NSURL *)urlForFileNamedInSDKDocumentsDirectory:(NSString *)name withExtension:(NSString *)extension;

-(BOOL)writeDictionary:(NSDictionary *)dictionary intoSDKDocumentsDirectoryWithName:(NSString *)name extension:(NSString *)extension;

-(BOOL)writeArray:(NSArray *)array intoSDKDocumentsDirectoryWithName:(NSString *)name extension:(NSString *)extension;

-(NSDictionary *)dictionaryFromSDKDocumentsDirectoryWithName:(NSString *)name extension:(NSString *)extension;

-(NSArray *)arrayFromSDKDocumentsDirectoryWithName:(NSString *)name extension:(NSString *)extension;

/**
 * Adds file to user's local candy box folder identified by user ID
 * @param fileData File data to be saved into folder
 * @param filename Name of file to be saved into folder
 * @param userIdentifier User ID
 * @return Returns YES if file is saved successfully
 */
-(BOOL)addFile:(id)fileData withFileName:(NSString *)filename forUserCandyBoxFolder:(NSString *)userIdentifier;

@end
