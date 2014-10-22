//
//  HONAnimatedBGViewFlowLayout.m
//  HotOrNot
//
//  Created by BIM  on 10/22/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONAnimatedBGViewFlowLayout.h"

const CGSize kClubCollectionViewSize = {120.0, 150.0};

@implementation HONAnimatedBGViewFlowLayout

- (id)init {
	if ((self = [super init])) {
		self.itemSize = kClubCollectionViewSize;
		self.scrollDirection = UICollectionViewScrollDirectionVertical;
		self.minimumInteritemSpacing = 40.0;
		self.minimumLineSpacing = 10.0;
		self.sectionInset = UIEdgeInsetsMake(0.0, 20.0, 60.0, 20.0);
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
