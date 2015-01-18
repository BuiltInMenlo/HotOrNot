//
//  HONCommentItemView.m
//  HotOrNot
//
//  Created by BIM  on 12/31/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"

#import "HONCommentItemView.h"

@interface HONCommentItemView()
@property (nonatomic, strong) UIImageView *loadingImageView;
@property(nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation HONCommentItemView
@synthesize commentVO = _commentVO;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor whiteColor];
		
		_loadingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loadingDots_50"]];
		_loadingImageView.frame = CGRectOffset(_loadingImageView.frame, 15.0, 15.0);
		[self addSubview:_loadingImageView];
		
		_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 15.0, 35.0, 35.0)];
		_avatarImageView.backgroundColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.90];
		[self addSubview:_avatarImageView];
		
		[[HONViewDispensor sharedInstance] maskView:_avatarImageView withMask:[UIImage imageNamed:@"topicMask"]];
		
		_bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greyChatBubble"]];
		_bgImageView.frame = CGRectMake(57.0, 16.0, 170.0, 34.0);
		[self addSubview:_bgImageView];
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0, 24.0, 293.0, 20.0)];
		_captionLabel.font = [[[HONFontAllocator sharedInstance] cartoGothicBook] fontWithSize:15];
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.textColor = [UIColor blackColor];
		[self addSubview:_captionLabel];
		
		_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0, 63.0, 160.0, 16.0)];
		_timeLabel.font = [[[HONFontAllocator sharedInstance] cartoGothicBook] fontWithSize:12];
		_timeLabel.backgroundColor = [UIColor clearColor];
		_timeLabel.textColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.75];
		_timeLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_timeLabel];
		
		
		UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
		overlayButton.frame = CGRectFromSize(self.frame.size);
		[self addSubview:overlayButton];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setCommentVO:(HONCommentVO *)commentVO {
	_commentVO = commentVO;
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_avatarImageView.image = image;
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		NSLog(@"ERROR:[%@]", error.description);
		_avatarImageView.image = [UIImage imageNamed:@"placeholderClubPhoto_320x320"];
	};
	
	NSLog(@"URL:[%@]", _commentVO.avatarPrefix);
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_commentVO.avatarPrefix]
															   cachePolicy:kOrthodoxURLCachePolicy
														   timeoutInterval:[HONAppDelegate timeoutInterval]]
							 placeholderImage:[UIImage imageNamed:@"loadingDots_50"]
									  success:imageSuccessBlock
									  failure:imageFailureBlock];
	
	
	if (_commentVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
		_bgImageView.image = [UIImage imageNamed:@"greenChatBubble"];
		_bgImageView.frame = CGRectOffset(_bgImageView.frame, 35, 0.0);
		
		_loadingImageView.frame = CGRectOffset(_loadingImageView.frame, 265.0, 0.0);
		_avatarImageView.frame = CGRectOffset(_avatarImageView.frame, 265.0, 0.0);
		
		_captionLabel.frame = CGRectOffset(_captionLabel.frame, 35.0, 0.0);
	}
	
	CGFloat maxWidth = 250.0;
	CGSize size = [_commentVO.textContent boundingRectWithSize:_captionLabel.frame.size
										options:NSStringDrawingTruncatesLastVisibleLine
									 attributes:@{NSFontAttributeName:_captionLabel.font}
										context:nil].size;

	_captionLabel.text = _commentVO.textContent;
	
//	_bgImageView.frame = CGRectResizeWidth(_bgImageView.frame, MIN(size.width, maxWidth));
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	[dateFormatter setDateFormat:@"MM/dd/yyyy @ hh:mm a"];
	_timeLabel.text = [dateFormatter stringFromDate:_commentVO.addedDate];
}

@end
