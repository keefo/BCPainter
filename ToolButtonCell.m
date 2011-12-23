//
//  ToolButtonCell.m
//  BCPainter
//
//  Created by Yidi Hou on 13/01/11.
//  Copyright 2011 SFU. All rights reserved.
//

#import "ToolButtonCell.h"


@implementation ToolButtonCell
@synthesize used;

- (void)setUsed:(BOOL)a
{
	used=a;
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
	if(used){
		NSBezierPath *p=[NSBezierPath bezierPathWithRoundedRect:frame xRadius:7 yRadius:7];
		[[NSColor grayColor] set];
		[p fill];
	}
}
- (void)drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView
{
	frame=NSInsetRect(frame, -2, -2);
	[super drawImage:image withFrame:frame inView:controlView];
}


@end
