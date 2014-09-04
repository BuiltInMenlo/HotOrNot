//
//  HONPostStatusUpdateViewCell.m
//  HotOrNot
//
//  Created by Anirudh Agarwala on 9/4/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONPostStatusUpdateViewCell.h"

@interface HONPostStatusUpdateViewCell()
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UIImageView *bgImageView;
@end


@implementation HONPostStatusUpdateViewCell
@synthesize caption = _caption;

- (id)initWithCaption:(NSString *)caption {
	if ((self = [super init])) {
		[self hideChevron];
		
		_caption = caption;
		_bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 70.0)];
		[self.contentView addSubview:_bgImageView];
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(26.0, 19.0, 260.0, 26.0)];
		_captionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:15];
		_captionLabel.textColor =  [UIColor blackColor];
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.text = _caption;
		[self.contentView addSubview:_captionLabel];
	}
	
	return (self);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
