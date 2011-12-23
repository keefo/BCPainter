//
//  ToolPanelController.m
//  BCPainter
//
//  Created by Yidi Hou on 13/01/11.
//  Copyright 2011 SFU. All rights reserved.
//

#import "ToolPanelController.h"
#import "ToolButton.h"

@implementation ToolPanelController
@synthesize paperwindow;

- (void)awakeFromNib
{
	NSArray *buttons=[[toolbar contentView] subviews];
	[self setTool:[buttons objectAtIndex:0]];
	
}

- (void)setPaperwindow:(NSWindow *)a
{
	paperwindow=a;
	paper=[[[paperwindow contentView] subviews] objectAtIndex:0];
	[paper setTpc:self];
	NSArray *buttons=[[toolbar contentView] subviews];
	[self setTool:[buttons objectAtIndex:0]];
}

- (CGColorRef)color
{
	return color;
}

- (void)setColor:(NSColor*)c
{	
	if(color){
		CGColorRelease(color);
	}
	float components[4];
	[c getRed: &components[0] green: &components[1] blue:&components[2] alpha: &components[3]];
	color=CGColorCreate (CGColorSpaceCreateDeviceRGB(), components);
}

- (IBAction)setTool:(id)sender
{
	NSArray *buttons=[[toolbar contentView] subviews];
	ToolButton *b;
	for (b in buttons) {
		if([b isKindOfClass:[ToolButton class]]){
			[b setUsed:sender==b];
			[b display];
		}
	}
	
	if(cursor){
		[paper removeCursorRect:[paper bounds] cursor:cursor];
	}

	switch ([sender tag]) {
		case 0:
			cursor=[[NSCursor alloc] initWithImage:[NSImage imageNamed:@"Brush"] hotSpot:NSMakePoint(2, 31)];
			break;
		case 1:
			cursor=[[NSCursor alloc] initWithImage:[NSImage imageNamed:@"Eraser"] hotSpot:NSMakePoint(0, 18)];
			break;
		case 2:
			cursor=[[NSCursor alloc] initWithImage:[NSImage imageNamed:@"Marquee"] hotSpot:NSMakePoint(7, 5)];
			break;
		default:
			cursor=[NSCursor arrowCursor];
			break;
	}

	[paper setTool:[sender tag]];
	[paper setToolCursor:cursor];
	[paper resetCursorRects];
}

@end
