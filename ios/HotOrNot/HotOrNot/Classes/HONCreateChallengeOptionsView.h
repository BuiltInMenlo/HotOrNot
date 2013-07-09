//
//  HONCreateChallengeOptionsView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.12.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HONCreateChallengeOptionsViewDelegate;
@interface HONCreateChallengeOptionsView : UIView
@property(nonatomic, assign) id <HONCreateChallengeOptionsViewDelegate> delegate;
@end


@protocol HONCreateChallengeOptionsViewDelegate
- (void)challengeOptionsViewMakePublic:(HONCreateChallengeOptionsView *)createChallengeOptionsView;
- (void)challengeOptionsViewMakeNonExpire:(HONCreateChallengeOptionsView *)createChallengeOptionsView;
- (void)challengeOptionsViewMakePrivate:(HONCreateChallengeOptionsView *)createChallengeOptionsView;
- (void)challengeOptionsViewExpire10Minutes:(HONCreateChallengeOptionsView *)createChallengeOptionsView;
- (void)challengeOptionsViewExpire24Hours:(HONCreateChallengeOptionsView *)createChallengeOptionsView;
- (void)challengeOptionsViewClose:(HONCreateChallengeOptionsView *)createChallengeOptionsView;
@end