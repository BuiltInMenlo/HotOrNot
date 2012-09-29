//
//  HONSettingsViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONSettingsViewCell.h"

@interface HONSettingsViewCell()
@property (nonatomic, strong) UIImageView *bgImgView;
@end

@implementation HONSettingsViewCell

@synthesize bgImgView = _bgImgView;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		_bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 70.0)];
		[self addSubview:_bgImgView];
	}
	
	return (self);
}

- (id)initAsTopCell:(int)points withSubject:(NSString *)subject {
	if ((self = [self init])) {
		_bgImgView.frame = CGRectMake(0.0, 0.0, 320.0, 55.0);
		_bgImgView.image = [UIImage imageNamed:@"headerBackground.png"];
		
		UILabel *ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 20.0, 50.0, 16.0)];
		//ptsLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//ptsLabel = [SNAppDelegate snLinkColor];
		ptsLabel.backgroundColor = [UIColor clearColor];
		ptsLabel.text = [NSString stringWithFormat:@"%d", points];
		[self addSubview:ptsLabel];
		
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(140.0, 20.0, 150.0, 16.0)];
		//subjectLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//subjectLabel = [SNAppDelegate snLinkColor];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.textAlignment = NSTextAlignmentCenter;
		subjectLabel.text = [NSString stringWithFormat:@"#%@", subject];
		[self addSubview:subjectLabel];
	}
	
	return (self);
}

- (id)initAsBottomCell {
	if ((self = [self init])) {
		_bgImgView.image = [UIImage imageNamed:@"footerRowBackground.png.png"];
	}
	
	return (self);
}

- (id)initAsMidCell:(NSString *)caption {
	if ((self = [self init])) {
		_bgImgView.image = [UIImage imageNamed:@"genericRowBackgroundnoImage.png"];
		
		UILabel *indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 25.0, 250.0, 16.0)];
		//subjectLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//subjectLabel = [SNAppDelegate snLinkColor];
		indexLabel.backgroundColor = [UIColor clearColor];
		indexLabel.text = caption;
		[self addSubview:indexLabel];
	}
	
	return (self);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

@end
