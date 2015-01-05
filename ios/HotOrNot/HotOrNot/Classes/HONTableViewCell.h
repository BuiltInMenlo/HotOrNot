//
//  HONTableViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 3/17/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


@protocol HONTableViewCellDelegate <NSObject>
@optional
@end

@interface HONTableViewCell : UITableViewCell {
	BOOL _accessoryViewsVisible;
}

+ (NSString *)cellReuseIdentifier;
- (void)hideChevron;
- (void)accVisible:(BOOL)isVisible;
- (void)toggleChevron;
- (void)removeBackground;
- (void)destroy;
- (BOOL)accessoryViewsVisible;

- (BOOL)isFirstCellInSection;
- (BOOL)isLastCellInSection;

@property (nonatomic, assign) id <HONTableViewCellDelegate> delegate;

@property (nonatomic) CGSize size;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, assign) NSInteger rowIndex;
@end
