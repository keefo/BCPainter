//
//  ToolButton.m
//  BCPainter
//
//  Created by Yidi Hou on 13/01/11.
//  Copyright 2011 SFU. All rights reserved.
//

#import "ToolButton.h"
#import "ToolButtonCell.h"

@implementation ToolButton

- (void)setUsed:(BOOL)b
{
	[[self cell] setUsed:b];
}

@end
