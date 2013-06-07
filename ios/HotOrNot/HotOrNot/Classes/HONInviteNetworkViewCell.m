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
		
		UIImageView *chevronImageView = [[UIImageView alloc] initWithFrame:CGRectMake(286.0, 19.0, 24.0, 24.0)];
		chevronImageView.image = [UIImage imageNamed:@"chevron"];
		[self addSubview:chevronImageView];
	}
	
	return (self);
}

- (void)setContents:(NSDictionary *)dict {
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(17.0, 12.0, 38.0, 38.0)];
	imageView.image = [UIImage imageNamed:[dict objectForKey:@"image"]];
	[self addSubview:imageView];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(67.0, 25.0, 180.0, 20.0)];
	nameLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:16];
	nameLabel.textColor = [HONAppDelegate honBlueTxtColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = [dict objectForKey:@"name"];
	[self addSubview:nameLabel];
}

@end
