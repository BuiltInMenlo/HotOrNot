//
//  KikClient.m
//  Pods
//
//  Created by Anthony Wong on 2014-08-06.
//  Copyright (c) 2014 Kik Interactive. All rights reserved.
//

#define KIK_MESSENGER_APP_STORE_ID      @"357218860"
#define KIK_MESSENGER_API_BACK_URL      @"kik-share://kik.com/back"
#define KIK_MESSENGER_API_PROFILE_URL   @"kik-share://kik.com/u/%@"

#import "KikClient.h"

@interface KikClient () <SKStoreProductViewControllerDelegate>

@end

@implementation KikClient

#pragma mark - Public Methods

+ (KikClient *)sharedInstance
{
    static KikClient *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[KikClient alloc] init];
        
        UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
        
        _sharedInstance.rootController = window.rootViewController;
    });
    return _sharedInstance;
}

- (void)backToKik
{
    NSURL *url = [NSURL URLWithString:KIK_MESSENGER_API_BACK_URL];
    [self openKikURL:url];
}

- (void)openProfileForKikUsername:(NSString *)username
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:KIK_MESSENGER_API_PROFILE_URL, username]];
    [self openKikURL:url];
}

- (void)sendKikMessage:(KikMessage *)message
{
    NSURL *url = [NSURL URLWithString:[message linkRepresentation]];
    [self openKikURL:url];
}

#pragma mark - Private Methods

/**
 *  Attempts to open the generated KikAPI URL if possible, AppStore modal otherwise.
 *
 *  @param url - the KikAPI URL to open
 */
- (void)openKikURL:(NSURL *)url
{
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    } else {
        [self showKikInAppStore];
    }
}

/**
 *  Presents Kik in an in-app modal AppStore controller
 */
- (void)showKikInAppStore
{
    SKStoreProductViewController *storeVC = [[SKStoreProductViewController alloc] init];
    NSDictionary *params = @{ SKStoreProductParameterITunesItemIdentifier : KIK_MESSENGER_APP_STORE_ID };
    storeVC.delegate = self;
    
    [storeVC loadProductWithParameters:params completionBlock:nil];
    [self.rootController presentViewController:storeVC
                                      animated:YES
                                    completion:nil];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [self.rootController dismissViewControllerAnimated:YES completion:nil];
}

@end
