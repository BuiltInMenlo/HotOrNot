//
//  HONRefreshingLabel.h
//  HotOrNot
//
//  Created by BIM  on 12/4/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


@interface HONRefreshingLabel : UILabel

- (void)setText:(NSString *)text;
- (void)toggleLoading:(BOOL)isLoading;
@end
