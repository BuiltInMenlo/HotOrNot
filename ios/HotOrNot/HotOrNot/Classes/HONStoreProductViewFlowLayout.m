//
//  HONStoreProductViewFlowLayout.m
//  HotOrNot
//
//  Created by BIM  on 11/3/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONStoreProductViewFlowLayout.h"

const CGSize kStoreProductImageViewSize = {64.0, 64.0};
const CGSize kStoreProductImageViewSpacing = {10.0, 10.0};

@implementation HONStoreProductViewFlowLayout
- (id)init {
	if ((self = [super init])) {
		self.itemSize = kStoreProductImageViewSize;
		self.scrollDirection = UICollectionViewScrollDirectionVertical;
		self.minimumInteritemSpacing = kStoreProductImageViewSpacing.width;
		self.minimumLineSpacing = kStoreProductImageViewSpacing.height;
		self.sectionInset = UIEdgeInsetsMake(0.0, kStoreProductImageViewSpacing.width, 0.0, kStoreProductImageViewSpacing.height); //UIEdgeInsetsZero;
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
