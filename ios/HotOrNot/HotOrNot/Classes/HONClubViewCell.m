//
//  HONClubViewCell.m
//  HotOrNot
//
//  Created by BIM  on 8/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "NSString+DataTypes.h"
#import "UILabel+FormattedText.h"

#import "HONClubViewCell.h"
#import "HONClubPhotoVO.h"
#import "HONImageLoadingView.h"

@interface HONClubViewCell ()
@property (nonatomic, strong) UIView *statsHolderView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) NSMutableArray *statusUpdateVOs;
@property (nonatomic, strong) NSMutableArray *statusUpdateViews;
@property (nonatomic, strong) HONImageLoadingView *statusUpdateImageLoadingView;
@property (nonatomic, retain) HONClubPhotoVO *statusUpdateVO;
@end

const CGRect kOrgLoaderFrame = {17.0f, 17.0f, 42.0f, 44.0f};

@implementation HONClubViewCell
@synthesize delegate = _delegate;
@synthesize contactUserVO = _contactUserVO;
@synthesize trivialUserVO = _trivialUserVO;
@synthesize clubVO = _clubVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(28.0, 23.0, 190.0, 26.0)];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
		_titleLabel.textColor = [UIColor blackColor];
		[self.contentView addSubview:_titleLabel];
		
		_subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.frame.origin.x, 38.0, 200.0, 14.0)];
		_subtitleLabel.backgroundColor = [UIColor clearColor];
		_subtitleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:11];
		_subtitleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		[self.contentView addSubview:_subtitleLabel];
		
		_statsHolderView = [[UIView alloc] initWithFrame:CGRectMake(275.0, 30.0, 16.0, 16.0)];
		[self.contentView addSubview:_statsHolderView];
		
		_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(270.0, 30.0, 34.0, 14.0)];
		_timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
		_timeLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		_timeLabel.backgroundColor = [UIColor clearColor];
		_timeLabel.textAlignment = NSTextAlignmentRight;
		[self.contentView addSubview:_timeLabel];
	}
	
	return (self);
	
}

- (id)initAsCellType:(HONClubViewCellType)cellType {
	if ((self = [self init])) {
		_cellType = cellType;
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setContactUserVO:(HONContactUserVO *)contactUserVO {
	_contactUserVO = contactUserVO;
	
	NSString *nameCaption = _contactUserVO.fullName;//[NSString stringWithFormat:@"Invite %@ to this app", _contactUserVO.fullName];
	_titleLabel.text = nameCaption;
	_titleLabel.attributedText = [[NSAttributedString alloc] initWithString:nameCaption attributes:@{}];
	[_titleLabel setFont:_titleLabel.font range:[nameCaption rangeOfString:_contactUserVO.fullName]];
	
	
	CGSize size = [[nameCaption stringByAppendingString:@""] boundingRectWithSize:_titleLabel.frame.size
																		  options:NSStringDrawingTruncatesLastVisibleLine
																	   attributes:@{NSFontAttributeName:_titleLabel.font}
																		  context:nil].size;
	_titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, MIN(_titleLabel.frame.size.width, size.width), MIN(_titleLabel.frame.size.height, size.height));
}

- (void)setTrivialUserVO:(HONTrivialUserVO *)trivialUserVO {
	_trivialUserVO = trivialUserVO;
	
	NSString *nameCaption = _trivialUserVO.username;//(_trivialUserVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? @"Me " : _trivialUserVO.username;//[NSString stringWithFormat:@"%@ is…", _trivialUserVO.username];
	_titleLabel.text = nameCaption;
	
	CGSize size = [_titleLabel.text boundingRectWithSize:_titleLabel.frame.size
												options:NSStringDrawingTruncatesLastVisibleLine
											 attributes:@{NSFontAttributeName:_titleLabel.font}
												context:nil].size;
	_titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, MIN(_titleLabel.frame.size.width, size.width), MIN(_titleLabel.frame.size.height, size.height));
}

- (void)setClubVO:(HONUserClubVO *)clubVO {
	_clubVO = clubVO;
	_statusUpdateVO = (HONClubPhotoVO *)[_clubVO.submissions firstObject];
	
	NSString *titleCaption = (_clubVO.ownerID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? @"" : [NSString stringWithFormat:@"%@, ", _clubVO.ownerName];
	
	for (HONTrivialUserVO *vo in _clubVO.activeMembers) {
		if (vo.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue])
			continue;
		titleCaption = [titleCaption stringByAppendingFormat:@"%@, ", vo.username];
	}
	
	for (HONTrivialUserVO *vo in _clubVO.pendingMembers) {
		if ([vo.username length] == 0 || vo.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue])
			continue;
		titleCaption = [titleCaption stringByAppendingFormat:@"%@, ", vo.username];
	}
	
	titleCaption = ([titleCaption rangeOfString:@", "].location != NSNotFound) ? [titleCaption substringToIndex:[titleCaption length] - 2] : titleCaption;
	_titleLabel.text = ([titleCaption length] == 0) ? @"You" : titleCaption;
	
	UILabel *statsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 16.0, 16.0)];
	statsLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
	statsLabel.textColor = [UIColor blackColor];
	statsLabel.backgroundColor = [UIColor clearColor];
	statsLabel.textAlignment = NSTextAlignmentCenter;
	statsLabel.text = [@"" stringFromInt:[_clubVO.submissions count]];
//	[_statsHolderView addSubview:statsLabel];
	
	_timeLabel.text = [[HONDateTimeAlloter sharedInstance] intervalSinceDate:_clubVO.updatedDate];
	
	_statusUpdateVOs = [NSMutableArray array];
	_statusUpdateViews = [NSMutableArray array];
	
	[_clubVO.submissions enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, MIN([_clubVO.submissions count], 1))] options:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONClubPhotoVO *vo = (HONClubPhotoVO *)obj;
		
		UIView *statusUpdateView = [self _holderViewForStatusUpdate:vo];
		statusUpdateView.frame = CGRectOffset(statusUpdateView.frame, 17.0 + (idx * 18.0), 11.0);
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
	_statusUpdateImageLoadingView.frame = kOrgLoaderFrame;
	_statusUpdateImageLoadingView.alpha = 0.75;
	[self.contentView addSubview:_statusUpdateImageLoadingView];
	
	NSString *subtitle = @"";
	if ([_statusUpdateVOs count] > 0) {
		int idx = 0;
		for (HONClubPhotoVO *vo in [_statusUpdateVOs reverseObjectEnumerator]) {
			if ([subtitle rangeOfString:vo.username].location == NSNotFound) {
				NSString *caption = [subtitle stringByAppendingString:vo.username];
				CGSize size = [caption boundingRectWithSize:_subtitleLabel.frame.size
													options:NSStringDrawingTruncatesLastVisibleLine
												 attributes:@{NSFontAttributeName:_subtitleLabel.font}
													context:nil].size;
				
				if (size.width >= _subtitleLabel.frame.size.width) {
					subtitle = [[subtitle substringToIndex:[subtitle length] - 2] stringByAppendingString:@"…"];
					break;
				}
				
				subtitle = [subtitle stringByAppendingFormat:@"%@, ", vo.username];
			}
			
			idx++;
		}
		
		HONClubPhotoVO *vo = (HONClubPhotoVO *)[_statusUpdateVOs lastObject];
		
		subtitle = [vo.username stringByAppendingFormat:@"has posted %d new emotion%@…", [vo.subjectNames count], ([vo.subjectNames count] == 1) ? @"" : @"s"];
		//subtitle = ([[subtitle substringWithRange:NSMakeRange([subtitle length] - 2, 2)] isEqualToString:@", "]) ? [subtitle substringToIndex:[subtitle length] - 2] : subtitle;
	}
	
	subtitle = ([_clubVO.activeMembers count] == 0 && [_clubVO.submissions count] == 0) ? subtitle = NSLocalizedString(@"empty_club", @"Tap and hold to invite friends") : subtitle;
	
	_titleLabel.frame = CGRectOffset(_titleLabel.frame, 35.0 + [_statusUpdateVOs count] * 18.0, 0.0);
	//_subtitleLabel.frame = CGRectOffset(_subtitleLabel.frame, [_statusUpdateVOs count] * 18.0, 0.0);
	//_subtitleLabel.text = (_clubVO.clubEnrollmentType == HONClubEnrollmentTypePending) ? NSLocalizedString(@"club_inviteSubText", @"You have been invited. Tap to join!") : subtitle;
}

- (void)hideTimeStat {
	_timeLabel.hidden = YES;
}

- (void)toggleImageLoading:(BOOL)isLoading {
	if (isLoading) {
		__block int cnt = 0.0;
		[_statusUpdateViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			UIView *view = (UIView *)obj;
			view.hidden = NO;
			
			UIImageView *imageView = (UIImageView *)[[view subviews] firstObject];
			if (imageView.image == nil) {
				void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
					_statusUpdateImageLoadingView.frame = CGRectMake(kOrgLoaderFrame.origin.x + (18.0 * ++cnt), kOrgLoaderFrame.origin.y, kOrgLoaderFrame.size.width, kOrgLoaderFrame.size.height);
					
					if (cnt >= [_statusUpdateViews count] - 1) {
						_statusUpdateImageLoadingView.hidden = YES;
						[_statusUpdateImageLoadingView stopAnimating];
						_statusUpdateImageLoadingView.frame = kOrgLoaderFrame;
					}
				};
				
				void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
					imageView.image = image;
					
					[UIView animateWithDuration:0.125 delay:(0.10 * ([_statusUpdateViews count] - idx)) options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
						view.alpha = 1.0;
						
					} completion:^(BOOL finished) {
						_statusUpdateImageLoadingView.frame = CGRectMake(kOrgLoaderFrame.origin.x + (18.0 * ++cnt), kOrgLoaderFrame.origin.y, kOrgLoaderFrame.size.width, kOrgLoaderFrame.size.height);
						
						if (cnt >= [_statusUpdateViews count] - 1) {
							_statusUpdateImageLoadingView.hidden = YES;
							[_statusUpdateImageLoadingView stopAnimating];
							_statusUpdateImageLoadingView.frame = kOrgLoaderFrame;
						}
					}];
				};
				
				[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[((HONClubPhotoVO *)[_statusUpdateVOs objectAtIndex:view.tag]).imagePrefix stringByAppendingString:kSnapThumbSuffix]]
																   cachePolicy:NSURLRequestReloadIgnoringCacheData
															   timeoutInterval:[HONAppDelegate timeoutInterval]]
								 placeholderImage:nil
										  success:imageSuccessBlock
										  failure:imageFailureBlock];
			
			} else {
				if (++cnt >= [_statusUpdateViews count] - 1) {
					_statusUpdateImageLoadingView.hidden = YES;
					[_statusUpdateImageLoadingView stopAnimating];
					_statusUpdateImageLoadingView.frame = kOrgLoaderFrame;
				}
			}
		}];
		
	} else {
		_statusUpdateImageLoadingView.frame = kOrgLoaderFrame;
		_statusUpdateImageLoadingView.alpha = 1.0;
		_statusUpdateImageLoadingView.hidden = NO;
		
		[_statusUpdateViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			UIView *view = (UIView *)obj;
			
			UIImageView *imageView = (UIImageView *)[[view subviews] firstObject];
			[imageView cancelImageRequestOperation];
		}];
	}
}

- (void)toggleUI:(BOOL)isEnabled {
	[super toggleUI:isEnabled];
}

- (void)_goDeselect {
	[super _goDeselect];
	
	NSLog(@"[*:*] clubViewCell:_goDeselect");
	
	if (_clubVO != nil) {
		if ([self.delegate respondsToSelector:@selector(clubViewCell:didSelectClub:)])
			[self.delegate clubViewCell:self didSelectClub:_clubVO];
	
	} else {
		if (_trivialUserVO != nil) {
			if ([self.delegate respondsToSelector:@selector(clubViewCell:didSelectTrivialUser:)])
				[self.delegate clubViewCell:self didSelectTrivialUser:_trivialUserVO];
		
		} else {
			if ([self.delegate respondsToSelector:@selector(clubViewCell:didSelectContactUser:)])
				[self.delegate clubViewCell:self didSelectContactUser:_contactUserVO];
		}
	}
}

- (void)_goSelect {
	[super _goSelect];
	
	NSLog(@"[*:*] clubViewCell:_goSelect");
	
	if (_clubVO != nil) {
		if ([self.delegate respondsToSelector:@selector(clubViewCell:didSelectClub:)])
			[self.delegate clubViewCell:self didSelectClub:_clubVO];
		
	} else {
		if (_trivialUserVO != nil) {
			if ([self.delegate respondsToSelector:@selector(clubViewCell:didSelectTrivialUser:)])
				[self.delegate clubViewCell:self didSelectTrivialUser:_trivialUserVO];
			
		} else {
			if ([self.delegate respondsToSelector:@selector(clubViewCell:didSelectContactUser:)])
				[self.delegate clubViewCell:self didSelectContactUser:_contactUserVO];
		}
	}
}


#pragma mark - UI Presentation
- (UIView *)_holderViewForStatusUpdate:(HONClubPhotoVO *)vo {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
	view.alpha = 0.0;
	view.hidden = YES;

	UIImageView *imageView = [[UIImageView alloc] initWithFrame:view.frame];
	[imageView setTag:0];
	[view addSubview:imageView];
	
	//[[HONImageBroker sharedInstance] maskView:imageView withMask:[UIImage imageNamed:@"statusUpdateStackMask"]];
	return (view);
}

@end
