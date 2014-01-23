//
//  HONSettingsViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import "UIImageView+AFNetworking.h"

#import "HONSettingsViewCell.h"
#import "HONColorAuthority.h"
#import "HONFontAllocator.h"

@interface HONSettingsViewCell()
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *ptsLabel;
@property (nonatomic, strong) UILabel *captionLabel;
@end

@implementation HONSettingsViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initWithCaption:(NSString *)caption {
	if ((self = [super init])) {
		[super hideChevron];
		
		_caption = caption;
		_bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 70.0)];
		[self addSubview:_bgImageView];
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 21.0, 260.0, 20.0)];
		_captionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
		_captionLabel.textColor =  [[HONColorAuthority sharedInstance] honBlueTextColor];
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.text = _caption;
		[self addSubview:_captionLabel];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goSupport {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUPPORT" object:nil];
}

- (void)_goInviteSMS {
	[[Mixpanel sharedInstance] track:@"Profile - Invite via SMS Button"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];

	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"INVITE_SMS" object:nil];
}

@end
