//
//  HONClubSettingsViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/01/2014 @ 14:06 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONViewController.h"
#import "HONUserClubVO.h"

@interface HONClubSettingsViewController : HONViewController <UITextFieldDelegate>
- (id)initWithClub:(HONUserClubVO *)userClubVO;
@end
