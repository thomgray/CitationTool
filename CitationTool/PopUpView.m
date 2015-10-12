//
//  PopUpView.m
//  CitationTool3
//
//  Created by Thomas Gray on 24/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "PopUpView.h"

@implementation PopUpView


//-(instancetype)initWithFrame:(NSRect)frameRect{
//    self = [super initWithFrame:frameRect];
//    if (self) {
//        textField = [[NSTextField alloc]initWithFrame:NSMakeRect(5, 5, frameRect.size.width-15, frameRect.size.height-10)];
//        [self addSubview:textField];
//    }
//    return self;
//}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSGraphicsContext * g = [NSGraphicsContext currentContext];
    
    [g saveGraphicsState];
    [g setShouldAntialias:TRUE];
    
    CGPoint o = NSMakePoint(dirtyRect.origin.x+1, dirtyRect.origin.y+1);
    CGSize s = NSMakeSize(dirtyRect.size.width, dirtyRect.size.height-2);
    
    float margin = 10;
    float pointWidth = 10;
    float corner = 20;
    
    NSPoint topLeft = NSMakePoint(o.x, o.y+s.height);
    NSPoint topRight = NSMakePoint(o.x+s.width-2, o.y+s.height);
    NSPoint bottomLeft = NSMakePoint(o.x, o.y);
    NSPoint bottomRight = NSMakePoint(o.x+s.width-margin, o.y);
    
    NSBezierPath * bez = [[NSBezierPath alloc]init];
    //[bez setLineWidth:1];
    
    
    [bez moveToPoint:NSMakePoint(o.x, o.y+corner)];
    [bez lineToPoint:NSMakePoint(o.x, o.y+s.height-corner)];
    [bez curveToPoint:NSMakePoint(o.x+corner, o.y+s.height) controlPoint1:topLeft controlPoint2:topLeft];
    [bez lineToPoint:topRight];
    [bez lineToPoint:NSMakePoint(o.x+s.width-margin, o.y+s.height-pointWidth)];
    [bez lineToPoint:NSMakePoint(o.x+s.width-margin, o.y+corner)];
    [bez curveToPoint:NSMakePoint(o.x+s.width-corner-margin, o.y)  controlPoint1:bottomRight controlPoint2:bottomRight];
    [bez lineToPoint:NSMakePoint(o.x+10, o.y)];
    [bez curveToPoint:NSMakePoint(o.x, o.y+corner) controlPoint1:bottomLeft controlPoint2:bottomLeft];
    [bez closePath];
    
    [[NSColor whiteColor] setFill];
    [[NSColor grayColor] setStroke];
    [bez fill];
    [bez stroke];
    
    [g restoreGraphicsState];
}

@end
