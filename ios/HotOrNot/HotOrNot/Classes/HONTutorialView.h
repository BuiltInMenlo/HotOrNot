//
//  HONTutorialView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 22:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

@class HONTutorialView;
@protocol HONTutorialViewDelegate <NSObject>
@optional
- (void)tutorialViewClose:(HONTutorialView *)tutorialView;
- (void)tutorialViewInvite:(HONTutorialView *)tutorialView;
- (void)tutorialViewSkip:(HONTutorialView *)tutorialView;
@end

@interface HONTutorialView : UIView
- (id)initWithImageURL:(NSString *)imageURL;
- (void)introWithCompletion:(void (^)(BOOL finished))completion;
- (void)outroWithCompletion:(void (^)(BOOL finished))completion;

@property (nonatomic, assign) id <HONTutorialViewDelegate> delegate;
@end
