//
//  HONImageRevealerView.h
//  HotOrNot
//
//  Created by BIM  on 3/19/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "HONCommentVO.h"

@class HONImageRevealerView;
@protocol HONImageRevealerViewDelegate <NSObject>
@optional
- (void)imageRevealerViewDidIntro:(HONImageRevealerView *)imageRevealerView;
- (void)imageRevealerViewDidOutro:(HONImageRevealerView *)imageRevealerView;
@end

@interface HONImageRevealerView : UIView
- (id)initWithComment:(HONCommentVO *)commentVO;

- (void)intro;
- (void)outro;

@property (nonatomic, assign) id <HONImageRevealerViewDelegate> delegate;
@end
