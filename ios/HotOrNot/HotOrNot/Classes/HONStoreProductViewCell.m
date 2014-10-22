//
//  HONStoreProductViewCell.m
//  HotOrNot
//
//  Created by BIM  on 10/7/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONStoreProductViewCell.h"

@interface HONStoreProductViewCell()
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UIButton *buyButton;
@end

@implementation HONStoreProductViewCell
@synthesize isPurchased = _isPurchased;
@synthesize storeProductVO = _storeProductVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		
	}
	
	return (self);
}

- (void)setStoreProductVO:(HONStoreProductVO *)storeProductVO {
	_storeProductVO = storeProductVO;
	
	_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(66.0, 24.0, 260.0, 26.0)];
	_captionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
	_captionLabel.textColor =  [UIColor blackColor];
	_captionLabel.backgroundColor = [UIColor clearColor];
	_captionLabel.text = @"Store Item";
	[self.contentView addSubview:_captionLabel];
	
	_buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_buyButton.frame = CGRectMake(247.0, 14.0, 64.0, 44.0);
	[_buyButton setBackgroundImage:[UIImage imageNamed:@"buyButton_nonActive"] forState:UIControlStateNormal];
	[_buyButton setBackgroundImage:[UIImage imageNamed:@"buyButton_Active"] forState:UIControlStateHighlighted];
	[_buyButton addTarget:self action:@selector(_goBuy) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:_buyButton];
}


#pragma mark - Navigation
- (void)_goBuy {
	if ([self.delegate respondsToSelector:@selector(storeProductCell:purchaseStoreItem:)])
		[self.delegate storeProductCell:self purchaseStoreItem:_storeProductVO];
}


@end
