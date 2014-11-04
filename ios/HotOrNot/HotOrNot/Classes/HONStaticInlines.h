//
//  HONStaticInlines.h
//  HotOrNot
//
//  Created by BIM  on 11/4/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

//#ifndef HotOrNot_HONStaticInlines_h
//#define HotOrNot_HONStaticInlines_h
//#endif


CG_INLINE CGRect
CGRectMakeFromSize(CGSize size)
{
	CGRect rect;
	rect.origin.x = 0.0;
	rect.origin.y = 0.0;
	rect.size.width = size.width;
	rect.size.height = size.height;
	return rect;
}

CG_INLINE CGRect
CGRectTranslate(CGRect rect, CGPoint point)
{
	CGRect transRect;
	transRect.origin.x = point.x;
	transRect.origin.y = point.y;
	transRect.size.width = rect.size.width;
	transRect.size.height = rect.size.height;
	
	return (transRect);
}

CG_INLINE CGSize
CGSizeMult(CGSize size, CGFloat mult)
{
	CGSize multSize;
	multSize.width = size.width * mult;
	multSize.height = size.height * mult;
	return multSize;
}

CG_INLINE CGSize
CGSizeMakeSquare(CGFloat length)
{
	CGSize size;
	size.width = length;
	size.height = length;
	return size;
}

CG_INLINE CGAffineTransform
CGAffineTransformMakeScalePercent(CGRect frame, CGFloat percent)
{
	CGSize perSize = CGSizeMake(frame.size.width * percent, frame.size.height * percent);
	CGSize scaleSize = CGSizeMake(perSize.width / frame.size.width, perSize.width / frame.size.height);
	CGPoint offsetPt = CGPointMake(CGRectGetMidX(frame) - CGRectGetMidX(CGRectInset(frame, perSize.width, perSize.height)), CGRectGetMidY(frame) - CGRectGetMidY(CGRectInset(frame, perSize.width, perSize.height)));
	
	CGAffineTransform t;
	t.a = scaleSize.width; t.b = 0.0; t.c = 0.0; t.d = scaleSize.height; t.tx = offsetPt.x; t.ty = offsetPt.y;
	return (t);
}


CG_INLINE CGAffineTransform
CGAffineTransformMakeNormal()
{
	CGAffineTransform t;
	t.a = 1.0; t.b = 0.0; t.c = 0.0; t.d = 1.0; t.tx = 0.0; t.ty = 0.0;
	return t;
}

