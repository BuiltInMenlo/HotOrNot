//
//  HONStatusUpdateViewController.h
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>

#import "HONViewController.h"
#import "HONStatusUpdateVO.h"
#import "HONUserClubVO.h"

typedef NS_ENUM(NSUInteger, HONStatusUpdateActionSheetType) {
	HONStatusUpdateActionSheetTypeDownloadAvailable = 0,
	HONStatusUpdateActionSheetTypeDownloadNotAvailable
};

@interface HONStatusUpdateViewController : HONViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UITextFieldDelegate>
- (id)initWithStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO forClub:(HONUserClubVO *)clubVO;
@end
