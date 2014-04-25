//
//  HONEmoticonPickerItemView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/21/2014 @ 20:44 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONEmotionVO.h"

@class HONEmoticonPickerItemView;
@protocol HONEmotionItemViewDelegate <NSObject>
- (void)emotionItemView:(HONEmoticonPickerItemView *)emotionItemView selectedEmotion:(HONEmotionVO *)emotionVO;
- (void)emotionItemView:(HONEmoticonPickerItemView *)emotionItemView deselectedEmotion:(HONEmotionVO *)emotionVO;
@end


@interface HONEmoticonPickerItemView : UIView
- (id)initAtPosition:(CGPoint)position withEmotion:(HONEmotionVO *)emotionVO;
@property (nonatomic, assign) id<HONEmotionItemViewDelegate> delegate;
@end