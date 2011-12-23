//
//  ToolPanelController.h
//  BCPainter
//
//  Created by Yidi Hou on 13/01/11.
//  Copyright 2011 SFU. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PaperView.h"
#import "ToolPanel.h"

@interface ToolPanelController : NSObject {
	IBOutlet ToolPanel *toolbar;
	
	NSWindow *paperwindow;
	PaperView *paper;
	NSCursor *cursor;
	CGColorRef color;
	
}
@property(assign) NSWindow *paperwindow;

- (void)setTool:(id)sender;
- (void)setColor:(NSColor*)c;

- (CGColorRef)color;

@end
