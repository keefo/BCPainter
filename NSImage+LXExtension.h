#import <Cocoa/Cocoa.h>


@interface NSImage (LXExtension)

//+ (NSImage *)imageForPath:(NSString*)path;
//+ (NSImage *)reflectedImage:(NSImage *)sourceImage amountReflected:(float)fraction;

- (NSImage *)resizeTo:(NSSize)newsize;
- (NSImage *)imageOfRect:(NSRect)rect;

- (void)saveToPath:(NSString*)p;
- (NSBitmapImageRep*)bitmapImageRep;
- (CGImageRef)CGImage;

@end
