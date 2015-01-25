#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

#define BINARY_UNIT_SIZE 3
#define BASE64_UNIT_SIZE 4
#define xx 65

- (CGSize)textSizeWithFont:(UIFont *)font fieldSize:(CGSize)size;
{
    if (self == nil || [self trim].length == 0 || !font) {
        return CGSizeZero;
    }
    
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        CGSize boundingBox = [self boundingRectWithSize:size
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:font}
                                                context:nil].size;
        return CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    }
    else {
        #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        return [self sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
        #pragma GCC diagnostic warning "-Wdeprecated-declarations"
    }
}




#pragma mark - Crypto
- (NSString *)MD5
{
    // Create pointer to the string as UTF8
    const char *ptr = [self UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (unsigned int)strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    
    return output;
}

- (NSString *)SHA1
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

- (NSUInteger)indexOf:(NSString *)string
{
    NSRange range = [self rangeOfString:string];
    return range.location;
}




+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            [NSException raise:@"Invalid color value"
                        format: @"Color value %@ is invalid. It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB!", hexString];
            break;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length
{
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}


- (NSArray *)shuffledArray {
	return [self sortedArrayUsingComparator:^(id obj1, id obj2) {
		return (NSComparisonResult)(arc4random() % 3 - 1);    
	}];
}



UILabel / TextField
-(void) drawPlaceholderInRect:(CGRect)rect {

  NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
  style.alignment = self.textAlignment;

  [self.placeholder drawInRect:rect
                withAttributes:@{NSFontAttributeName: self.font,
                                 NSParagraphStyleAttributeName: style,
                                 NSForegroundColorAttributeName: self.placeholderTextColor}];

}






// TTTColorFormatter.m
// 
// Copyright (c) 2013 Mattt Thompson (http://mattt.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "TTTColorFormatter.h"

#import <tgmath.h>

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED

static void TTTGetRGBAComponentsFromColor(UIColor *color, CGFloat *red, CGFloat *green, CGFloat *blue, CGFloat *alpha) {
    [color getRed:red green:green blue:blue alpha:alpha];
}

static void TTTGetCMYKComponentsFromColor(UIColor *color, CGFloat *cyan, CGFloat *magenta, CGFloat *yellow, CGFloat *black) {
    CGFloat r = 0.0f, g = 0.0f, b = 0.0f;
    TTTGetRGBAComponentsFromColor(color, &r, &g, &b, NULL);

    CGFloat k = 1.0f - fmax(fmax(r, g), b);
    CGFloat dK = 1.0f - k;

    CGFloat c = (1.0f - (r + k)) / dK;
    CGFloat m = (1.0f - (g + k)) / dK;
    CGFloat y = (1.0f - (b + k)) / dK;

    if (cyan) *cyan = c;
    if (magenta) *magenta = m;
    if (yellow) *yellow = y;
    if (black) *black = k;
}

static void TTTGetHSLComponentsFromColor(UIColor *color, CGFloat *hue, CGFloat *saturation, CGFloat *lightness) {
    CGFloat r = 0.0f, g = 0.0f, b = 0.0f;
    TTTGetRGBAComponentsFromColor(color, &r, &g, &b, NULL);

    CGFloat h = 0.0f, s = 0.0f, l = 0.0f;

    CGFloat v = fmax(fmax(r, g), b);
    CGFloat m = fmin(fmin(r, g), b);
    l = (m + v) / 2.0f;

    CGFloat vm = v - m;

    if (l > 0.0f && vm > 0.0f) {
        s = vm / ((l <= 0.5f) ? (v + m) : (2.0f - v - m));

        CGFloat r2 = (v - r) / vm;
        CGFloat g2 = (v - g) / vm;
        CGFloat b2 = (v - b) / vm;

        if (r == v) {
            h = (g == m ? 5.0f + b2 : 1.0f - g2);
        } else if (g == v) {
            h = (b == m ? 1.0f + r2 : 3.0f - b2);
        } else {
            h = (r == m ? 3.0f + g2 : 5.0f - r2);
        }

        h /= 6.0f;
    }

    if (hue) *hue = h;
    if (saturation) *saturation = s;
    if (lightness) *lightness = l;
}

#pragma mark -

@implementation TTTColorFormatter

- (NSString *)hexadecimalStringFromColor:(UIColor *)color {
    CGFloat r = 0.0f, g = 0.0f, b = 0.0f;
    TTTGetRGBAComponentsFromColor(color, &r, &g, &b, NULL);

    return [NSString stringWithFormat:@"#%02lX%02lX%02lX", (unsigned long)round(r * 0xFF), (unsigned long)round(g * 0xFF), (unsigned long)round(b * 0xFF)];
}

- (UIColor *)colorFromHexadecimalString:(NSString *)string {
    NSScanner *scanner = [NSScanner scannerWithString:string];
    scanner.charactersToBeSkipped = [[NSCharacterSet alphanumericCharacterSet] invertedSet];

    unsigned value;
    [scanner scanHexInt:&value];

    CGFloat r = ((value & 0xFF0000) >> 16) / 255.0f;
    CGFloat g = ((value & 0xFF00) >> 8) / 255.0f;
    CGFloat b = ((value & 0xFF)) / 255.0f;

    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

#pragma mark -

- (NSString *)RGBStringFromColor:(UIColor *)color {
    CGFloat r = 0.0f, g = 0.0f, b = 0.0f;
    TTTGetRGBAComponentsFromColor(color, &r, &g, &b, NULL);

    return [NSString stringWithFormat:@"rgb(%lu, %lu, %lu)", (unsigned long)round(r * 0xFF), (unsigned long)round(g * 0xFF), (unsigned long)round(b * 0xFF)];
}

- (UIColor *)colorFromRGBString:(NSString *)string {
    return [self colorFromRGBAString:string];
}

#pragma mark -

- (NSString *)RGBAStringFromColor:(UIColor *)color {
    CGFloat r = 0.0f, g = 0.0f, b = 0.0f, a = 0.0f;
    TTTGetRGBAComponentsFromColor(color, &r, &g, &b, &a);

    return [NSString stringWithFormat:@"rgb(%lu, %lu, %lu, %g)", (unsigned long)round(r * 0xFF), (unsigned long)round(g * 0xFF), (unsigned long)round(b * 0xFF), a];

}

- (UIColor *)colorFromRGBAString:(NSString *)string {
    NSScanner *scanner = [NSScanner scannerWithString:string];
    scanner.charactersToBeSkipped = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];

    NSInteger r, g, b; float a;
    [scanner scanInteger:&r];
    [scanner scanInteger:&g];
    [scanner scanInteger:&b];

    if ([scanner scanFloat:&a]) {
        return [UIColor colorWithRed:(r / 255.0f) green:(g / 255.0f) blue:(b / 255.0f) alpha:a];
    } else {
        return [UIColor colorWithRed:(r / 255.0f) green:(g / 255.0f) blue:(b / 255.0f) alpha:1.0];
    }

}

#pragma mark -

- (NSString *)CMYKStringFromColor:(UIColor *)color {
    CGFloat c = 0.0f, m = 0.0f, y = 0.0f, k = 0.0f;
    TTTGetCMYKComponentsFromColor(color, &c, &m, &y, &k);

    return [NSString stringWithFormat:@"cmyk(%g%%, %g%%, %g%%, %g%%)", c * 100.0f, m * 100.0f, y * 100.0f, k * 100.0f];
}

- (UIColor *)colorFromCMYKString:(NSString *)string {
    NSScanner *scanner = [NSScanner scannerWithString:string];
    scanner.charactersToBeSkipped = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    float c, m, y, k;
    
    [scanner scanFloat:&c];
    [scanner scanFloat:&m];
    [scanner scanFloat:&y];
    [scanner scanFloat:&k];
    
    c *= 0.01f;
    m *= 0.01f;
    y *= 0.01f;
    k *= 0.01f;
    
    CGFloat dk = 1.0f - k;
    
    return [UIColor colorWithRed:(1.0f - c) * dk green:(1.0f - m) * dk blue:(1.0f - y) * dk alpha:1.0f];
}

#pragma mark -

- (NSString *)HSLStringFromColor:(UIColor *)color {
    CGFloat h = 0.0f, s = 0.0f, l = 0.0f;
    TTTGetHSLComponentsFromColor(color, &h, &s, &l);

    return [NSString stringWithFormat:@"hsl(%0.0lu, %g%%, %g%%)", (unsigned long)round(h * 0xFF), s * 100.0f, l * 100.0f];
}

- (UIColor *)colorFromHSLString:(NSString *)string {
    NSScanner *scanner = [NSScanner scannerWithString:string];
    scanner.charactersToBeSkipped = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];

    NSInteger h, s, l;
    [scanner scanInteger:&h];
    [scanner scanInteger:&s];
    [scanner scanInteger:&l];

    return [UIColor colorWithHue:(h / 359.0f) saturation:(s / 100.0f) brightness:(l / 100.0f) alpha:1.0f];
}

#pragma mark -

- (NSString *)UIColorDeclarationFromColor:(UIColor *)color {
    CGFloat r = 0.0f, g = 0.0f, b = 0.0f, a = 0.0f;
    [color getRed:&r green:&g blue:&b alpha:&a];

    return [NSString stringWithFormat:@"[UIColor colorWithRed:%g green:%g blue:%g alpha:%g]", r, g, b, a];
}

#pragma mark - NSFormatter

- (NSString *)stringForObjectValue:(id)anObject {
    if (![anObject isKindOfClass:[UIColor class]]) {
        return nil;
    }

    return [self hexadecimalStringFromColor:(UIColor *)anObject];
}

- (BOOL)getObjectValue:(out __autoreleasing id *)obj
             forString:(NSString *)string
      errorDescription:(out NSString *__autoreleasing *)error
{
    UIColor *color = nil;
    if ([string hasPrefix:@"#"]) {
        color = [self colorFromHexadecimalString:string];
    } else if ([string hasPrefix:@"rgb("]) {
        color = [self colorFromRGBString:string];
    } else if ([string hasPrefix:@"rgba("]) {
        color = [self colorFromRGBAString:string];
    } else if ([string hasPrefix:@"cmyk("]) {
        color = [self colorFromCMYKString:string];
    } else if ([string hasPrefix:@"hsl("]) {
        color = [self colorFromHSLString:string];
    }

    if (color) {
        *obj = color;

        return YES;
    }

    *error = NSLocalizedStringFromTable(@"Color format not recognized", @"FormatterKit", nil);

    return NO;
}

@end

#endif



// UIView
- (UIView *)findFirstResponder { 
	if(self.isFirstResponder) return self;
	
	for (UIView *subView in self.subviews) {
		UIView *firstResponder = [subView findFirstResponder];
		if (firstResponder != nil) 
			return firstResponder;
	}
	return nil;
}



// MAC Address

#import "MACAddress.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>


+ (NSString *)address
{
    static NSString *macAddress = nil;
    if (macAddress == nil)
    {
        //set up managment information base
        int mib[] =
        {
            CTL_NET,
            AF_ROUTE,
            0,
            AF_LINK,
            NET_RT_IFLIST,
            if_nametoindex("en0")
        };
        
        //get message size
        size_t length = 0;
        if (mib[5] == 0 || sysctl(mib, 6, NULL, &length, NULL, 0) < 0 || length == 0)
        {
            return nil;
        }
        
        //get message
        NSMutableData *data = [NSMutableData dataWithLength:length];
        if (sysctl(mib, 6, [data mutableBytes], &length, NULL, 0) < 0)
        {
            return nil;
        }
        
        //get socket address
        struct sockaddr_dl *socketAddress = ([data mutableBytes] + sizeof(struct if_msghdr));
        unsigned char *coreAddress = (unsigned char *)LLADDR(socketAddress);
        macAddress = [[NSString alloc] initWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                      coreAddress[0], coreAddress[1], coreAddress[2],
                      coreAddress[3], coreAddress[4], coreAddress[5]];
    }
    return macAddress;
}

+ (NSString *)addressWithDelimiter:(NSString *)delimiter
{
    return [[self address] stringByReplacingOccurrencesOfString:@":" withString:delimiter ?: @""];
}

