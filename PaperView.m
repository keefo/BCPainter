//
//  PaperView.m
//  BCPainter
//
//  Created by Yidi Hou on 13/01/11.
//  Copyright 2011 SFU. All rights reserved.
//

#import "PaperView.h"
#import "NSImage+LXExtension.h"

@implementation PaperView
@synthesize toolCursor;
@synthesize tool;
@synthesize tpc;
@synthesize modified;

- (void)awakeFromNib
{
	if(initPaper){
		return;
	}
	modified=NO;
	linePointArray=[[NSMutableArray alloc] init];

	colorSpaceRef = CGColorSpaceCreateDeviceRGB();	
	
	width=[self frame].size.width;
	height=[self frame].size.height;
	bitsPerComponent = 8;
	bitsPerPixel = 32;
	bytesPerRow = (width * bitsPerComponent * bitsPerComponent + 7)/8;
	buffer = (GLubyte *) malloc(bytesPerRow * height);	
	
	BOOL needTransparent=YES;
	if(needTransparent){
		bitmapInfo = kCGImageAlphaPremultipliedFirst; //建立XRGB 绘制真正的透明图像
	}else {
		bitmapInfo = kCGImageAlphaNoneSkipLast;  //该选项会导致alpha=0的部分render为黑色
		//如果是这种模式的图像我们的橡皮擦不能使用
		//CGContextSetBlendMode(context, kCGBlendModeClear);
		//方式，而要使用
		//CGContextSetBlendMode(context,  kCGBlendModeNormal);
		//然后用背景色填充
	}
	
	CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, buffer, bytesPerRow * height, NULL);
	image = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, dataProvider, NULL, false, kCGRenderingIntentDefault);
	//从buffer 建立CGImageRef用来绘制到View内
	
	context = CGBitmapContextCreate(buffer, width, height, bitsPerComponent, bytesPerRow, colorSpaceRef, bitmapInfo);
	//从buffer建立image的CGContextRef 用来绘制图像本身
	
	CGContextClearRect(context, CGRectMake(0, 0, width, height));

	[self reloadStokeWidth];
	
	[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:@"values.stokeWidth" options:NSKeyValueObservingOptionNew context:NULL];
	
	[self setTool:tool];
	initPaper=YES;
}

- (id)initWithFrame:(NSRect)frameRect
{
	if(self=[super initWithFrame:frameRect]){
		[self awakeFromNib];
	}
	return self;
}

- (void)dealloc
{
	CGImageRelease(image);
	[linePointArray release];
	[super dealloc];
}

-(BOOL)acceptsFirstResponder 
{
	//该函数保证paperview接收keyEvent
	return YES; 
}

- (void)reloadStokeWidth
{
	float newstokeWidth=[[NSUserDefaults standardUserDefaults] floatForKey:@"stokeWidth"];
	if(newstokeWidth<=0)newstokeWidth=1;
	if(newstokeWidth>=100)newstokeWidth=100;
	stokeWidth=newstokeWidth;
	CGContextSetLineWidth(context, stokeWidth);
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"values.stokeWidth"]){
		[self reloadStokeWidth];
	}
}

- (void)setImage:(NSImage*)img
{
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), [img CGImage]);
	[self display];
}

- (void)resetCursorRects
{
    [super resetCursorRects];
    [self addCursorRect:self.bounds cursor:toolCursor];
}

- (void)drawRect:(NSRect)rect 
{
	[[NSColor whiteColor] set];
	NSRectFill(rect); //白色底色
	
	CGContextRef c = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	CGContextDrawImage (c, NSRectToCGRect([self bounds]), image ); //绘制当前画布
	
	if(tool==0){
		if([linePointArray count]>0){
			
			CGContextSetLineCap(c, kCGLineCapRound);
			CGContextSetAlpha(c, CGColorGetAlpha((CGColorRef)[tpc color]));
			CGContextSetStrokeColorWithColor(c, (CGColorRef)[tpc color]);
			CGContextSetLineWidth(c, stokeWidth);
			NSString *ps=[linePointArray objectAtIndex:0];
			NSPoint p=NSPointFromString(ps);
			CGContextMoveToPoint(c, p.x, p.y);		
			for(ps in linePointArray){
				p=NSPointFromString(ps);
				CGContextAddLineToPoint(c, p.x, p.y);
			}
			CGContextStrokePath(c);
		}
	}else if(tool==1){
		if([linePointArray count]>0){
			
			CGContextSetLineCap(c, kCGLineCapRound);
			CGFloat components[]={ 1.0, 1.0, 1.0, 0.0 };
			CGContextSetStrokeColorWithColor(context,CGColorCreate(colorSpaceRef,components));
			CGContextSetLineWidth(c, stokeWidth);
			NSString *ps=[linePointArray objectAtIndex:0];
			NSPoint p=NSPointFromString(ps);
			CGContextMoveToPoint(c, p.x, p.y);		
			for(ps in linePointArray){
				p=NSPointFromString(ps);
				CGContextAddLineToPoint(c, p.x, p.y);
			}
			CGContextStrokePath(c);
		}
	}else if(tool==2){ //Marquee 工具绘制情况
		
		NSRect border=NSZeroRect;
		
		if(marqueeMove){ //如果是移动选择区域过程中
			border=marqueeMoveRect;
		}else if(mouseMovePoint.x!=mouseDownPoint.x || mouseMovePoint.y!=mouseDownPoint.y){
			//刚建立完选择区域时候，还为做选择区移动，未建立crop image
			border=marqueeRect;
		}
		
		if(tempImage){
			//如果建立了crop image 则绘制出来， tempImage 会在释放marquee工具后绘制到 画布（image） 中
			CGContextDrawImage (c, NSRectToCGRect(marqueeMoveRect), tempImage );
		}
		
		if(border.size.width>0 && border.size.height>0){  
			//如果border区域大于0，则需要绘制虚线选择区边框。
			//绘制虚线选择区域边框
			NSBezierPath *marquee=[NSBezierPath bezierPathWithRect:border];
			[marquee setLineJoinStyle:NSMiterLineJoinStyle];
			[marquee setLineCapStyle:NSButtLineCapStyle];
			float dashArray[2] = {5.0, 2.0};
			[marquee setLineDash:dashArray count:sizeof(dashArray) / sizeof(dashArray[0]) phase:0.0];
			[[NSColor blackColor] set];
			[marquee stroke];
		}

	}
}

- (void)putLineBack
{
	if([linePointArray count]>0){
		CGContextSetLineCap(context, kCGLineCapRound);
		if(tool==0){
			CGContextSetAlpha(context, CGColorGetAlpha((CGColorRef)[tpc color]));
			CGContextSetStrokeColorWithColor(context, (CGColorRef)[tpc color]);
		}else  if(tool==1){
			CGFloat components[]={ 1.0, 1.0, 1.0, 0.0 };
			CGContextSetStrokeColorWithColor(context,CGColorCreate(colorSpaceRef,components));
		}
		CGContextSetLineWidth(context, stokeWidth);
		NSString *ps=[linePointArray objectAtIndex:0];
		NSPoint p=NSPointFromString(ps);
		CGContextMoveToPoint(context, p.x, p.y);		
		for(ps in linePointArray){
			p=NSPointFromString(ps);
			CGContextAddLineToPoint(context, p.x, p.y);
		}
		CGContextStrokePath(context);
		[linePointArray removeAllObjects];
	}
}

- (void)putTempImageBack
{
	if(tempImage){
		marqueeRect=marqueeMoveRect;
		CGContextSaveGState(context); //save current context
		CGContextSetAlpha(context, 1.0); //set alpha to 1, cause alpha will effect on drawImage function
		CGContextDrawImage(context, NSRectToCGRect(marqueeRect), tempImage);
		CGContextRestoreGState(context);
	}
}

- (void)getTempImage
{
	if(tempImage==NULL){
		//crop出选择区域图像到tempImage内，并清空原图选中区域
		float tempwidth=marqueeRect.size.width;
		float tempheight=marqueeRect.size.height;
		float tempbitsPerComponent = 8;
		float tempbitsPerPixel = 32;
		float tempbytesPerRow = (tempwidth * tempbitsPerComponent * tempbitsPerComponent + 7)/8;
		GLubyte *tempbuffer = (GLubyte *) malloc(tempbytesPerRow * tempheight);	
		
		CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, tempbuffer, tempbytesPerRow * tempheight, NULL);
		tempImage = CGImageCreate(tempwidth, tempheight, tempbitsPerComponent, tempbitsPerPixel, tempbytesPerRow, colorSpaceRef, kCGImageAlphaPremultipliedFirst, dataProvider, NULL, false, kCGRenderingIntentDefault);
		CGContextRef tempcontext = CGBitmapContextCreate(tempbuffer, tempwidth, tempheight, tempbitsPerComponent, tempbytesPerRow, colorSpaceRef, kCGImageAlphaPremultipliedFirst);
		
		CGContextClearRect(tempcontext, CGRectMake(0, 0, tempwidth, tempheight));
		
		CGContextSaveGState(context);
		CGRect clippedRect = CGRectMake(0, 0, marqueeRect.size.width, marqueeRect.size.height);
		CGContextClipToRect( context, clippedRect);
		CGRect drawRect = CGRectMake(marqueeRect.origin.x * -1, marqueeRect.origin.y * -1, width, height);
		CGContextDrawImage(tempcontext, drawRect, image);
		CGContextRestoreGState(context);
		
		CGContextClearRect(context, NSRectToCGRect(marqueeRect));
		
		CGContextSetBlendMode(context,  kCGBlendModeClear);
		CGFloat components[]={ 1.0, 1.0, 1.0, 0.0 };
		CGContextSetFillColor(context, components);
		CGContextFillRect(context, NSRectToCGRect(marqueeRect));
		CGContextSetBlendMode(context,  kCGBlendModeNormal);
	}	
}



- (void)mouseDown:(NSEvent*)e
{
	
	if(tool==0){
		[linePointArray addObject:NSStringFromPoint([e locationInWindow])];
	}else if(tool==2){ //当前是Marquee工具
		if(addExtraCursor){ //已经添加勾选区域。处在Marquee移动状态
			if (NSPointInRect([e locationInWindow], marqueeRect)) {
				//点在勾选区域内，准备开始移动
				marqueeMove=YES;
				mouseDownPoint=[e locationInWindow];
				marqueeMoveRect=marqueeRect;
			}else {
				
				//首先回写上次的数据
				[self putTempImageBack];
				
				//点在勾选区域外，清除上次添加的勾选区域。准备开始新勾选
				[super resetCursorRects];
				[self removeCursorRect:marqueeRect cursor:[NSCursor openHandCursor]];
				addExtraCursor=NO;				
				mouseDownPoint=[e locationInWindow];
				mouseMovePoint=mouseDownPoint;
				if(tempImage){
					CGImageRelease(tempImage);
					tempImage = NULL;
				}
			}
		}else {//开始新恶Marquee
			mouseDownPoint=[e locationInWindow];
			mouseMovePoint=mouseDownPoint;
			if(tempImage){
				CGImageRelease(tempImage);
				tempImage = NULL;
			}
		}
	}
	mouseDown=YES;
}

- (void)mouseUp:(NSEvent*)e
{
	if(tool==0){
		[self putLineBack];
	}else if(tool==1){
		[self putLineBack];
	}else if(tool==2){ //marquee工具
		if(marqueeMove){ //移动选择区域结束
			marqueeRect=marqueeMoveRect;
			marqueeMove=NO;
		}else { //选好区域
			if(mouseMovePoint.x!=mouseDownPoint.x || mouseMovePoint.y!=mouseDownPoint.y){ //如果选择的是一个rect则建立，鼠标指针手势
				
				extraCursorRect=marqueeRect;
				[super resetCursorRects];
				[self addCursorRect:marqueeRect cursor:[NSCursor openHandCursor]];
				addExtraCursor=YES;
				
			}else { //选择的区域不是rect ，可能用户只点了一个点，或者选择了一条线 则不进入移动阶段
				addExtraCursor=NO;
			}
		}
	}else if(tool==0){
		//[linePointArray addObject:NSStringFromPoint([e locationInWindow])];
	}
	mouseDown=NO;
	[self display];
}

- (void)setTool:(int)a
{
	tool=a;

	if (context==NULL) {
		return;
	}
	
	[self putTempImageBack];
	[self putLineBack];
	
	if(tool==0){ //brush
		CGContextSetBlendMode(context,  kCGBlendModeNormal);
	}else if(tool==1){ //eraser
		CGContextSetBlendMode(context, kCGBlendModeClear);
	}else if(tool==2){ //marquee
		CGContextSetBlendMode(context,  kCGBlendModeNormal);
	}
	
	
	if(tool!=2){
			
		if(addExtraCursor){
			[super resetCursorRects];
			[self removeCursorRect:extraCursorRect cursor:[NSCursor openHandCursor]];
			addExtraCursor=NO;
		}
		mouseDownPoint=NSZeroPoint;
		mouseMovePoint=mouseDownPoint;	
		
		if(tempImage){
			CGImageRelease(tempImage);
			tempImage = NULL;
		}
	}
	[self display];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	//鼠标拖动时候根据选择的不同工具做动作
	
	NSPoint p=[theEvent locationInWindow];
	if(tool==2){ //marquee
		if(marqueeMove){ //移动选择区域过程中
		
			[self getTempImage];
		
			mouseMovePoint=p;
			marqueeMoveRect.origin.x=marqueeRect.origin.x+(mouseMovePoint.x-mouseDownPoint.x);
			marqueeMoveRect.origin.y=marqueeRect.origin.y+(mouseMovePoint.y-mouseDownPoint.y);
			
			if(addExtraCursor){
				[super resetCursorRects];
				[self removeCursorRect:extraCursorRect cursor:[NSCursor openHandCursor]];
				extraCursorRect=marqueeMoveRect;
				[self addCursorRect:extraCursorRect cursor:[NSCursor openHandCursor]];
			}
			
		}else { //选取过程中 等待选择矩形，第二个点
			mouseMovePoint=p;
			if(mouseMovePoint.x!=mouseDownPoint.x || mouseMovePoint.y!=mouseDownPoint.y){
				float ax=mouseDownPoint.x<mouseMovePoint.x?mouseDownPoint.x:mouseMovePoint.x;
				float ay=mouseDownPoint.y<mouseMovePoint.y?mouseDownPoint.y:mouseMovePoint.y;
				float aw=fabs(mouseDownPoint.x-mouseMovePoint.x);
				float ah=fabs(mouseDownPoint.y-mouseMovePoint.y);
				marqueeRect=NSMakeRect(ax, ay, aw, ah);
			}
		}		
		[self display];
		return;
	}
	
	if(tool==0){ //brush
		[linePointArray addObject:NSStringFromPoint(p)];
	}else if(tool==1) { //eraser
		[linePointArray addObject:NSStringFromPoint(p)];
	}
	
	if(modified==NO)
		modified=YES;
	[self display];
}

- (void)keyDown:(NSEvent *)theEvent
{
	int code=[theEvent keyCode];
	if(code==51){//如果选择区域存在并且按下delete键则情况选择区域。
		if(marqueeRect.size.width>0 && marqueeRect.size.height>0){
			[self getTempImage];
			if(tempImage){
				CGImageRelease(tempImage);
				tempImage=NULL;
				[self display];
			}
		}
	}
}

- (NSImage*) imageFromCGImageRef:(CGImageRef)aimage
{ 
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0); 
    CGContextRef imageContext = nil; 
    NSImage* newImage = nil; // Get the image dimensions. 
    imageRect.size.height = CGImageGetHeight(aimage); 
    imageRect.size.width = CGImageGetWidth(aimage); 
	
    // Create a new image to receive the Quartz image data. 
    newImage = [[NSImage alloc] initWithSize:imageRect.size]; 
    [newImage lockFocus]; 
	
    // Get the Quartz context and draw. 
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];    
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, aimage); [newImage unlockFocus]; 
    return newImage;
}

- (void)openSaveSheetClosed:(NSSavePanel *)panel returnCode:(NSInteger)code contextInfo:(id)contextInfo
{
	[NSApp stopModal];
	if (code == NSOKButton)
	{
		NSImage *img=[self imageFromCGImageRef:image];
		[img saveToPath:[panel filename]];
	}
}

- (void)save:(NSWindow*)win
{
	NSSavePanel *dlg = [NSSavePanel savePanel];
	[dlg setRequiredFileType:@"png"];
	[dlg beginSheetForDirectory:nil file:@"untilted.png" modalForWindow:win modalDelegate:self didEndSelector:@selector(openSaveSheetClosed:returnCode:contextInfo:) contextInfo:win];
	[NSApp runModalForWindow:win];
}

@end
