//
//  SourceView.m
//  CitationTool3
//
//  Created by Thomas Gray on 07/10/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import "SourceView.h"

//-------------AttributeStore Private Interface
@interface AttributeStore()

@property NSMutableArray* indexes;
@property NSMutableArray* attributes;

-(void)addAttribute:(NSDictionary*)atts atIndex:(NSNumber*)indx;

@end

//-------------Attribute Store Implementation
@implementation AttributeStore
@synthesize indexes;
@synthesize attributes;

-(instancetype)init{
    self = [super init];
    if (self) {
        indexes = [[NSMutableArray alloc]init];
        attributes = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)addAttribute:(NSDictionary*)atts atIndex:(NSNumber*)indx{
    [indexes addObject:indx];
    [attributes addObject:atts];
}

@end

//--------Source Private Method Interface
@interface SourceView(Private)
@end

//--------Source Implementation
@implementation SourceView

-(void)awakeFromNib{
    highlightedAttributes = [[AttributeStore alloc]init];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)highlightSelectionInRange:(NSRange)rng extendingSelection:(BOOL)extending{
    if (!extending) {
        [self clearHighlights];
    }
    for (NSInteger i=rng.location; i<rng.location+rng.length; i++) {
        NSNumber* n = [[NSNumber alloc]initWithFloat:i];
        NSDictionary* att = [self.textStorage attributesAtIndex:i effectiveRange:nil];
        [highlightedAttributes addAttribute:att atIndex:n];
    }
    [self.textStorage setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor],
                                     NSForegroundColorAttributeName, [NSColor blueColor], NSBackgroundColorAttributeName, nil] range:rng];
}

-(void)clearHighlights{
    for (NSInteger i =0; i<highlightedAttributes.indexes.count; i++) {
        NSInteger n = [[highlightedAttributes.indexes objectAtIndex:i] longValue];
        NSDictionary* att = [highlightedAttributes.attributes objectAtIndex:i];
        [self.textStorage setAttributes:att range:NSMakeRange(n, 1)];
    }
    [highlightedAttributes.indexes removeAllObjects];
    [highlightedAttributes.attributes removeAllObjects];
}



@end













