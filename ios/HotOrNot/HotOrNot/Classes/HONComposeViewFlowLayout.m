//
//  HONComposeViewFlowLayout.m
//  HotOrNot
//
//  Created by BIM  on 12/12/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONComposeViewFlowLayout.h"

const CGSize kComposeCollectionViewCellSize = {160.0, 160.0};
const CGSize kComposeCollectionViewCellSpacing = {0.0, 0.0};

@implementation HONComposeViewFlowLayout

- (id)init {
	if ((self = [super init])) {
		self.itemSize = kComposeCollectionViewCellSize;
		self.scrollDirection = UICollectionViewScrollDirectionVertical;
		self.minimumInteritemSpacing = kComposeCollectionViewCellSpacing.width;
		self.minimumLineSpacing = kComposeCollectionViewCellSpacing.height;
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
