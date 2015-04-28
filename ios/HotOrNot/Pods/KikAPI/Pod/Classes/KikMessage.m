//
//  KikMessage.m
//  Pods
//
//  Created by Anthony Wong on 2014-08-05.
//  Copyright (c) 2014 Kik Interactive. All rights reserved.
//

#define KIK_MESSENGER_API_SEND_URL              @"kik-share://kik.com/send/"
#define KIK_MESSENGER_API_PREVIEW_MAX_SIZE      @"400x400"
#define KIK_MESSENGER_API_IMAGE_MAX_SIZE        @"960x960"

#import <UIKit/UIKit.h>
#import "KikMessage.h"
#import "NSString+URLEncoding.h"
#import "UIImage+ResizeMagick.h"
#import "UIImage+Base64URI.h"

@interface KikMessage ()

- (id)initWithTitle:(NSString *)title
               text:(NSString *)text
         contentURL:(NSString *)contentURL
         previewURL:(NSString *)previewURL;

- (id)initWithImageURL:(NSString *)imageURL
            previewURL:(NSString *)previewURL;

- (id)initWithImage:(UIImage *)image;

@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSString *appPackage;
@property (nonatomic, strong) NSString *iconURL;
@end

@implementation KikMessage

#pragma mark - Public Methods

+ (KikMessage *)articleMessageWithTitle:(NSString *)title
                                   text:(NSString *)text
                             contentURL:(NSString *)contentURL
                             previewURL:(NSString *)previewURL
{
    return [[KikMessage alloc] initWithTitle:title
                                        text:text
                                  contentURL:contentURL
                                  previewURL:previewURL];
}

+ (KikMessage *)photoMessageWithImageURL:(NSString *)imageURL
                              previewURL:(NSString *)previewURL
{
    return [[KikMessage alloc] initWithImageURL:imageURL
                                     previewURL:previewURL];
}

+ (KikMessage *)photoMessageWithImage:(UIImage *)image
{
    return [[KikMessage alloc] initWithImage:image];
}

- (void)addFallbackURL:(NSString *)fallbackURL
           forPlatform:(KikMessagePlatform)platform
{
    if (![NSURL URLWithString:fallbackURL]) {
        return;
    }
    
    NSUInteger currentPriority = _URLs.count;
    
    NSString *stringPlatform;
    
    switch (platform) {
        case KikMessagePlatformAndroid:
            stringPlatform = @"android";
            break;
        case KikMessagePlatformiPhone:
            stringPlatform = @"iphone";
            break;
        case KikMessagePlatformCards:
            stringPlatform = @"cards";
            break;
        default:
            stringPlatform = @"";
            break;
    }
    
    NSDictionary *uri;
    
    uri = @{@"priority": @(currentPriority),
            @"value": fallbackURL};
    
    if (stringPlatform.length) {
        uri = @{@"priority": @(currentPriority),
                @"value": fallbackURL,
                @"platform": stringPlatform};
    } else {
        uri = @{@"priority": @(currentPriority),
                @"value": fallbackURL};
    }
    
    [_URLs addObject:uri];
}

#pragma mark - Private Methods

- (id)initWithTitle:(NSString *)title
               text:(NSString *)text
         contentURL:(NSString *)contentURL
         previewURL:(NSString *)previewURL
{
    if (![NSURL URLWithString:contentURL]) {
        return nil;
    }
    
    if (contentURL.length && ![NSURL URLWithString:previewURL]) {
        return nil;
    }
    
    if (!title && !text) {
        return nil;
    }
    
    if (self = [super init]) {
        _type = KikMessageTypeArticle;
        _title = title;
        _text = text;
        _previewURL = previewURL;
        _forwardable = YES;
        _URLs = [NSMutableArray arrayWithObject:@{@"value": contentURL}];
    }
    
    return self;
}

- (id)initWithImageURL:(NSString *)imageURL
            previewURL:(NSString *)previewURL
{
    if (![NSURL URLWithString:imageURL] || ![NSURL URLWithString:previewURL]) {
        return nil;
    }
    
    if (self = [super init]) {
        _type = KikMessageTypePhoto;
        _imageURL = imageURL;
        _previewURL = previewURL;
        _forwardable = YES;
        _URLs = [NSMutableArray array];
        
    }
    
    return self;
}

- (id)initWithImage:(UIImage *)image
{
    if (!image) {
        return nil;
    }
    
    UIImage *previewImage = [image resizedImageByMagick:KIK_MESSENGER_API_PREVIEW_MAX_SIZE];
    UIImage *contentImage = [image resizedImageByMagick:KIK_MESSENGER_API_IMAGE_MAX_SIZE];
    
    self = [self initWithImageURL:[contentImage base64URI]
                       previewURL:[previewImage base64URI]];
    
    return self;
}

- (NSString *)linkRepresentation
{
    NSMutableString *link = [NSMutableString stringWithString:KIK_MESSENGER_API_SEND_URL];
    
    if (self.type == KikMessageTypeArticle) {
        [link appendString:@"article?"];
    } else {
        [link appendString:@"photo?"];
    }
	
	NSLog(@"link:[%@]", link);
	NSLog(@"self.appName:[%@]", self.appName);
	NSLog(@"self.appPackage:[%@]", self.appPackage);
	NSLog(@"self.title:[%@]", self.title);
	NSLog(@"self.text:[%@]", self.text);
	
    [link appendString:[NSString stringWithFormat:@"app_name=%@", [self.appName urlEncodeUsingEncoding:NSUTF8StringEncoding]]];
    [link appendString:[NSString stringWithFormat:@"&app_pkg=%@", [self.appPackage urlEncodeUsingEncoding:NSUTF8StringEncoding]]];
    
    if (self.title.length) {
        [link appendString:[NSString stringWithFormat:@"&title=%@", [self.title urlEncodeUsingEncoding:NSUTF8StringEncoding]]];
    }
    
    if (self.text.length) {
        [link appendString:[NSString stringWithFormat:@"&text=%@", [self.text urlEncodeUsingEncoding:NSUTF8StringEncoding]]];
    }
    
    if (self.forwardable) {
        [link appendString:@"&forwardable=1"];
    } else {
        [link appendString:@"&forwardable=0"];
    }
    
    for (NSDictionary *uri in self.URLs) {
        NSString *platform = uri[@"platform"];
        NSString *value = [uri[@"value"] urlEncodeUsingEncoding:NSUTF8StringEncoding];
        
        if (platform.length) {
            [link appendString:[NSString stringWithFormat:@"&url=%@,%@", platform, value]];
        } else {
            [link appendString:[NSString stringWithFormat:@"&url=%@", value]];
        }
		
    }
    
    if (self.imageURL.length) {
        [link appendString:[NSString stringWithFormat:@"&image_url=%@",
                            [self.imageURL urlEncodeUsingEncoding:NSUTF8StringEncoding]]];
    }
    
    if (self.previewURL.length) {
        [link appendString:[NSString stringWithFormat:@"&preview_url=%@",
                            [self.previewURL urlEncodeUsingEncoding:NSUTF8StringEncoding]]];
    }
    
    [link appendString:[NSString stringWithFormat:@"&icon_url=%@", [self.iconURL urlEncodeUsingEncoding:NSUTF8StringEncoding]]];
    
    [link appendString:@"&native=1"];
    
    [link appendString:[NSString stringWithFormat:@"&referer=%@", [self.appPackage urlEncodeUsingEncoding:NSUTF8StringEncoding]]];
    
    return link;
}

- (NSString *)appName
{
    if (!_appName) {
        _appName = @"Popup";//[[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    }
    
    return _appName;
}

- (NSString *)appPackage
{
    if (!_appPackage) {
        _appPackage = [[NSBundle mainBundle] bundleIdentifier];
    }

    return _appPackage;
}

- (NSString *)iconURL
{
	
    if (!_iconURL) {
		UIImage *appIcon = [UIImage imageNamed:@"appIcon"];
        // Try to find the icon from the bundles
//        UIImage *appIcon = [UIImage imageNamed:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIconFiles"] objectAtIndex:0]];
		
        // Maybe stored in .xcasset style?
        if (!appIcon) {
            appIcon = [UIImage imageNamed: [[[[[[NSBundle mainBundle] infoDictionary]
                                               objectForKey:@"CFBundleIcons"]
                                              objectForKey:@"CFBundlePrimaryIcon"]
                                             objectForKey:@"CFBundleIconFiles"]
                                            objectAtIndex:0]];
        }
        
        // Fall back if we can't find any icon at all
        if (!appIcon) {
            appIcon = [UIImage imageNamed:@"app_store_icon"];
        }
        
        // Resize it to 32x32
        appIcon = [appIcon resizedImageByMagick:@"32x32"];
        
        _iconURL = [appIcon base64URI];

    }
    
    return _iconURL;
}

@end
