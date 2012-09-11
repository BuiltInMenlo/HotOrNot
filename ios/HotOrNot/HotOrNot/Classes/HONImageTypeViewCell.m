//
//  HONImageTypeViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.10.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONImageTypeViewCell.h"

@interface HONImageTypeViewCell()
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UILabel *totalLabel;
@end

@implementation HONImageTypeViewCell

@synthesize caption = _caption;
@synthesize total = _total;

@synthesize captionLabel = _captionLabel;
@synthesize totalLabel = _totalLabel;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		self.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
		
		self.captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 20.0, 200.0, 16.0)];
		self.captionLabel.textColor = [UIColor grayColor];
		self.captionLabel.backgroundColor = [UIColor clearColor];
		self.captionLabel.text = @"DERP";
		[self addSubview:self.captionLabel];
		
		self.totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(200.0, 20.0, 120.0, 16.0)];
		self.totalLabel.textColor = [UIColor grayColor];
		self.totalLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:self.totalLabel];
		
		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 56.0, self.frame.size.width, 1.0)];
		lineView.backgroundColor = [UIColor colorWithWhite:0.33 alpha:1.0];
		[self addSubview:lineView];
	}
	
	return (self);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)setCaption:(NSString *)caption {
	_caption = caption;
	self.captionLabel.text = caption;
}

- (void)setTotal:(int)total {
	_total = total;
	self.totalLabel.text = [NSString stringWithFormat:@"%d photos", total];
}

@end
