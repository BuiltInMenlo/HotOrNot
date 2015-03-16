//
//  UIViewController+BuiltinMeno.m
//  HotOrNot
//
//  Created by BIM  on 3/15/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "UIViewController+BuiltinMeno.h"

@implementation UIViewController (BuiltinMeno)

+ (UIViewController *)findBestViewController:(UIViewController *)vc {
	if (vc.presentedViewController) {
		return ([UIViewController findBestViewController:vc.presentedViewController]);
		
	} else if ([vc isKindOfClass:[UISplitViewController class]]) {
		UISplitViewController* svc = (UISplitViewController*) vc;
		return ((svc.viewControllers.count > 0) ? [UIViewController findBestViewController:svc.viewControllers.lastObject] : vc);
		
	} else if ([vc isKindOfClass:[UINavigationController class]]) {
		
		UINavigationController* svc = (UINavigationController*) vc;
		return ((svc.viewControllers.count > 0) ? [UIViewController findBestViewController:svc.topViewController] : vc);
		
	} else if ([vc isKindOfClass:[UITabBarController class]]) {
		UITabBarController* svc = (UITabBarController*) vc;
		return ((svc.viewControllers.count > 0) ? [UIViewController findBestViewController:svc.selectedViewController] : vc);
		
	} else {
		return (vc);
	}
}

+ (UIViewController *)currentViewController {
	return ([UIViewController findBestViewController:[UIApplication sharedApplication].keyWindow.rootViewController]);
}

@end
