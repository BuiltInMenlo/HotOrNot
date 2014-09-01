//
//  HONClubViewCell.m
//  HotOrNot
//
//  Created by BIM  on 8/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONClubViewCell.h"
#import "HONClubPhotoVO.h"
#import "HONImageLoadingView.h"

@interface HONClubViewCell ()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *membersLabel;
@property (nonatomic, strong) NSMutableArray *statusUpdateVOs;
@property (nonatomic, strong) NSMutableArray *statusUpdateViews;
@property (nonatomic, strong) HONImageLoadingView *statusUpdateImageLoadingView;
@property (nonatomic) CGRect loaderStartFrame;
@end

@implementation HONClubViewCell
@synthesize delegate = _delegate;
@synthesize clubVO = _clubVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		_loaderStartFrame = CGRectMake(17.0, 17.0, 42.0, 44.0);
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(53.0, 22.0, 180.0, 17.0)];
		_nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:13];
		_nameLabel.textColor = [UIColor blackColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_nameLabel];
		
		_membersLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x, 37.0, 180.0, 14.0)];
		_membersLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:11];
		_membersLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		_membersLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_membersLabel];
	}
	
	return (self);
	
}


#pragma mark - Public APIs
- (void)setClubVO:(HONUserClubVO *)clubVO {
	_clubVO = clubVO;
	
	_nameLabel.text = _clubVO.clubName;
	_membersLabel.text = @"";
	
	_statusUpdateVOs = [NSMutableArray array];
	_statusUpdateViews = [NSMutableArray array];
	
	[_clubVO.submissions enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, MIN([_clubVO.submissions count], 3))] options:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONClubPhotoVO *vo = (HONClubPhotoVO *)obj;
		
		UIView *statusUpdateView = [self _holderViewForStatusUpdate:vo];
		statusUpdateView.frame = CGRectOffset(statusUpdateView.frame, 17.0 + (idx * 18.0), 17.0);
		[statusUpdateView setTag:idx];
		[self.contentView addSubview:statusUpdateView];
		[_statusUpdateViews addObject:statusUpdateView];
		[_statusUpdateVOs addObject:vo];
	}];
	
	if ([_clubVO.submissions count] == 0) {
		NSMutableDictionary *dict = [[[HONClubAssistant sharedInstance] emptyClubPhotoDictionary] mutableCopy];
		[dict setValue:_clubVO.coverImagePrefix forKey:@"img"];
		
		HONClubPhotoVO *vo = [HONClubPhotoVO clubPhotoWithDictionary:dict];
		
		UIView *statusUpdateView = [self _holderViewForStatusUpdate:vo];
		statusUpdateView.frame = CGRectOffset(statusUpdateView.frame, 17.0, 17.0);
		[statusUpdateView setTag:0];
		[self.contentView addSubview:statusUpdateView];
		[_statusUpdateViews addObject:statusUpdateView];
		[_statusUpdateVOs addObject:vo];
	}
	
	_statusUpdateViews = [[[_statusUpdateViews reverseObjectEnumerator] allObjects] mutableCopy];
	_statusUpdateVOs = [[[_statusUpdateVOs reverseObjectEnumerator] allObjects] mutableCopy];
	
	_statusUpdateImageLoadingView = [[HONImageLoadingView alloc] initAtPos:CGPointZero asLargeLoader:NO];
	_statusUpdateImageLoadingView.frame = _loaderStartFrame;
	_statusUpdateImageLoadingView.alpha = 0.75;
	[self.contentView addSubview:_statusUpdateImageLoadingView];
	
	NSString *members = @"";
	if ([_statusUpdateVOs count] > 0) {
		int idx = 0;
		for (HONClubPhotoVO *vo in [_statusUpdateVOs reverseObjectEnumerator]) {
			if ([members rangeOfString:vo.username].location == NSNotFound) {
				NSString *caption = [members stringByAppendingString:vo.username];
				CGSize size = [caption boundingRectWithSize:_membersLabel.frame.size
													options:NSStringDrawingTruncatesLastVisibleLine
												 attributes:@{NSFontAttributeName:_membersLabel.font}
													context:nil].size;
				
				if (size.width >= _membersLabel.frame.size.width) {
					members = [[members substringToIndex:[members length] - 2] stringByAppendingString:@"…"];
					break;
				}
				
				members = [members stringByAppendingFormat:@"%@, ", vo.username];
			}
			
			idx++;
		}
		
		members = ([[members substringWithRange:NSMakeRange([members length] - 2, 2)] isEqualToString:@", "]) ? [members substringToIndex:[members length] - 2] : members;
		
	} else {
		members = _clubVO.ownerName;
	}
	
	_nameLabel.frame = CGRectOffset(_nameLabel.frame, [_statusUpdateVOs count] * 18.0, 0.0);
	_membersLabel.frame = CGRectOffset(_membersLabel.frame, [_statusUpdateVOs count] * 18.0, 0.0);
	_membersLabel.text = members;
	
}

- (void)toggleImageLoading:(BOOL)isLoading {
	if (isLoading) {
		__block int cnt = 0.0;
		[_statusUpdateViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			UIView *view = (UIView *)obj;
			view.hidden = NO;
			
			UIImageView *imageView = (UIImageView *)[[view subviews] firstObject];
			void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
				_statusUpdateImageLoadingView.frame = CGRectMake(_loaderStartFrame.origin.x + (18.0 * ++cnt), _loaderStartFrame.origin.y, _loaderStartFrame.size.width, _loaderStartFrame.size.height);
				
				if (cnt >= [_statusUpdateViews count] - 1) {
					_statusUpdateImageLoadingView.hidden = YES;
					[_statusUpdateImageLoadingView stopAnimating];
					_statusUpdateImageLoadingView.frame = _loaderStartFrame;
				}
			};
			
			void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
				imageView.image = image;
				
				[UIView animateWithDuration:0.125 delay:(0.10 * ([_statusUpdateViews count] - idx)) options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
					view.alpha = 1.0;
					
				} completion:^(BOOL finished) {
					_statusUpdateImageLoadingView.frame = CGRectMake(_loaderStartFrame.origin.x + (18.0 * ++cnt), _loaderStartFrame.origin.y, _loaderStartFrame.size.width, _loaderStartFrame.size.height);
					
					if (cnt >= [_statusUpdateViews count] - 1) {
						_statusUpdateImageLoadingView.hidden = YES;
						[_statusUpdateImageLoadingView stopAnimating];
						_statusUpdateImageLoadingView.frame = _loaderStartFrame;
					}
				}];
			};
			
			[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[((HONClubPhotoVO *)[_statusUpdateVOs objectAtIndex:view.tag]).imagePrefix stringByAppendingString:kSnapThumbSuffix]]
															   cachePolicy:NSURLRequestReloadIgnoringCacheData
														   timeoutInterval:[HONAppDelegate timeoutInterval]]
							 placeholderImage:nil
									  success:imageSuccessBlock
									  failure:imageFailureBlock];
		}];
		
	} else {
		_statusUpdateImageLoadingView.frame = _loaderStartFrame;
		_statusUpdateImageLoadingView.alpha = 1.0;
		_statusUpdateImageLoadingView.hidden = NO;
		
		[_statusUpdateViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			UIView *view = (UIView *)obj;
			view.hidden = YES;
			
			UIImageView *imageView = (UIImageView *)[[view subviews] firstObject];
			[imageView cancelImageRequestOperation];
		}];
	}
}


#pragma mark - UI Presentation
- (UIView *)_holderViewForStatusUpdate:(HONClubPhotoVO *)vo {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 42.0, 44.0)];
	view.alpha = 0.0;

	UIImageView *imageView = [[UIImageView alloc] initWithFrame:view.frame];
	[imageView setTag:0];
	[view addSubview:imageView];
	
	[[HONImageBroker sharedInstance] maskView:imageView withMask:[UIImage imageNamed:@"statusUpdateStackMask"]];
	return (view);
}

@end
