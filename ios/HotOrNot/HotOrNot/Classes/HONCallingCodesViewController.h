//
//  HONCallingCodesViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 05/02/2014 @ 10:08 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONCountryVO.h"

@class HONCallingCodesViewController;
@protocol HONCallingCodesViewControllerDelegate <NSObject>
- (void)callingCodesViewController:(HONCallingCodesViewController *)viewController didSelectCountry:(HONCountryVO *)countryVO;
@end

@interface HONCallingCodesViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) id <HONCallingCodesViewControllerDelegate> delegate;
@end
