//
//  PicoDownloadManager.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 11/12/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kPicoDownloadManagerIdling      = (1 << 0), // 0001 = 1
    kPicoDownloadManagerDownloading = (1 << 1), // 0010 = 2
    kPicoDownloadManagerPaused      = (1 << 2)  // 0100 = 4
} kPicoDownloadManagerStatusType;

typedef enum {
    kPicoDownloadManagerImageSizeUnknown = -1,
    kPicoDownloadManagerImageSizeSmall,
    kPicoDownloadManagerImageSizeMedium,
    kPicoDownloadManagerImageSizeLarge
} kPicoDownloadManagerImageSize;

typedef void (^PicoDownloadManagerFileDownloadSuccessBlock)(NSURL *fileURL);
typedef void (^PicoDownloadManagerFileDownloadProgressBlock)(NSURL *fileURL, NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);
typedef void (^PicoDownloadManagerFileDownloadFailureBlock)(NSURL *fileURL);

@protocol PicoDownloadObserver <NSObject>

@optional
-(void)downloadManager:(id)downloadManager fileEnqueued:(NSURL *)url thumbnail:(NSString *)thumbnail;
-(void)downloadManager:(id)downloadManager file:(NSURL *)url bytesRead:(NSUInteger)bytesRead
        totalBytesRead:(long long)totalBytesRead totalBytesExpectedToRead:(long long)totalBytesExpectedToRead;
-(void)downloadManager:(id)downloadManager fileDownloaded:(NSURL *)url;
-(void)downloadManager:(id)downloadManager fileFailedToDownload:(NSURL *)url;

@end

@interface PicoDownloadManager : NSObject

@property (nonatomic, readonly) kPicoDownloadManagerStatusType status;

/**
 * @return Singleton instance of PicoDownloadManager
 */
+(PicoDownloadManager *)sharedManager;

+(kPicoDownloadManagerImageSize)imageSizeTypeByURL:(NSURL *)url;

/**
 * Instruct instance of PicoDownloadManager to listen to application notifications
 */
-(void)registerForApplicationNotifications;

/**
 * Add file and automatically starts download queue
 * @param url URL to download file from
 * @param success Block called when file is successfully downloaded
 * @param failure Block called when file cannot be downloaded
 */
-(void)enqueueFileForDownload:(NSURL *)url success:(PicoDownloadManagerFileDownloadSuccessBlock)success fail:(PicoDownloadManagerFileDownloadFailureBlock)failure;

/**
 * Add file and automatically starts download queue, with progress block to track download progress
 * @param url URL to download file from
 * @param success Block called when file is successfully downloaded
 * @param progress Block called during file download. Use this to track file download progress
 * @param failure Block called when file cannot be downloaded
 */
-(void)enqueueFileForDownload:(NSURL *)url success:(PicoDownloadManagerFileDownloadSuccessBlock)success progress:(PicoDownloadManagerFileDownloadProgressBlock)progress fail:(PicoDownloadManagerFileDownloadFailureBlock)failure;

/**
 * Add file and automatically starts download queue, with progress block to track download progress and thumbnail image for views monitoring download
 * @param url URL to download file from
 * @param thumbnail Path to thumbnail image stored in local file system
 * @param success Block called when file is successfully downloaded
 * @param progress Block called during file download. Use this to track file download progress
 * @param failure Block called when file cannot be downloaded
 */
-(void)enqueueFileForDownload:(NSURL *)url
                    thumbnail:(NSString *)thumbnail
                      success:(PicoDownloadManagerFileDownloadSuccessBlock)success
                     progress:(PicoDownloadManagerFileDownloadProgressBlock)progress
                         fail:(PicoDownloadManagerFileDownloadFailureBlock)failure;

/**
 * Pauses any ongoing downloads
 */
-(void)pauseDownload;

/**
 * Resumes any ongoing downloads
 */
-(void)resumeDownload;

/**
 * Indicates if file download is ongoing
 * @return Returns YES if file download is ongoing
 */
-(BOOL)downloading;

/**
 * Indicates if file download is paused
 * @return Returns YES if file download is paused
 */
-(BOOL)paused;

/**
 * Indicates number of files pending to be downloaded
 * @return Number of files pending to be downloaded
 */
-(NSUInteger)numberOfFilesRemaining;

-(void)addDownloadObserver:(id<PicoDownloadObserver>)observer;

-(void)removeDownloadObserver:(id<PicoDownloadObserver>)observer;

-(void)removeAllDownloadObservers;

@end
