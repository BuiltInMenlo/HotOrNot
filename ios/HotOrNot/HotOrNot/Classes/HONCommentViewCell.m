//
//  HONCommentViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 02.20.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "UIImageView+AFNetworking.h"

#import "HONCommentViewCell.h"
#import "HONColorAuthority.h"

@implementation HONCommentViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (void)setCommentVO:(HONCommentVO *)commentVO {
	_commentVO = commentVO;
	
	UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, 13.0, 38.0, 38.0)];
	[userImageView setImageWithURL:[NSURL URLWithString:_commentVO.avatarPrefix] placeholderImage:nil];
	[self addSubview:userImageView];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(245.0, 24.0, 60.0, 16.0)];
	timeLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
	timeLabel.textColor = [UIColor colorWithRed:0.549 green:0.565 blue:0.565 alpha:1.0];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = [HONAppDelegate timeSinceDate:_commentVO.addedDate];
	[self addSubview:timeLabel];
	
	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 13.0, 180.0, 18.0)];
	usernameLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:15];
	usernameLabel.textColor = [[HONColorAuthority sharedInstance] honPercentGreyscaleColor:0.455];
	usernameLabel.backgroundColor = [UIColor clearColor];
	usernameLabel.text = [NSString stringWithFormat:@"@%@", _commentVO.username];
	[self addSubview:usernameLabel];
	
	CGSize size = [_commentVO.content sizeWithAttributes:@{NSFontAttributeName:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16]}];
	UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 33.0, 200.0, size.height)];
	contentLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16];
	contentLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	contentLabel.backgroundColor = [UIColor clearColor];
	contentLabel.text = _commentVO.content;
	[self addSubview:contentLabel];
	
	[self hideChevron];
}

@end
