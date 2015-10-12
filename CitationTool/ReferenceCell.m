//
//  ReferenceCell.m
//  CitationTool3
//
//  Created by Thomas Gray on 24/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "ReferenceCell.h"

@implementation ReferenceCell

@synthesize state;

-(instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        NSTrackingArea* track = [[NSTrackingArea alloc]initWithRect:self.frame options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow owner:self userInfo:nil];
        [self addTrackingArea:track];
        //[self setBackgroundStyle:NSBackgroundStyleRaised];
    }
    return self;
}


-(BOOL)acceptsFirstResponder{
    return TRUE;
}


-(void)mouseUp:(NSEvent *)theEvent{
    NSLog(@"Mouse Up");
}





@end
