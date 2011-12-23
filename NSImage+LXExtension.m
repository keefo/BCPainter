//
//  NSImage+BHReflectedImage.m
//  Flected
//
//  Created by Jeff Ganyard on 11/1/06.
/*
	Copyright (c) 2006 Bithaus.

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

	Sending an email to ganyard (at) bithaus.com informing where the code is being used would be appreciated.
*/

#import "NSImage+LXExtension.h"

@implementation NSImage (LXExtension)

/*
+ (NSImage *)imageForPath:(NSString*)value
{
	if (!value)
        return nil;
    
    NSString * path = [value stringByExpandingTildeInPath];
    NSImage * icon;
    //show a folder icon if the folder doesn't exist
    if (![[NSFileManager defaultManager] fileExistsAtPath: path] && [[path pathExtension] isEqualToString: @""])
        icon = [[NSWorkspace sharedWorkspace] iconForFileType: NSFileTypeForHFSTypeCode('fldr')];
    else
        icon = [[NSWorkspace sharedWorkspace] iconForFile: [value stringByExpandingTildeInPath]];
    
    [icon setSize: NSMakeSize(16.0, 16.0)];
    
    return icon;
}

+ (NSImage *)reflectedImage:(NSImage *)sourceImage amountReflected:(float)fraction
{
	NSImage *reflection = [[NSImage alloc] initWithSize:[sourceImage size]];
	[reflection setFlipped:YES];

	[reflection lockFocus];
	NSGradient *fade = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.5] endingColor:[NSColor clearColor]];
	[fade drawInRect:NSMakeRect(0, 0, [sourceImage size].width, [sourceImage size].height*fraction) angle:90.0];	
	
	//LXGradient *fade = [LXGradient gradientWithBeginningColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.5] endingColor:[NSColor clearColor]];
	//[fade fillRect:NSMakeRect(0, 0, [sourceImage size].width, [sourceImage size].height*fraction) angle:90.0];	
	[sourceImage drawAtPoint:NSMakePoint(0,0) fromRect:NSZeroRect operation:NSCompositeSourceIn fraction:1.0];
	[reflection unlockFocus];

	return [reflection autorelease];
}
*/

- (NSImage *)resizeTo:(NSSize)newsize
{
	NSImage *resizedImage = [[NSImage alloc] initWithSize:newsize];
	NSSize originalSize = [self size];
	[resizedImage lockFocus];
	[self drawInRect: NSMakeRect(0, 0, newsize.width, newsize.height) fromRect: NSMakeRect(0, 0, originalSize.width, originalSize.height) operation: NSCompositeSourceOver fraction: 1.0];
	[resizedImage unlockFocus];
	self=resizedImage;
	return self;
}

- (NSImage *)imageOfRect:(NSRect)rect
{
	NSImage *newimage=[[NSImage alloc] initWithSize:rect.size];
	[newimage lockFocus];
	[self drawInRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
	[newimage unlockFocus];
	return [newimage autorelease];
}

- (NSBitmapImageRep*)bitmapImageRep
{
	NSArray *list=[self representations];
	NSImageRep	*currentRepresentation	= nil;
	NSBitmapImageRep *bm = nil;
	for(currentRepresentation in list){
		if([currentRepresentation isKindOfClass:[NSBitmapImageRep class]]) {
			bm = (NSBitmapImageRep *)currentRepresentation;
			return bm;
			break;
		}
	}
	NSData *data=[self TIFFRepresentation];
	if(data==nil)return nil;
	bm = [[NSBitmapImageRep alloc] initWithData:data];
	[self addRepresentation:bm];
	return bm;
}

- (void)saveToPath:(NSString*)p
{
	NSBitmapImageRep *bm = [self bitmapImageRep];
	NSData *data = [bm representationUsingType:NSPNGFileType properties: nil];
	[data writeToFile:p atomically: NO];
}


- (CGImageRef)CGImage
{
	NSBitmapImageRep *bm = [self bitmapImageRep];
	if(bm){
		return [bm CGImage];	
	}
	return nil;
}

@end
