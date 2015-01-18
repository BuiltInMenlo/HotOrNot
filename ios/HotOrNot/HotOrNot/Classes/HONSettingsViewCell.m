//
//  HONSettingsViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import "UIImageView+AFNetworking.h"

#import "HONSettingsViewCell.h"

@interface HONSettingsViewCell()
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *ptsLabel;
@property (nonatomic, strong) UILabel *captionLabel;
@end

@implementation HONSettingsViewCell
@synthesize caption = _caption;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settingsRowBG_normal"]];
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 8.0, 260.0, 26.0)];
		_captionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
		_captionLabel.textColor = [[HONColorAuthority sharedInstance]  percentGreyscaleColor:0.75];
		_captionLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_captionLabel];
	}
	
	return (self);
}

- (id)initWithCaption:(NSString *)caption {
	if ((self = [super init])) {
		_caption = caption;
		_captionLabel.text = _caption;
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setCaption:(NSString *)caption {
	_caption = caption;
	_captionLabel.text = _caption;
}

#pragma mark - Navigation
@end
