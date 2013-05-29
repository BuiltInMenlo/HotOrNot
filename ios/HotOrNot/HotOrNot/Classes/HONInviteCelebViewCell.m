//
//  HONInviteCelebViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 05.27.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONInviteCelebViewCell.h"
#import "HONAppDelegate.h"

@implementation HONInviteCelebViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genericRowBackground_nonActive"]];
		//self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rowGray_nonActive"]];
		
		UIImageView *chevronImageView = [[UIImageView alloc] initWithFrame:CGRectMake(285.0, 20.0, 24.0, 24.0)];
		chevronImageView.image = [UIImage imageNamed:@"chevron"];
		[self addSubview:chevronImageView];
	}
	
	return (self);
}

- (void)setContents:(NSDictionary *)dict {
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, 11.0, 38.0, 38.0)];
	imageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	imageView.image = [UIImage imageNamed:[dict objectForKey:@"image"]];
	[self addSubview:imageView];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 22.0, 180.0, 16.0)];
	nameLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:12];
	nameLabel.textColor = [HONAppDelegate honGrey635Color];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = [dict objectForKey:@"name"];
	[self addSubview:nameLabel];
}

@end
