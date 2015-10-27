//
//  CiteListRow.m
//  CitationTool
//
//  Created by Thomas Gray on 17/10/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import "CiteListRow.h"

@implementation CiteListRow

@synthesize location;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
}

-(void)drawSelectionInRect:(NSRect)dirtyRect{
    if (!location){
        NSBezierPath* bpath = [NSBezierPath bezierPathWithRect:dirtyRect];
        [[NSColor colorWithCalibratedWhite:0.7 alpha:0.5]setFill];
        [bpath fill];
        return;
    }else{
        CGFloat f = dirtyRect.size.height/2.0;
        [[NSColor colorWithCalibratedRed:0.1 green:0.5 blue:1 alpha:1]setStroke];
        NSBezierPath* bpath = [NSBezierPath bezierPath];
        [bpath setLineWidth:2];

        [bpath moveToPoint:NSMakePoint(2, f)];
        [bpath lineToPoint:NSMakePoint(dirtyRect.size.width-2, f)];
        [bpath stroke];
    }
}

@end
