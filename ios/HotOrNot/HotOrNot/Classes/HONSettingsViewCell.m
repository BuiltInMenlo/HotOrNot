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
		[self hideChevron];
		
		_caption = caption;
		_bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 70.0)];
		[self.contentView addSubview:_bgImageView];
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 21.0, 260.0, 20.0)];
		_captionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
		_captionLabel.textColor =  [[HONColorAuthority sharedInstance] honBlueTextColor];
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.text = _caption;
		[self.contentView addSubview:_captionLabel];
	}
	
	return (self);
}


#pragma mark - Navigation
@end
