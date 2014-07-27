//
//  HONWebViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.26.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONViewController.h"

@interface HONWebViewController : HONViewController <UIWebViewDelegate>
- (id)initWithURL:(NSString *)url title:(NSString *)title;

@property (nonatomic, strong) NSString *headerTitle;
@property (nonatomic, strong) NSString *url;
@end
