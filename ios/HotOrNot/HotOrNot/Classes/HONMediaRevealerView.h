//
//  HONMediaRevealerView.h
//  HotOrNot
//
//  Created by BIM  on 3/19/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "HONCommentVO.h"

@class HONMediaRevealerView;
@protocol HONMediaRevealerViewDelegate <NSObject>
@optional
- (void)mediaRevealerViewDidIntro:(HONMediaRevealerView *)mediaRevealerView;
- (void)mediaRevealerViewDidOutro:(HONMediaRevealerView *)mediaRevealerView;
@end

@interface HONMediaRevealerView : UIView
- (id)initWithComment:(HONCommentVO *)commentVO;

- (void)intro;
- (void)outro;

@property (nonatomic, assign) id <HONMediaRevealerViewDelegate> delegate;
@end
