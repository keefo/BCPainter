//
//  AppDelegate.m
//  BCPainter
//
//  Created by Yidi Hou on 13/01/11.
//  Copyright 2011 SFU. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate
@synthesize color;

-(void)awakeFromNib
{
	[colorWell setColor:[NSColor blackColor]];
	[ColorPanel setPickerMask:NSColorPanelAllModesMask];
	ColorPanel *colorPanel = (ColorPanel*)[ColorPanel sharedColorPanel];
	[colorPanel setShowsAlpha:YES];
	[colorPanel setTarget:self];
	[colorPanel setAction:@selector(colorPanelAction:)];
	[colorPanel setColor:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
	[NSApp orderFrontColorPanel:self];
	
	[firstPaperWindow setDelegate:self];
	[tpc setPaperwindow:firstPaperWindow];
	[tpc setColor:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
	papers=[[NSMutableArray alloc] init];
	[papers addObject:firstPaperWindow];
	
}

- (void)dealloc
{
	[papers release];
	[super dealloc];
}

- (IBAction)colorPanelAction:(id)sender
{
	self.color=[[NSColorPanel sharedColorPanel] color];
	[tpc setColor:color];
}

- (IBAction)openPaperAction:(id)sender
{
	NSOpenPanel *dlg = [NSOpenPanel openPanel];
	[dlg setAllowsMultipleSelection:NO];
	[dlg setAllowedFileTypes:[NSArray arrayWithObjects:@"png",@"jpg",@"tiff",nil]];
	[dlg setCanChooseDirectories:NO];
	if([dlg runModal]==NSFileHandlingPanelOKButton){
		NSString *filename=[dlg filename];
		NSImage *img=[[NSImage alloc] initWithContentsOfFile:filename];
		NSRect r=[[papers lastObject] frame];
		r.origin.x+=20;
		r.origin.y+=20;
		r.size=[img size];
		
		NSWindow *newpaper=[[NSWindow alloc] initWithContentRect:NSMakeRect(r.origin.x, r.origin.y, r.size.width, r.size.height) styleMask:NSClosableWindowMask | NSMiniaturizableWindowMask| NSTitledWindowMask backing:NSBackingStoreBuffered defer:YES];
		[newpaper setDelegate:self];
		[newpaper setTitle:[filename lastPathComponent]];
		PaperView *p=[[PaperView alloc] initWithFrame:[[newpaper contentView] bounds]];
		[p setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
		[p setImage:img];
		[[newpaper contentView] addSubview:p];
		[p setTool:0];
		[p release];
		[papers addObject:newpaper];
		[newpaper makeKeyAndOrderFront:self];
		[newpaper release];
	}
}

- (IBAction)newPaperAction:(id)sender
{
	NSRect r=[[papers lastObject] frame];
	r.origin.x+=20;
	r.origin.y+=20;
	
	NSWindow *newpaper=[[NSWindow alloc] initWithContentRect:NSMakeRect(r.origin.x, r.origin.y, r.size.width, r.size.height) styleMask:NSClosableWindowMask | NSMiniaturizableWindowMask| NSTitledWindowMask backing:NSBackingStoreBuffered defer:YES];
	[newpaper setDelegate:self];
	[newpaper setTitle:@"Untitled"];
	PaperView *p=[[PaperView alloc] initWithFrame:[[newpaper contentView] bounds]];
	[p setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
	[[newpaper contentView] addSubview:p];
	[p setTool:0];
	[p release];
	[papers addObject:newpaper];
	
	[newpaper makeKeyAndOrderFront:self];
	[newpaper release];
	
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(id)contextInfo;
{
	[NSApp stopModal];
	NSWindow *w=(NSWindow*)contextInfo;
	PaperView *p=[[[w contentView] subviews] objectAtIndex:0];
	if (returnCode == NSAlertFirstButtonReturn) {
		[p save:w];
	}else {
		[p setModified:NO];
		[w orderOut:self];
	}
}

- (void)askForSave:(NSTimer*)a
{
	id sender=[a userInfo];
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:NSLocalizedString(@"保存",@"保存")];
	[alert addButtonWithTitle:NSLocalizedString(@"取消",@"取消")];
	[alert setMessageText:NSLocalizedString(@"绘画已经修改",@"绘画已经修改")];
	[alert setInformativeText:NSLocalizedString(@"你是否要保持该涂鸦呢？", @"你是否要保持该涂鸦呢？")];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:sender modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:sender]; 
	[NSApp runModalForWindow:sender];
}

- (BOOL)windowShouldClose:(id)sender
{
	PaperView *p=[[[sender contentView] subviews] objectAtIndex:0];
	if([p modified]){
		[NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(askForSave:) userInfo:sender repeats:NO];
		return NO;
	}
	return YES;
}

- (void)windowDidBecomeKey:(NSNotification *)n
{
	[tpc setPaperwindow:[n object]];
}

#pragma mark -

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}

- (void)applicationWillTerminate:(NSNotification*)notification
{
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication 
					hasVisibleWindows:(BOOL)flag
{
	return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender
{
	return NO;
}

@end
