//
//  AppDelegate.h
//  BCPainter
//
//  Created by Yidi Hou on 13/01/11.
//  Copyright 2011 SFU. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ToolPanelController.h"
#import "ColorPanel.h"

@interface AppDelegate : NSObject {
	NSColor *color;
	IBOutlet ToolPanelController *tpc;
	IBOutlet NSColorWell *colorWell;
	
	IBOutlet NSWindow *firstPaperWindow;
	NSMutableArray *papers;
}
@property(retain) NSColor *color;

- (IBAction)colorPanelAction:(id)sender;
- (IBAction)newPaperAction:(id)sender;
- (IBAction)openPaperAction:(id)sender;

@end
