//
//  CitationsHorizontalList.h
//  CitationTool
//
//  Created by Thomas Gray on 13/10/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CitationHorizontalListCell.h"

@protocol CitationHorizontalListDelegate;

@interface CitationsHorizontalList : NSControl <NSTextViewDelegate, NSUserInterfaceValidations>{
    NSMutableArray<NSTextField*>* cells;
    id<CitationHorizontalListDelegate> delegate;
}



@end


@protocol CitationHorizontalListDelegate

-(NSArray*)valuesForCitationList:(CitationsHorizontalList*)list;

@end