//
//  ReferenceRow.m
//  CitationTool3
//
//  Created by Thomas Gray on 07/10/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import "ReferenceRow.h"

@implementation ReferenceRow

@synthesize state;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if (state==1){
        NSRect selectionRect = NSInsetRect(self.bounds, 2.5, 2.5);
        [[NSColor colorWithCalibratedRed:.01 green:.5 blue:1 alpha:1] setStroke];
        [[NSColor colorWithCalibratedWhite:1 alpha:1]setFill];
        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:6 yRadius:6];
        selectionPath.lineWidth = 2;
        [selectionPath stroke];
        [selectionPath fill];
    }
}

-(void)drawSelectionInRect:(NSRect)dirtyRect{
//    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {
//        NSRect selectionRect = NSInsetRect(self.bounds, 2.5, 2.5);
//        [[NSColor colorWithCalibratedWhite:.65 alpha:1.0] setStroke];
//        [[NSColor colorWithCalibratedWhite:.82 alpha:1.0] setFill];
//        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:6 yRadius:6];
//        [selectionPath fill];
//        [selectionPath stroke];
//    }
}


@end
