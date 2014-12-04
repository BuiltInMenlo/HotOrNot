//
//  HONHomeViewFlowLayout.m
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONHomeViewFlowLayout.h"

const CGSize kHomeCollectionViewCellSize = {107.0, 107.0};
const CGSize kHomeCollectionViewCellSpacing = {0.0, 0.0};

@implementation HONHomeViewFlowLayout

- (id)init {
	if ((self = [super init])) {
		self.itemSize = kHomeCollectionViewCellSize;//CGSizeFromLength(106.0);
		self.scrollDirection = UICollectionViewScrollDirectionVertical;
		self.minimumInteritemSpacing = kHomeCollectionViewCellSpacing.width;
		self.minimumLineSpacing = kHomeCollectionViewCellSpacing.height;
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
