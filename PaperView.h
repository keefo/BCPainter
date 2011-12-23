//
//  PaperView.h
//  BCPainter
//
//  Created by Yidi Hou on 13/01/11.
//  Copyright 2011 SFU. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ToolPanelController;

@interface PaperView : NSView {
	
	ToolPanelController *tpc;
	
	NSCursor *toolCursor;
	NSTrackingArea *trackingarea;
	
	CGImageRef image;
	GLubyte *buffer;
	CGContextRef context;
	CGColorSpaceRef colorSpaceRef;
	CGBitmapInfo bitmapInfo;
	float width,height;
	int bitsPerComponent;
	int bitsPerPixel;
	int bytesPerRow;
	
	int tool;
	float stokeWidth;
	
	BOOL marqueeMove;
	NSRect marqueeRect;
	NSRect marqueeMoveRect;
	
	BOOL addExtraCursor;
	NSRect extraCursorRect;
	CGImageRef tempImage;
	BOOL mouseDown;
	NSPoint mouseDownPoint;
	NSPoint mouseMovePoint;
	
	BOOL modified;
	
	BOOL initPaper;
	
	NSMutableArray *linePointArray;
	
}
@property(retain) NSCursor *toolCursor;
@property(assign) int tool;
@property(assign) ToolPanelController *tpc;
@property(assign) BOOL modified;

- (void)reloadStokeWidth;
- (void)save:(NSWindow*)win;
- (void)setImage:(NSImage*)img;


@end
