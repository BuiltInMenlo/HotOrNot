//
//  HONChallengeToggleViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 05.21.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeToggleViewCell.h"

#import "HONAppDelegate.h"


@interface HONChallengeToggleViewCell()
@property (nonatomic, strong) UIImageView *toggleImageView;
@end

@implementation HONChallengeToggleViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		self.backgroundColor = [UIColor whiteColor];
		
		_toggleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, 9.0, 304.0, 34.0)];
		_toggleImageView.image = [UIImage imageNamed:@"homeToggle_globalActive"];
		[self addSubview:_toggleImageView];
	}
	
	return (self);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

@end
