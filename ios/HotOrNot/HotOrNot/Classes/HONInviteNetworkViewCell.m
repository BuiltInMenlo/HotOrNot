//
//  HONInviteNetworkViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 5/25/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONInviteNetworkViewCell.h"

#import "HONAppDelegate.h"

@implementation HONInviteNetworkViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genericRowBackground_nonActive"]];
		//self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rowGray_nonActive"]];
		
		UIImageView *plusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(266.0, 10.0, 44.0, 44.0)];
		plusImageView.image = [UIImage imageNamed:@"plusButton_nonActive"];
		[self addSubview:plusImageView];
	}
	
	return (self);
}

- (void)setContents:(NSDictionary *)dict {
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 12.0, 38.0, 38.0)];
	imageView.image = [UIImage imageNamed:[dict objectForKey:@"image"]];
	[self addSubview:imageView];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 24.0, 200.0, 20.0)];
	nameLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:16];
	nameLabel.textColor = [HONAppDelegate honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = [dict objectForKey:@"name"];
	[self addSubview:nameLabel];
}

@end
