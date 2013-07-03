//
//  HONAddChallengersViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.12.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HONAddChallengersDelegate;
@interface HONAddChallengersViewController : UIViewController
- (id)initRecentsSelected:(NSArray *)followers friendsSelected:(NSArray *)friends contactsSelected:(NSArray *)contacts;

@property(nonatomic, assign) id <HONAddChallengersDelegate> delegate;
@end

@protocol HONAddChallengersDelegate
- (void)addChallengers:(HONAddChallengersViewController *)viewController selectFollowing:(NSArray *)following forAppending:(BOOL)isAppend;
- (void)addChallengers:(HONAddChallengersViewController *)viewController selectContacts:(NSArray *)contacts forAppending:(BOOL)isAppend;
@end
