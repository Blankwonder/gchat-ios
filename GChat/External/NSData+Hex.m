#import "NSData+Hex.h"

@implementation NSData (Hex)

- (NSString *)hexStringValue {
	NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:([self length] * 2)];
	const unsigned char *dataBuffer = [self bytes];
	for (int i = 0; i < [self length]; ++i) {
		[stringBuffer appendFormat:@"%02lX", (unsigned long)dataBuffer[i]];
	}
	
	return stringBuffer;	
}

@end