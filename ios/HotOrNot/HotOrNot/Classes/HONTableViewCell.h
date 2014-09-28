//
//  HONTableViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 3/17/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


@interface HONTableViewCell : UITableViewCell {
	BOOL _accessoryViewsVisible;
}

+ (NSString *)cellReuseIdentifier;
- (void)hideChevron;
- (void)accVisible:(BOOL)isVisible;
- (void)toggleChevron;
- (void)removeBackground;
- (BOOL)accessoryViewsVisible;

@property (nonatomic) CGSize size;
@end
