//
//  HONCollectionViewCell.h
//  HotOrNot
//
//  Created by BIM  on 10/22/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


@class HONCollectionViewCell;
@protocol HONCollectionViewCellDelegate <NSObject>
@optional
- (void)collectionViewCellDidSelect:(HONCollectionViewCell *)viewCell;
@end

@interface HONCollectionViewCell : UICollectionViewCell
+ (NSString *)cellReuseIdentifier;
- (void)destroy;
- (void)toggleContentVisible:(BOOL)isContentVisible;

@property (nonatomic) CGSize size;
@property (nonatomic, readonly, getter=isContentVisible) BOOL contentVisible;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, assign) id <HONCollectionViewCellDelegate> delegate;
@end
