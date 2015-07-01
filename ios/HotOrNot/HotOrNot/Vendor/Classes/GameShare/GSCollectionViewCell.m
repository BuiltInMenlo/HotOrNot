//
//  GSMessengerViewCellCollectionViewCell.m
//  HotOrNot
//
//  Created by BIM  on 6/29/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "GSCollectionViewCell.h"

@interface GSCollectionViewCell ()
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImageView *imageView;
//@property (nonatomic, strong) UILabel *label;
@end

@implementation GSCollectionViewCell
@synthesize indexPath = _indexPath;
@synthesize delegate = _delegate;
@synthesize messengerType = _messengerType;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	NSLog(@"[:|:] [%@ init] [:|:]", self.class);
	if ((self = [super init])) {
		
	}
	
	return (self);
}

- (id)initWithFrame:(CGRect)frame {
	NSLog(@"[:|:] [%@ initWithFrame:%@] [:|:]", self.class, NSStringFromCGRect(frame));
	
	if ((self == [super initWithFrame:frame])) {
		_button = [UIButton buttonWithType:UIButtonTypeCustom];
		_button.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
		[_button setBackgroundImage:[UIImage imageNamed:@"placeholderClubPhoto_160x160"] forState:UIControlStateNormal];
		[_button setBackgroundImage:[UIImage imageNamed:@"placeholderClubPhoto_160x160"] forState:UIControlStateHighlighted];
		[_button addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_button];
	}
	
	return (self);
}

- (void)destroy {
	NSLog(@"[:|:] [%@ destroy] [:|:]", self.class);
	
	[self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)dealloc {
	NSLog(@"[:|:] [%@ dealloc] [:|:]", self.class);
	
	[self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}


#pragma mark - Public APIs
- (void)setIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"[:|:] [%@ setIndexPath:%@] [:|:]", self.class, NSStringFromNSIndexPath(indexPath));
	
	_indexPath = indexPath;
}

- (void)setSize:(CGSize)size {
	NSLog(@"[:|:] [%@ setSize:%@] [:|:]", self.class, NSStringFromCGSize(size));
	
	_size = size;
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, _size.width, _size.height);
	self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, _size.width, _size.height);
}

- (void)setMessengerVO:(GSMessengerVO *)messengerVO {
	//NSLog(@"[:|:] [%@ setMessengerVO:%@] [:|:]", self.class, messengerVO.dictionary);
	
	_messengerVO = messengerVO;
	[_button setBackgroundImage:_messengerVO.normalImage forState:UIControlStateNormal];
	[_button setBackgroundImage:_messengerVO.hilightedImage forState:UIControlStateHighlighted];
	[_button setBackgroundImage:_messengerVO.selectedImage forState:UIControlStateSelected];
	
//	NSString *resource = [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"GameShareRecources" ofType:@"bundle"]] pathForResource:@"fileName" ofType:@"png"];
	// [UIImage imageNamed:@"GameShareRecources.bundle/imageInBundle.png"];
}


#pragma mark - Navigation
- (void)_goSelect {
	if ([self.delegate respondsToSelector:@selector(collectionViewCell:didSelectMessgenger:)])
		[self.delegate collectionViewCell:self didSelectMessgenger:_messengerVO];
}

@end

