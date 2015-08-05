//
//  HONStatusUpdateViewController.h
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "HONViewController.h"
#import "HONStatusUpdateVO.h"
#import "HONUserClubVO.h"

typedef NS_ENUM(NSUInteger, HONStatusUpdateActionSheetType) {
	HONStatusUpdateActionSheetTypeDownloadAvailable = 0,
	HONStatusUpdateActionSheetTypeDownloadNotAvailable
};

typedef NS_ENUM(NSUInteger, HONStatusUpdateAlertViewType) {
	HONStatusUpdateAlertViewTypeEmpty = 0,
	HONStatusUpdateAlertViewTypeBack,
	HONStatusUpdateAlertViewTypeFlag,
	HONStatusUpdateAlertViewTypeShare
};

@interface HONStatusUpdateViewController : HONViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UITextFieldDelegate>
- (id)initFromDeepLinkWithChannelName:(NSString *)channelName;
- (id)initWithStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO forClub:(HONUserClubVO *)clubVO;
- (id)initWithChannelName:(NSString *)channelName;
@end
