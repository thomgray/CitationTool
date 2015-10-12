//
//  CountCellView.m
//  CitationTool3
//
//  Created by Thomas Gray on 22/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "CountCellView.h"

@implementation CountCellView

@synthesize button;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)setButtonToggleStatus:(BOOL)status{
    [button setState:status];
}


@end
