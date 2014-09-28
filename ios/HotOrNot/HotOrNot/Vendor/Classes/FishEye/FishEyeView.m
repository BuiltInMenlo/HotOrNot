//
//  FishEyeView.m
//  FishEyeDemo
//
//  Created by haiwei li on 11-11-22.
//  Copyright (c) 2011年 13awan. All rights reserved.
//

#import "FishEyeView.h"



@interface FishEyeView (hide)

- (void)resetPosition;

@end

@implementation FishEyeView (hide)

- (void)resetPosition{
    
    float viewH = m_Height * EYE_COUNT;
    m_StartY = (self.frame.size.height - viewH) / 2;
    
    [UIView beginAnimations: @"FishEyeAnimation" context: NULL];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration: 0.5];
    
    for (int i = 0; i < EYE_COUNT; ++i){

        alphabets[i].frame = CGRectMake(0, m_StartY + i * m_Height, m_Width, m_Height);
        
        alphabets2[i].frame = CGRectMake(0, m_StartY + i * m_Height, m_Width, m_Height);
    }
    
    [UIView commitAnimations];
    
}

@end


@implementation FishEyeView

@synthesize indexDelegate;

- (void)dealloc{
    
    
	
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
    }
    return self;
}

- (void) awakeFromNib
{

}

- (id) initializeWithImages:(NSMutableArray *)_imageArray
				  withMinSize:(CGSize)_minSize
				  withMaxRate:(float)_maxRate
			  withActionCount:(int)_actionCount {
	
	
	if ((self = [self initWithFrame:CGRectMake(0.0, 100.0, 250.0, 200.0)])) {
		
		
		//	self.backgroundColor = [UIColor clearColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		for (int i =0; i!= EYE_COUNT; ++i)
		{
			alphabets2[i] = [[UIImageView alloc] initWithFrame:CGRectZero];
			[self addSubview: alphabets2[i]];
			
			alphabets[i] = [[UIImageView alloc] initWithFrame:CGRectZero];
			alphabets[i].contentMode = UIViewContentModeScaleAspectFill;
			alphabets[i].image = ((UIImageView *)[((UIView *)[_imageArray objectAtIndex:i]).subviews lastObject]).image;
			[self addSubview: alphabets[i]];
		}
		
		m_Width = _minSize.width;
		m_Height = _minSize.height;
		
		m_MaxDisc = m_Width * 3.5;
		m_MinRate = 1.0f;
		m_MinDisc = m_Width / 2;
		m_MaxRate = _maxRate;
		
		m_A = (m_MinRate - m_MaxRate)/(m_MaxDisc - m_MinDisc);
		m_B = m_MinRate - m_A * m_MaxDisc;
		
		m_Offset = ((m_A * m_Width * 0.5 + m_B) + (m_A * 1.5 * m_Width + m_B)  + (m_A * 2.5 * m_Width + m_B) + (m_A * 3.5 * m_Width + m_B)  - 4.5)  * m_Width;
		
		[self resetPosition];
		

	}
	
	return (self);
	
}

- (void) initializeWithNames:(NSMutableArray *)_nameArray
                 withMinSize:(CGSize)_minSize
                 withMaxRate:(float)_maxRate
             withActionCount:(int)_actionCount;
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    for (int i =0; i!= EYE_COUNT; ++i)
    {
        alphabets2[i] = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview: alphabets2[i]];
        
        alphabets[i] = [[UIImageView alloc] initWithFrame:CGRectZero];
        alphabets[i].contentMode = UIViewContentModeScaleAspectFill;
        alphabets[i].image = [UIImage imageNamed:[NSString stringWithFormat:@"eye_item_%d.png", i]];
        [self addSubview: alphabets[i]];
    }
    
    m_Width = _minSize.width;
    m_Height = _minSize.height;
        
    m_MaxDisc = m_Width * 3.5;
    m_MinRate = 1.0f;
    m_MinDisc = m_Width / 2;
    m_MaxRate = _maxRate;
    
    m_A = (m_MinRate - m_MaxRate)/(m_MaxDisc - m_MinDisc);
    m_B = m_MinRate - m_A * m_MaxDisc;
    
    m_Offset = ((m_A * m_Width * 0.5 + m_B) + (m_A * 1.5 * m_Width + m_B)  + (m_A * 2.5 * m_Width + m_B) + (m_A * 3.5 * m_Width + m_B)  - 4.5)  * m_Width;
    
    [self resetPosition];
    
}

- (void)calFishEyeWithPosition:(CGPoint)position 
                  withAnimated:(BOOL)animated{
    
    float _disc;
    float _per;
    float _rate;
    
    NSUInteger indexTmp;
    
    for (int i = 0; i < EYE_COUNT; ++i){
        if (position.y > alphabets2[i].frame.origin.y && position.y <= alphabets2[i].frame.origin.y + m_Height ) {
            indexTmp = i;
            _per = (position.y - alphabets2[i].frame.origin.y) * m_MaxRate;
            break;
        }else if(i == 0){
            if(position.y < alphabets2[i].frame.origin.y){
                [self resetPosition];
                return;
            }
        }else if(i == EYE_COUNT - 1){
            if(position.y > alphabets2[i].frame.origin.y + alphabets2[i].frame.size.height){
                [self resetPosition];
                return;
            }
        }
    }
    
    if (animated) {
        [UIView beginAnimations: @"FishEyeAnimation" context: NULL];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration: 0.3];
    }
    
        
    alphabets[indexTmp].frame = CGRectMake(0, position.y - _per, m_Width * m_MaxRate, m_Height * m_MaxRate);
        
    for (int i = indexTmp - 1; i > -1; i--) {
        if (i < indexTmp - 3) {
            alphabets[i].frame = CGRectMake(0, alphabets2[indexTmp].center.y - m_Height * abs(i - indexTmp) - m_Offset - m_Height, m_Width, m_Height);
        }else{
            _disc = abs(alphabets2[i].center.y - position.y );
            
            _rate = m_A * _disc + m_B;
            alphabets[i].frame = CGRectMake(0, alphabets[i + 1].frame.origin.y - m_Height * _rate, m_Width * _rate, m_Height * _rate);
        }
        
    }
    for (int i = indexTmp + 1; i < EYE_COUNT; i++) {
        if (i > indexTmp + 3) {
            alphabets[i].frame = CGRectMake(0, alphabets2[indexTmp].center.y + m_Height * abs(i - indexTmp) + m_Offset, m_Width, m_Height);
        }else{
            _disc = abs(alphabets2[i].center.y - position.y );
                        
            _rate = m_A * _disc + m_B;  
            alphabets[i].frame = CGRectMake(0, alphabets[i - 1].frame.origin.y + alphabets[i - 1].frame.size.height, m_Width * _rate, m_Height * _rate);
        }        
    }
    if (animated) {
        [UIView commitAnimations];
    }
    
    if (index != indexTmp && indexDelegate && [indexDelegate respondsToSelector: @selector(fishEyeIndex:)])
    {
        index = indexTmp;
        [indexDelegate fishEyeIndex : index];
    }

}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    UITouch * _touch = [touches anyObject];
    
    CGPoint touchPoint = [_touch locationInView: self];
    
    [self calFishEyeWithPosition:touchPoint 
                    withAnimated:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resetPosition];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resetPosition];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * _touch = [touches anyObject];
    
    CGPoint touchPoint = [_touch locationInView: self];   
    
    [self calFishEyeWithPosition:touchPoint 
                    withAnimated:NO];
}


@end
