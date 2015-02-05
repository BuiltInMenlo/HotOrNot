//
//  HONContactsAssistant.h
//  HotOrNot
//
//  Created by Matt Holcombe on 07/26/2014 @ 11:50 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>

#import "HONContactUserVO.h"
#import "HONTrivialUserVO.h"
#import "HONUserClubVO.h"

typedef NS_ENUM(NSUInteger, HONSocialPlatformShareType) {
	HONSocialPlatformShareTypeDefault = 0,
	HONSocialPlatformShareTypeClipboard,
	HONSocialPlatformShareTypeInstagram,
	HONSocialPlatformShareTypeSMS,
	HONSocialPlatformShareTypeEmail,
	HONSocialPlatformShareTypeTwitter,
	HONSocialPlatformShareTypeFacebook,
	HONSocialPlatformShareTypeKik
};

typedef NS_ENUM(NSUInteger, HONSocialPlatformShareActionSheetType) {
	HONSocialPlatformShareActionSheetTypeClipboard = 0,
	HONSocialPlatformShareActionSheetTypeTwitter,
	HONSocialPlatformShareActionSheetTypeInstagram,
	HONSocialPlatformShareActionSheetTypeSMS,
	HONSocialPlatformShareActionSheetTypeEmail
};

@interface HONSocialCoordinator : NSObject <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate>
+ (HONSocialCoordinator *)sharedInstance;

+ (NSString *)shareMessageForSocialPlatform:(HONSocialPlatformShareType)shareType;
+ (UIImage *)shareImageForSocialPlatform:(HONSocialPlatformShareType)shareType;
- (void)presentActionSheetForSharingWithMetaData:(NSDictionary *)metaData;
- (void)presentSocialPlatformForSharing:(HONSocialPlatformShareType)shareType withMetaData:(NSDictionary *)metaData;

+ (NSString *)kikCardURL;
+ (NSString *)shareURL;

- (BOOL)hasAdressBookPermission;
- (NSArray *)deviceContactsSortedByName:(BOOL)isSorted;

- (BOOL)isContactUserInvitedToClubs:(HONContactUserVO *)contactUserVO;
- (BOOL)isTrivialUserInvitedToClubs:(HONTrivialUserVO *)trivialUserVO;
- (BOOL)isContactUser:(HONContactUserVO *)contactUserVO invitedToClub:(HONUserClubVO *)clubVO;
- (BOOL)isTrivialUser:(HONTrivialUserVO *)trivialUserVO invitedToClub:(HONUserClubVO *)clubVO;

- (int)totalInvitedContacts;
- (void)writeContactUser:(HONContactUserVO *)contactUserVO toInvitedClub:(HONUserClubVO *)clubVO;
- (void)writeTrivialUser:(HONTrivialUserVO *)trivialUserVO toInvitedClub:(HONUserClubVO *)clubVO;

- (void)writeTrivialUserToDeviceContacts:(HONTrivialUserVO *)trivialUserVO;

@end
