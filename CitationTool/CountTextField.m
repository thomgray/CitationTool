//
//  CountTextField.m
//  CitationTool
//
//  Created by Thomas Gray on 14/10/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import "CountTextField.h"

@implementation CountTextField

- (void)drawRect:(NSRect)dirtyRect {
    NSRect insetRect = NSInsetRect(dirtyRect, 1, 1);
    NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:insetRect xRadius:6 yRadius:6];
    [[NSColor colorWithCalibratedRed:0.4 green:.4 blue:.4 alpha:.9]setFill];
    [[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1]setStroke];
    [path fill];
    [path stroke];
    
    [super drawRect:dirtyRect];
}

@end
