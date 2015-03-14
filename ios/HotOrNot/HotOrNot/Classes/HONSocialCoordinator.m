//
//  HONContactsAssistant.m
//  HotOrNot
//
//  Created by Matt Holcombe on 07/26/2014 @ 11:50 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "HONSocialCoordinator.h"

NSString * const kSocialPlatformDefaultKey		= @"default";
NSString * const kSocialPlatformClipboardKey	= @"clipboard";
NSString * const kSocialPlatformInstagamKey		= @"instagram";
NSString * const kSocialPlatformSMSKey			= @"sms";
NSString * const kSocialPlatformEmailKey		= @"email";
NSString * const kSocialPlatformTwitterKey		= @"twitter";
NSString * const kSocialPlatformFacebookKey		= @"facebook";
NSString * const kSocialPlatformKikKey			= @"kik";
NSString * const kSocialPlatformDownloadKey		= @"download";


@implementation HONSocialCoordinator
static HONSocialCoordinator *sharedInstance = nil;

+ (HONSocialCoordinator *)sharedInstance {
	static HONSocialCoordinator *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[self alloc] init];
	});
	
	return (s_sharedInstance);
}

- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}

+ (NSString *)shareMessageForSocialPlatform:(HONSocialPlatformShareType)shareType {
	NSString *key = kSocialPlatformDefaultKey;
	
	if (shareType == HONSocialPlatformShareTypeClipboard) {
		key = kSocialPlatformClipboardKey;
		
	} else if (shareType == HONSocialPlatformShareTypeInstagram) {
		key = kSocialPlatformInstagamKey;
		
	} else if (shareType == HONSocialPlatformShareTypeSMS) {
		key = kSocialPlatformSMSKey;
		
	} else if (shareType == HONSocialPlatformShareTypeEmail) {
		key = kSocialPlatformEmailKey;
		
	} else if (shareType == HONSocialPlatformShareTypeTwitter) {
		key = kSocialPlatformTwitterKey;
		
	} else if (shareType == HONSocialPlatformShareTypeFacebook) {
		key = kSocialPlatformFacebookKey;
		
	} else if (shareType == HONSocialPlatformShareTypeKik) {
		key = kSocialPlatformKikKey;
	}
	
	NSDictionary *shareFormats = [[NSUserDefaults standardUserDefaults] objectForKey:@"share_formats"];
	return (([key isEqualToString:kSocialPlatformEmailKey]) ? [NSString stringWithFormat:@"%@|%@", [[shareFormats objectForKey:key] objectForKey:@"subject"], [[shareFormats objectForKey:key] objectForKey:@"body"]] : [shareFormats objectForKey:key]);
}

+ (UIImage *)shareImageForSocialPlatform:(HONSocialPlatformShareType)shareType {
	NSString *key = kSocialPlatformDefaultKey;
	
	if (shareType == HONSocialPlatformShareTypeClipboard) {
		key = kSocialPlatformClipboardKey;
		
	} else if (shareType == HONSocialPlatformShareTypeInstagram) {
		key = kSocialPlatformInstagamKey;
		
	} else if (shareType == HONSocialPlatformShareTypeSMS) {
		key = kSocialPlatformSMSKey;
		
	} else if (shareType == HONSocialPlatformShareTypeEmail) {
		key = kSocialPlatformEmailKey;
		
	} else if (shareType == HONSocialPlatformShareTypeTwitter) {
		key = kSocialPlatformTwitterKey;
		
	} else if (shareType == HONSocialPlatformShareTypeFacebook) {
		key = kSocialPlatformFacebookKey;
		
	} else if (shareType == HONSocialPlatformShareTypeKik) {
		key = kSocialPlatformKikKey;
	}
	
	return ([UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:[@"share_template-" stringByAppendingString:key]]]);
}


- (void)presentActionSheetForSharingWithMetaData:(NSDictionary *)metaData {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Copy Chat URL", @"Share on Twitter", @"Share on SMS", @"Share on Email", nil];
	[actionSheet showInView:[[UIApplication sharedApplication].windows firstObject]];
}

- (void)presentSocialPlatformForSharing:(HONSocialPlatformShareType)shareType withMetaData:(NSDictionary *)metaData {
	UIViewController *rootViewController = [HONAppDelegate topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
	if (shareType == HONSocialPlatformShareTypeClipboard) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - copy_clipboard"];
		
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		pasteboard.string = [NSString stringWithFormat:[HONSocialCoordinator shareMessageForSocialPlatform:HONSocialPlatformShareTypeClipboard], [metaData objectForKey:@"deeplink"]];
		
		[[[UIAlertView alloc] initWithTitle:@"Paste anywhere to share!"
									message:@""
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
		
	} else if (shareType == HONSocialPlatformShareTypeEmail) {
		if ([MFMailComposeViewController canSendMail]) {
			MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
			mailComposeViewController.delegate = (id<UINavigationControllerDelegate>)self;
			[mailComposeViewController setSubject:[[[HONSocialCoordinator shareMessageForSocialPlatform:HONSocialPlatformShareTypeEmail] componentsSeparatedByString:@"|"] firstObject]];
			[mailComposeViewController setMessageBody:[NSString stringWithFormat:[[[HONSocialCoordinator shareMessageForSocialPlatform:HONSocialPlatformShareTypeEmail] componentsSeparatedByString:@"|"] lastObject], [metaData objectForKey:@"deeplink"]] isHTML:NO];
			mailComposeViewController.mailComposeDelegate = (id<MFMailComposeViewControllerDelegate>)self;
			
//			HONAppDelegate *appDelegate = ((HONAppDelegate *)[UIApplication sharedApplication].delegate);
//			appDelegate.
//			
			[rootViewController presentViewController:mailComposeViewController
											 animated:YES
										   completion:^(void) {}];
			
//			[[[UIApplication sharedApplication].windows firstObject] presentViewController:mailComposeViewController
//																	   animated:YES
//																	 completion:^(void) {}];
//			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"Email Error"
										message:@"Cannot send email from this device!"
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
		}
		
	} else if (shareType == HONSocialPlatformShareTypeInstagram) {
		NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/selfieclub_instagram.igo"];
		[[HONImageBroker sharedInstance] saveForInstagram:[HONSocialCoordinator shareImageForSocialPlatform:HONSocialPlatformShareTypeInstagram]
											 withUsername:[[HONUserAssistant sharedInstance] activeUsername]
												   toPath:savePath];
		
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://app"]]) {
			UIDocumentInteractionController *documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
			documentInteractionController.UTI = @"com.instagram.exclusivegram";
			documentInteractionController.delegate = (id<UIDocumentInteractionControllerDelegate>)self;
			documentInteractionController.annotation = @{@"InstagramCaption"	: [NSString stringWithFormat:[HONSocialCoordinator shareMessageForSocialPlatform:HONSocialPlatformShareTypeInstagram], [metaData objectForKey:@"deeplink"]]};
			
			[documentInteractionController presentOpenInMenuFromRect:CGRectZero
															  inView:rootViewController.view animated:YES];
			
		} else {
			[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"alert_instagramError_t", nil) //@"Not Available"
										message:@"This device isn't allowed or doesn't recognize Instagram!"
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
		}
		
	} else if (shareType == HONSocialPlatformShareTypeSMS) {
		if ([MFMessageComposeViewController canSendText]) {
			MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
			messageComposeViewController.body = [NSString stringWithFormat:[HONSocialCoordinator shareMessageForSocialPlatform:HONSocialPlatformShareTypeSMS], [metaData objectForKey:@"deeplink"]];
			messageComposeViewController.messageComposeDelegate = (id<MFMessageComposeViewControllerDelegate>)self;
			
			[rootViewController presentViewController:messageComposeViewController
											 animated:YES
										   completion:^(void) {}];
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"SMS Error"
										message:@"Cannot send SMS from this device!"
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
		}
		
	} else if (shareType == HONSocialPlatformShareTypeTwitter) {
		if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
			SLComposeViewController *twitterComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
			SLComposeViewControllerCompletionHandler completionBlock = ^(SLComposeViewControllerResult result) {
				[twitterComposeViewController dismissViewControllerAnimated:YES completion:nil];
			};
			
			[twitterComposeViewController setInitialText:[NSString stringWithFormat:[HONSocialCoordinator shareMessageForSocialPlatform:HONSocialPlatformShareTypeTwitter], [metaData objectForKey:@"deeplink"]]];
			[twitterComposeViewController addImage:[[HONUserAssistant sharedInstance] activeUserAvatar]];
			twitterComposeViewController.completionHandler = completionBlock;
			
			[rootViewController presentViewController:twitterComposeViewController
											 animated:YES
										   completion:nil];
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@""
										message:@"Cannot use Twitter from this device!"
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
		}
		
	} else if (shareType == HONSocialPlatformShareTypeFacebook) {
	} else if (shareType == HONSocialPlatformShareTypeKik) {
	} else if (shareType == HONSocialPlatformShareTypeDefault) {
	}
}



+ (NSString *)kikCardURL {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"kik_card"]);
}

+ (NSString *)shareURL {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"share_url"]);
}


- (BOOL)hasAdressBookPermission {
	return (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized);
}


- (NSArray *)deviceContactsSortedByName:(BOOL)isSorted {
	NSMutableArray *contactVOs = [NSMutableArray array];
	NSMutableArray *contactDicts = [NSMutableArray array];
	
	CFErrorRef error = NULL;
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
	if (error)
		return (@[]);
	
	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
	CFIndex nPeople = MIN(600, ABAddressBookGetPersonCount(addressBook));
	
	for (int i=0; i<nPeople; i++) {
		ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
		
		NSString *fName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
		NSString *lName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
		
		fName = ([fName isEqual:[NSNull null]] || [fName length] == 0) ? @"" : [fName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		lName = ([lName isEqual:[NSNull null]] || [lName length] == 0) ? @"" : [lName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		if ([fName length] == 0 && [lName length] == 0) {
			continue;
		}
		
		
		NSData *imageData = nil;
		if (ABPersonHasImageData(ref))
			imageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
		imageData = (imageData == nil) ? UIImagePNGRepresentation([UIImage imageNamed:@"avatarPlaceholder"]) : imageData;
		
		
		ABMultiValueRef phoneProperties = ABRecordCopyValue(ref, kABPersonPhoneProperty);
		CFIndex phoneCount = ABMultiValueGetCount(phoneProperties);
		NSString *phoneNumber = (phoneCount > 0) ? (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, 0) : @"";
		CFRelease(phoneProperties);
		
		
		ABMultiValueRef emailProperties = ABRecordCopyValue(ref, kABPersonEmailProperty);
		CFIndex emailCount = ABMultiValueGetCount(emailProperties);
		NSString *email = (emailCount > 0) ? (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailProperties, 0) : @"";
		CFRelease(emailProperties);
		
		
		if ((fName != nil && lName != nil && phoneNumber != nil && email != nil && imageData != nil) && ([phoneNumber length] > 0 || [email length] > 0)) {
			[contactDicts addObject:@{@"f_name"	: fName,
									  @"l_name"	: lName,
									  @"phone"	: phoneNumber,
									  @"email"	: email,
									  @"image"	: imageData}];
		}
	}
	
	if (isSorted) {
		NSString *sortKey = (ABPersonGetSortOrdering() == kABPersonCompositeNameFormatFirstNameFirst) ? @"f_name" : @"l_name";
		contactDicts = [[NSArray arrayWithArray:[contactDicts sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]] mutableCopy];
	}
	
	[contactDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSDictionary *dict = (NSDictionary *)obj;
		
//		NSLog(@"CONTACT:[%d]=- (%@)(%@)", idx, [dict objectForKey:@"f_name"], [dict objectForKey:@"l_name"]);
		[contactVOs addObject:[HONContactUserVO contactWithDictionary:dict]];
	}];
	
	return ([contactVOs copy]);
}


- (int)totalInvitedContacts {
	NSLog(@"INVITES:[%ld]", (unsigned long)[[[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] count]);
	return (([[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] == nil) ? 0 : (int)[[[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] count]);
}


- (void)writeContactUser:(HONContactUserVO *)contactUserVO toInvitedClub:(HONUserClubVO *)clubVO {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] == nil)
		[[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"club_invites"];
	
	NSMutableArray *invites = [[[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] mutableCopy];
	NSLog(@"CLUB INVITES:[%@]", invites);
	
	BOOL isFound = NO;
	for (NSDictionary *dict in invites) {
		if ([[dict objectForKey:@"club_id"] isEqualToString:NSStringFromInt(clubVO.clubID)] && [[dict objectForKey:@"phone"] isEqualToString:contactUserVO.mobileNumber]) {
			isFound = YES;
			break;
		}
	}
	
	if (!isFound) {
		[invites addObject:@{@"club_id"		: @(clubVO.clubID),
							 @"user_id"		: NSStringFromInt(0),
							 @"phone"		: contactUserVO.mobileNumber}];
		
		[[NSUserDefaults standardUserDefaults] setObject:[invites copy] forKey:@"club_invites"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void)writeTrivialUser:(HONTrivialUserVO *)trivialUserVO toInvitedClub:(HONUserClubVO *)clubVO {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] == nil)
		[[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"club_invites"];
	
	
	NSMutableArray *invites = [[[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] mutableCopy];
	NSLog(@"CLUB INVITES:[%@]", invites);
	
	BOOL isFound = NO;
	for (NSDictionary *dict in invites) {
		if ([[dict objectForKey:@"club_id"] isEqualToString:NSStringFromInt(clubVO.clubID)] && [[dict objectForKey:@"user_id"] isEqualToString:NSStringFromInt(trivialUserVO.userID)]) {
			isFound = YES;
			break;
		}
	}
	
	if (!isFound) {
		[invites addObject:@{@"club_id"		: @(clubVO.clubID),
							 @"user_id"		: @(trivialUserVO.userID),
							 @"phone"		: @""}];
		
		[[NSUserDefaults standardUserDefaults] setObject:[invites copy] forKey:@"club_invites"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (BOOL)isContactUserInvitedToClubs:(HONContactUserVO *)contactUserVO {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] == nil)
		[[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"club_invites"];
	
//	NSLog(@"CLUB INVITES:[%@]", [[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"]);
	
	BOOL isFound = NO;
//	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"]) {
//		for (NSString *key in @[@"owned", @"member"]) {
//			for (NSDictionary *clubDict in [[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:key]) {
//				HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:clubDict];
//				
//				if ([[dict objectForKey:@"club_id"] isEqualToString:NSStringFromInt(vo.clubID)] && [[dict objectForKey:@"phone"] isEqualToString:contactUserVO.mobileNumber]) {
//					isFound = YES;
//					break;
//				}
//			}
//		}
//	}
	
	return (isFound);
}

- (BOOL)isTrivialUserInvitedToClubs:(HONTrivialUserVO *)trivialUserVO {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] == nil)
		[[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"club_invites"];
	
	NSLog(@"CLUB INVITES:[%@]", [[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"]);
	
	BOOL isFound = NO;
//	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"]) {
//		for (NSString *key in @[@"owned", @"member"]) {
//			for (NSDictionary *clubDict in [[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:key]) {
//				if ([[dict objectForKey:@"club_id"] intValue] == [[clubDict objectForKey:@"club_id"] intValue] && [[dict objectForKey:@"user_id"] intValue] == trivialUserVO.userID) {
//					isFound = YES;
//					break;
//				}
//			}
//		}
//	}
	
	return (isFound);
}

- (BOOL)isContactUser:(HONContactUserVO *)contactUserVO invitedToClub:(HONUserClubVO *)clubVO {
	__block BOOL isFound = NO;
	[clubVO.pendingMembers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
		if (contactUserVO.isSMSAvailable)
			isFound = ([contactUserVO.mobileNumber isEqualToString:vo.altID]);
		
		else
			isFound = ([contactUserVO.email isEqualToString:vo.altID]);
		
		*stop = isFound;
	}];
	
	return (isFound);
	
//	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] == nil)
//		[[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"club_invites"];
//	
//	NSLog(@"CLUB INVITES:[%@]", [[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"]);
//	
//	__block BOOL isFound = NO;
//	[[[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//		NSDictionary *dict = (NSDictionary *)obj;
//		
//		if ([[dict objectForKey:@"club_id"] isEqualToString:NSStringFromInt(clubVO.clubID)] && [[dict objectForKey:@"phone"] isEqualToString:contactUserVO.mobileNumber]) {
//			isFound = YES;
//			*stop = YES;
//		}
//	}];
//	
//	return (isFound);
}

- (BOOL)isTrivialUser:(HONTrivialUserVO *)trivialUserVO invitedToClub:(HONUserClubVO *)clubVO {
	
	__block BOOL isFound = NO;
	[clubVO.pendingMembers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
		isFound = (trivialUserVO.userID == vo.userID);
		*stop = isFound;
	}];
	
	return (isFound);
	
	
//	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] == nil)
//		[[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"club_invites"];
//	
//	NSLog(@"CLUB INVITES:[%@]", [[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"]);
//	
//	__block BOOL isFound = NO;
//	[[[NSUserDefaults standardUserDefaults] objectForKey:@"club_invites"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//		NSDictionary *dict = (NSDictionary *)obj;
//		
//		if ([[dict objectForKey:@"club_id"] isEqualToString:NSStringFromInt(clubVO.clubID]] && [[dict objectForKey:@"user_id"] isEqualToString:NSStringFromInt(trivialUserVO.userID)]) {
//			isFound = YES;
//			*stop = YES;
//		}
//	}];
//	
//	return (isFound);
}

- (void)writeTrivialUserToDeviceContacts:(HONTrivialUserVO *)trivialUserVO {
	CFErrorRef error = NULL;
	
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
	
	if (error)
		NSLog(@"ERROR(ABAddressBookRef): - [%@]", error);
	
	ABRecordRef person = ABPersonCreate();
	
	
	int len = arc4random_uniform(7) + 4;
	NSMutableString *fName = [NSMutableString stringWithCapacity:len];
	for (int i=0; i<len; i++)
		[fName appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
	
	
	len = arc4random_uniform(13) + 5;
	NSMutableString *lName = [NSMutableString stringWithCapacity:len];
	for (int i=0; i<len; i++)
		[lName appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
	
	
	ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)(fName), &error);
	if (error)
		NSLog(@"ERROR(kABPersonFirstNameProperty): - [%@]", error);
	
	
	ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFTypeRef)(lName), &error);
	if (error)
		NSLog(@"ERROR(kABPersonLastNameProperty): - [%@]", error);
	
	
	NSString *phoneNumber = @"";
	NSString *email = @"";
	
	if (arc4random_uniform(100) < 50) {
		for (int i=0; i<3; i++)
			phoneNumber = [phoneNumber stringByAppendingString:NSStringFromInt((arc4random() % 9))];
		
		for (int i=0; i<3; i++)
			phoneNumber = [phoneNumber stringByAppendingString:NSStringFromInt((arc4random() % 9))];
		
		for (int i=0; i<4; i++)
			phoneNumber = [phoneNumber stringByAppendingString:NSStringFromInt((arc4random() % 9))];
		
	} else {
		len = arc4random_uniform(10) + 5;
		for (int i=0; i<len; i++)
			email = [email stringByAppendingFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
		
		email = [email stringByAppendingString:@"@"];
		
		len = arc4random_uniform(10) + 5;
		for (int i=0; i<len; i++)
			email = [email stringByAppendingFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
		
		email = [email stringByAppendingString:@".com"];
	}
	
	if ([phoneNumber length] > 0) {
		ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
		
		int phoneType = arc4random_uniform(4);
		CFStringRef phoneLabel;
		
		if (phoneType == 0)
			phoneLabel = kABPersonPhoneMobileLabel;
		
		else if (phoneType == 1)
			phoneLabel = kABPersonPhoneIPhoneLabel;
		
		else if (phoneType == 2)
			phoneLabel = kABPersonPhoneHomeFAXLabel;
		
		else
			phoneLabel = kABPersonPhoneMainLabel;
		
		
		ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(phoneNumber), phoneLabel, NULL);
		ABRecordSetValue(person, kABPersonPhoneProperty, multiPhone, &error);
		if (error)
			NSLog(@"ERROR(kABPersonPhoneProperty):[%@]", error);
		
		CFRelease(multiPhone);
	}
	
	if ([email length] > 0) {
		int emailType = arc4random_uniform(3);
		CFStringRef emailLabel;
		
		if (emailType == 0)
			emailLabel = kABWorkLabel;
		
		else if (emailType == 1)
			emailLabel = kABHomeLabel;
		
		else
			emailLabel = kABOtherLabel;
		
		ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
		ABMultiValueAddValueAndLabel(multiEmail, (__bridge CFTypeRef)(email), emailLabel, NULL);
		ABRecordSetValue(person, kABPersonEmailProperty, multiEmail, &error);
		if (error)
			NSLog(@"ERROR(kABPersonEmailProperty):[%@]", error);
		
		CFRelease(multiEmail);
	}
	
	NSLog(@"ADDING:[%@ %@] (%@) {%@}", fName, lName, phoneNumber, email);
	ABAddressBookAddRecord(addressBook, person, &error);
	CFRelease(person);
	
	ABAddressBookSave(addressBook, nil);
	CFRelease(addressBook);
	
	if (error)
		NSLog(@"ERROR(ABAddressBookAddRecord):[%@]", error);
}


#pragma mark - Actionsheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSLog(@"[*:*] actionSheet:clickedButtonAtIndex:[%d][%d] [*:*]", (int)actionSheet.tag, (int)buttonIndex);
	
	NSDictionary *metaData = ([[NSUserDefaults standardUserDefaults] objectForKey:@"share"] != nil) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"share"] : nil;
	
	if (buttonIndex == HONSocialPlatformShareActionSheetTypeClipboard) {
		[[HONSocialCoordinator sharedInstance] presentSocialPlatformForSharing:HONSocialPlatformShareTypeClipboard withMetaData:metaData];
		
	} else if (buttonIndex == HONSocialPlatformShareActionSheetTypeTwitter) {
		[[HONSocialCoordinator sharedInstance] presentSocialPlatformForSharing:HONSocialPlatformShareTypeTwitter withMetaData:metaData];
		
//	} else if (buttonIndex == HONSocialPlatformShareActionSheetTypeInstagram) {
//		[[HONSocialCoordinator sharedInstance] presentSocialPlatformForSharing:HONSocialPlatformShareTypeInstagram withMetaData:metaData];
		
	} else if (buttonIndex == HONSocialPlatformShareActionSheetTypeSMS) {
		[[HONSocialCoordinator sharedInstance] presentSocialPlatformForSharing:HONSocialPlatformShareTypeSMS withMetaData:metaData];
		
	} else if (buttonIndex == HONSocialPlatformShareActionSheetTypeEmail) {
		[[HONSocialCoordinator sharedInstance] presentSocialPlatformForSharing:HONSocialPlatformShareTypeEmail withMetaData:metaData];
	}
}


#pragma mark - MailCompose Delegates
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[controller dismissViewControllerAnimated:NO completion:^(void) {
	}];
}


#pragma mark - MessageCompose Delegates
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[controller dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - DocumentInteraction Delegates
- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller {
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
	controller.delegate = nil;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
}


@end
