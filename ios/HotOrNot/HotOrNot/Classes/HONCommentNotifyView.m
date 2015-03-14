//
//  HONCommentNotifyView.m
//  HotOrNot
//
//  Created by BIM  on 3/13/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "HONCommentNotifyView.h"

@interface HONCommentNotifyView()
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UILabel *localityLabel;
@end

@implementation HONCommentNotifyView
@synthesize caption = _caption;
@synthesize locality = _locality;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor whiteColor];
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 14.0, 280.0, 18.0)];
		_captionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.textColor = [UIColor blackColor];
		[self addSubview:_captionLabel];
		
		_localityLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 34.0, 280.0, 16.0)];
		_localityLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
		_localityLabel.backgroundColor = [UIColor clearColor];
		_localityLabel.textColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.75];
		[self addSubview:_localityLabel];
	}
	
	return (self);
}

- (void)setCaption:(NSString *)caption {
	_caption = caption;
	_captionLabel.text = _caption;
}

- (void)setLocality:(NSString *)locality {
	_locality = locality;
	_localityLabel.text = _locality;
}


@end
