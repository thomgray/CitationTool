//
//  LocationButton.m
//  CitationTool3
//
//  Created by Thomas Gray on 24/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "LocationButton.h"

@implementation LocationButton


-(instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        NSTrackingArea* track = [[NSTrackingArea alloc]initWithRect:self.frame options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways owner:self userInfo:nil];
        [self addTrackingArea:track];
    }
    return self;
}

-(void)setFrame:(NSRect)frame{
    //NSLog(@"button set frame");
    [super setFrame:frame];
    NSTrackingArea* track = [[NSTrackingArea alloc]initWithRect:frame options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways owner:self userInfo:nil];
    [self addTrackingArea:track];
}

-(void)mouseEntered:(NSEvent *)theEvent{
    [model mouseEntered:self];
}

-(void)mouseExited:(NSEvent *)theEvent{
    [model mouseExited:self];
}

@end
