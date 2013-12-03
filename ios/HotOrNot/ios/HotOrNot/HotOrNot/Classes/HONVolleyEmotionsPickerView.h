//
//  HONCameraSubjectsView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONEmotionVO.h"

@protocol HONVolleyEmotionsPickerViewDelegate;
@interface HONVolleyEmotionsPickerView : UIView <UITableViewDataSource, UITableViewDelegate>

- (id)initWithFrame:(CGRect)frame AsComposeSubjects:(BOOL)isCompose;

@property (nonatomic, assign) id <HONVolleyEmotionsPickerViewDelegate> delegate;
@property (nonatomic) BOOL isJoinVolley;
@end

@protocol HONVolleyEmotionsPickerViewDelegate
- (void)emotionsPickerView:(HONVolleyEmotionsPickerView *)emotionsPickerView selectEmotion:(HONEmotionVO *)emotionVO;
@end
