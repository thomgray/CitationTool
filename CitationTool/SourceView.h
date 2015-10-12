//
//  SourceView.h
//  CitationTool3
//
//  Created by Thomas Gray on 07/10/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AttributeStore : NSObject

@end

@interface SourceView : NSTextView{
    AttributeStore* highlightedAttributes;
}

-(void)highlightSelectionInRange:(NSRange)rng extendingSelection:(BOOL)extending;
-(void)clearHighlights;

@end
