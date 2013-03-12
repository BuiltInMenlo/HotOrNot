//
//  HONAlternatingRowsViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.06.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONAlternatingRowsViewCell.h"
#import "HONAppDelegate.h"

@interface HONAlternatingRowsViewCell()
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *chevronImageView;
@property (nonatomic) BOOL isGrey;
@end


@implementation HONAlternatingRowsViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		_bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 63.0)];
		[self addSubview:_bgImageView];
		
		_chevronImageView = [[UIImageView alloc] initWithFrame:CGRectMake(273.0, 18.0, 24.0, 24.0)];
		_chevronImageView.image = [UIImage imageNamed:@"chevron"];
		[self addSubview:_chevronImageView];
	}
	
	return (self);
}

- (id)initAsGreyCell:(BOOL)grey {
	if ((self = [self init])) {
		_isGrey = grey;
		_bgImageView.image = [UIImage imageNamed:@"genericRowBackground_nonActive"];
	}
	
	return (self);
}

- (void)hideChevron {
	_chevronImageView.hidden = YES;
}


- (void)didSelect {
	_bgImageView.image = [UIImage imageNamed:@"genericRowBackground_Active"];
	[self performSelector:@selector(_resetBG) withObject:nil afterDelay:0.33];
}

- (void)_resetBG {
	_bgImageView.image = [UIImage imageNamed:@"genericRowBackground_nonActive"];
}

@end
