//
//  GSCollectionViewFlowLayout.m
//  HotOrNot
//
//  Created by BIM  on 6/30/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "GSCollectionViewFlowLayout.h"

const CGSize kGSCollectionViewCellSize = {75.0, 100.0};
const CGSize kGSCollectionViewCellSpacing = {28.0, 28.0};

@implementation GSCollectionViewFlowLayout
- (id)init {
	if ((self = [super init])) {
		self.itemSize = kGSCollectionViewCellSize;
		self.scrollDirection = UICollectionViewScrollDirectionVertical;
		self.minimumInteritemSpacing = kGSCollectionViewCellSpacing.width;
		self.minimumLineSpacing = kGSCollectionViewCellSpacing.height;
		self.sectionInset = UIEdgeInsetsZero;
	}
	
	return (self);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
	return (YES);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	NSArray *array = [super layoutAttributesForElementsInRect:rect];
	
	CGRect visibleRect;
	visibleRect.origin = self.collectionView.contentOffset;
	visibleRect.size = self.collectionView.bounds.size;
	
	return (array);
}

@end
