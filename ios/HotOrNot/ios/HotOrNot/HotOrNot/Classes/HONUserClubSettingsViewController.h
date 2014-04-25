//
//  HONUserClubSettingsViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/01/2014 @ 14:06 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserClubVO.h"

@interface HONUserClubSettingsViewController : UIViewController <UITextFieldDelegate>
- (id)initWithClub:(HONUserClubVO *)userClubVO;
@end
