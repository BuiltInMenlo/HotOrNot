//
//  KikMessage.h
//  Pods
//
//  Created by Anthony Wong on 2014-08-05.
//  Copyright (c) 2014 Kik Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    KikMessageTypeArticle = 0,
    KikMessageTypePhoto
} KikMessageType;

typedef enum {
    KikMessagePlatformGeneric = 0,
    KikMessagePlatformiPhone,
    KikMessagePlatformAndroid,
    KikMessagePlatformCards
} KikMessagePlatform;

@interface KikMessage : NSObject

/**
 *  The type of KikMessage: either an Article or Photo
 */
@property (nonatomic, assign, readonly) KikMessageType type;

/**
 *  Your app name that'll be attached to the KikMessage. This is automatically set for you.
 */
@property (nonatomic, strong, readonly) NSString *appName;

/**
 *  Your apps package that'll be attached to the KikMessage. This is automatically set for you.
 */
@property (nonatomic, strong, readonly) NSString *appPackage;

/**
 *  The icon URL that is associated to the KikMessage. This will be generated from your apps' app icon for you.
 */
@property (nonatomic, strong, readonly) NSString *iconURL;

/**
 *  The image URL that is associated with this KikMessage. Either the URL specified if you created the message via URLs
 *  or a base64 encoded image of the UIImage used in construction.
 */
@property (nonatomic, strong, readonly) NSString *imageURL;

/**
 *  The preview URL that is associated with this KikMessage. See above.
 */
@property (nonatomic, strong, readonly) NSString *previewURL;

/**
 *  The text in an Article-type content message.
 */
@property (nonatomic, strong, readonly) NSString *text;

/**
 *  The title in an Article-type content message.
 */
@property (nonatomic, strong, readonly) NSString *title;

/**
 *  The set of URLs associated with the KikMessage. This will be your contentURL/imageURL, followed by any
 *  fallback URLs.
 */
@property (nonatomic, strong, readonly) NSMutableArray *URLs;

/**
 *  Determines whether or not this KikMessage is forwardable inside of Kik.
 */
@property (nonatomic, assign) BOOL forwardable;

/**
 *  Convenience constructor to create an Article typed KikMessage.
 *
 *  @param title      The title of the Article (At least one of title or text must be set)
 *  @param text       The text of the Article (At least one of title or text must be set)
 *  @param contentURL URL of the Article you wish to send (Required)
 *  @param previewURL URL of an image thumbnail to go with the content (Optional)
 *
 *  @return The constructed KikMessage object, nil if any errors.
 */
+ (KikMessage *)articleMessageWithTitle:(NSString *)title
                                   text:(NSString *)text
                             contentURL:(NSString *)contentURL
                             previewURL:(NSString *)previewURL;

/**
 *  Convenience constructor to create a Photo typed KikMessage from URLs.
 *
 *  @param imageURL   URL of the image you wish to send. Can be a base64 encoded data URI. (Required)
 *  @param previewURL URL of the preview image you wish to send. Can be a base64 encoded data URI. (Required)
 *
 *  @return The constructed KikMessage object, nil if any errors.
 */
+ (KikMessage *)photoMessageWithImageURL:(NSString *)imageURL
                              previewURL:(NSString *)previewURL;

/**
 *  Convenience constructor to create a Photo typed KikMessage from an UIImage.
 *
 *  @param image UIImage in which to create the Photo message from.
 *
 *  @return The constructed KikMessage object, nil if any errors.
 */
+ (KikMessage *)photoMessageWithImage:(UIImage *)image;

/**
 *  Adds a fallback URL to the receiving KikMessage
 *
 *  @param fallbackURL the URL to be opened as fallback
 *  @param platform    if necessary, restrict the specified fallbackURL to a specified platform
 */
- (void)addFallbackURL:(NSString *)fallbackURL
           forPlatform:(KikMessagePlatform)platform;

/**
 *  Useful for Debugging purposes.
 *
 *  @return The generated Kik API URL that is sent to Kik Messenger.
 */
- (NSString *)linkRepresentation;

@end
