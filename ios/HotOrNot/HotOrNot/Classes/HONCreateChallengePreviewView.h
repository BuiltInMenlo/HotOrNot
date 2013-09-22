//
//  HONCreateChallengePreviewView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.15.13 @ 17:17 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONUserVO.h"

@protocol HONCreateChallengePreviewViewDelegate;
@interface HONCreateChallengePreviewView : UIView
- (id)initWithFrame:(CGRect)frame withSubject:(NSString *)subject withImage:(UIImage *)image;
- (id)initWithFrame:(CGRect)frame withSubject:(NSString *)subject withMirroredImage:(UIImage *)image;
- (void)uploadComplete;
- (void)setOpponents:(NSArray *)users asJoining:(BOOL)isJoining redrawTable:(BOOL)isRedraw;
- (void)showKeyboard;

@property (nonatomic, assign) id <HONCreateChallengePreviewViewDelegate> delegate;
@property (nonatomic) BOOL isFirstCamera;
@end

@protocol HONCreateChallengePreviewViewDelegate
- (void)previewView:(HONCreateChallengePreviewView *)previewView removeChallenger:(HONUserVO *)userVO;
- (void)previewViewBackToCamera:(HONCreateChallengePreviewView *)previewView;
- (void)previewView:(HONCreateChallengePreviewView *)previewView changeSubject:(NSString *)subject;
- (void)previewViewClose:(HONCreateChallengePreviewView *)previewView;
- (void)previewViewSubmit:(HONCreateChallengePreviewView *)previewView;
@end
