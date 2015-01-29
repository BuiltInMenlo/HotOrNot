unsigned int outVal;
NSScanner* scanner = [NSScanner scannerWithString:messagePart];
[scanner scanHexInt:&outVal];


unsigned result = 0;
NSScanner *scanner = [NSScanner scannerWithString:@"#01FFFFAB"];

[scanner setScanLocation:1]; // bypass '#' character
[scanner scanHexInt:&result];