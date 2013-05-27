//
//  HONInviteViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 5/25/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONInviteViewCell.h"

#import "HONAppDelegate.h"

@implementation HONInviteViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
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
