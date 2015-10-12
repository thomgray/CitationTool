//
//  BibListController.h
//  CitationTool3
//
//  Created by Thomas Gray on 22/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Bibliography.h"
#import "BibFormatSpecialist.h"

@interface BibListController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate>{
@private
    BibFormatSpecialist * formatter;
    
    __unsafe_unretained IBOutlet NSTableView* bibTable;
    
    __unsafe_unretained IBOutlet NSTableView* fieldTable;
    __unsafe_unretained IBOutlet NSTableView* typeView;
    
    __unsafe_unretained IBOutlet NSOutlineView *bibOutlines;
    
    __unsafe_unretained IBOutlet NSButton *addFieldButton;
    __unsafe_unretained IBOutlet NSButton *toggleViewFieldsButton;
    
    Bibliography* selectedBib;
    Reference* selectedReference;
    NSMutableArray* fieldData;
}

@property (nonatomic) NSMutableArray * bibliographies;

-(void)setBibliographies:(NSMutableArray *)bibliographies;

@end
