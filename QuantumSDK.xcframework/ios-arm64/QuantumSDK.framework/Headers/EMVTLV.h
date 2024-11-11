#import <Foundation/Foundation.h>

@interface EMVTLV : NSObject

@property (assign) int tag;
@property (copy) NSData *data;
@property (readonly) const uint8_t *bytes;
@property (readonly) NSData *encodedData;
@property (readonly) BOOL constructed;

- (NSString *)toHexStringValue;
- (NSString *)toStringValue;
- (int)toIntValue;

+ (NSArray *)decodeTagList:(NSData *)data;
+ (NSData *)encodeTagList:(NSArray *)data;
+ (uint)tagFromHexString:(NSString *)string;
+ (EMVTLV *)tlvWithString:(NSString *)data tag:(uint)tag;
+ (EMVTLV *)tlvWithHexString:(NSString *)data tag:(uint)tag;
+ (EMVTLV *)tlvWithData:(NSData *)data tag:(uint)tag;
+ (EMVTLV *)tlvWithInt:(UInt64)data nBytes:(int)nBytes tag:(uint)tag;
+ (EMVTLV *)tlvWithBCD:(UInt64)data nBytes:(int)nBytes tag:(uint)tag;
+ (EMVTLV *)findLastTag:(int)tag tags:(NSArray *)tags;
+ (NSArray *)findTag:(int)tag tags:(NSArray *)tags;
+ (NSArray *)decodeTags:(NSData *)data;
+ (NSData *)encodeTags:(NSArray *)tags;
+ (int)findLastIndex:(int)byte inData:(NSData *)data;

@end
