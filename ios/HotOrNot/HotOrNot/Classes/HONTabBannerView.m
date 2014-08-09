//
//  HONTabBannerView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 08/09/2014 @ 12:29 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONTabBannerView.h"
#import "HONEmotionPaginationView.h"

@interface HONTabBannerView ()
@property (nonatomic, strong) NSArray *clubs;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) HONEmotionPaginationView *paginationView;
@property (nonatomic) int prevPage;
@property (nonatomic) int currPage;
@property (nonatomic) int totalPages;
@end

@implementation HONTabBannerView
@synthesize delegate = _delegate;

- (id)init {
	if ((self = [super initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - (kTabSize.height + 80.0), 320.0, 81.0)])) {
		[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabBannerBG"]]];
		
		
		_prevPage = 0;
		_currPage = 0;
		_totalPages = 0;
		
		_clubs = [[HONClubAssistant sharedInstance] suggestedClubs];
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 81.0)];
		_scrollView.backgroundColor = [[HONColorAuthority sharedInstance] honDebugDefaultColor];
		_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * ([_clubs count] + 1), _scrollView.frame.size.height);
//		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceHorizontal = YES;
		_scrollView.pagingEnabled = YES;
		_scrollView.delegate = self;
		[self addSubview:_scrollView];
	}
	
	return (self);
}


#pragma mark - Navigation


@end
