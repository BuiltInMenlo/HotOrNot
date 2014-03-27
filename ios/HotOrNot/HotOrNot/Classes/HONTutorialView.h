//
//  HONTutorialView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 22:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HONTutorialViewDelegate;
@interface HONTutorialView : UIView
- (id)initWithBGImage:(UIImage *)bgImage;
- (void)introWithCompletion:(void (^)(BOOL finished))completion;
- (void)outroWithCompletion:(void (^)(BOOL finished))completion;

@property (nonatomic, assign) id <HONTutorialViewDelegate> delegate;
@end

@protocol HONTutorialViewDelegate <NSObject>
- (void)tutorialViewClose:(HONTutorialView *)tutorialView;
@optional
- (void)tutorialViewTakeAvatar:(HONTutorialView *)tutorialView;
@end