//
//  HONContactsSearchViewController.h
//  HotOrNot
//
//  Created by BIM  on 8/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONViewController.h"

@interface HONContactsSearchViewController : HONViewController <UIAlertViewDelegate, UITextFieldDelegate>
- (id)initWithClub:(HONUserClubVO *)clubVO;
@end
