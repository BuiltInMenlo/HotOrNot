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
@synthesize commentVO = _commentVO;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 14.0, 280.0, 18.0)];
		_captionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15];
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.textColor = [UIColor blackColor];
		[self addSubview:_captionLabel];
		
		_localityLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 33.0, 280.0, 16.0)];
		_localityLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:11];
		_localityLabel.backgroundColor = [UIColor clearColor];
		_localityLabel.textColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.75];
		_localityLabel.text = @"…";
		[self addSubview:_localityLabel];
	}
	
	return (self);
}

- (void)setCommentVO:(HONCommentVO *)commentVO {
	_commentVO = commentVO;
	_captionLabel.text = _commentVO.textContent;
	
	[[HONGeoLocator sharedInstance] addressForLocation:_commentVO.location onCompletion:^(NSDictionary *result) {
		_localityLabel.text = [result objectForKey:@"city"];
	}];
}

@end