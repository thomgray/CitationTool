//
//  CutomRow.m
//  CitationTool3
//
//  Created by Thomas Gray on 11/10/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import "CustomRow.h"

@implementation CustomRow

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)drawSelectionInRect:(NSRect)dirtyRect{
    //[super drawSelectionInRect:dirtyRect];
    //NSRect selrect = NSInsetRect(dirtyRect, 5, 5);
    [[NSColor whiteColor]setFill];
    NSBezierPath* selection = [NSBezierPath bezierPathWithRect:dirtyRect];
    [selection fill];
}

@end
