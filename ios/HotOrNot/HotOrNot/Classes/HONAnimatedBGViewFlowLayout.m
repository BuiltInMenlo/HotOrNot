//
//  HONAnimatedBGViewFlowLayout.m
//  HotOrNot
//
//  Created by BIM  on 10/22/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONAnimatedBGViewFlowLayout.h"

const CGSize kAnimatedBGCollectionViewSize = {159.0, 158.0};
const CGSize kAnimatedBGCollectionViewSpacing = {1.0, 2.0};

@implementation HONAnimatedBGViewFlowLayout

- (id)init {
	if ((self = [super init])) {
		self.itemSize = kAnimatedBGCollectionViewSize;
		self.scrollDirection = UICollectionViewScrollDirectionVertical;
		self.minimumInteritemSpacing = kAnimatedBGCollectionViewSpacing.width;
		self.minimumLineSpacing = kAnimatedBGCollectionViewSpacing.height;
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
