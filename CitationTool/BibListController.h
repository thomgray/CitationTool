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
#import "BibTexTextView.h"

@interface BibListController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate, NSPathControlDelegate, NSSplitViewDelegate, NSTextViewDelegate, NSTextFieldDelegate, NSTextDelegate, NSTabViewDelegate>{
    
@private
    BibFormatSpecialist * formatter;
    
    __unsafe_unretained IBOutlet NSTableView* bibTable;
    __unsafe_unretained IBOutlet NSPathControl* pathControl;
    
    __unsafe_unretained IBOutlet NSTableView* fieldTable;
    __unsafe_unretained IBOutlet BibTexTextView* texView;
    
    __unsafe_unretained IBOutlet NSOutlineView *bibOutlines;
    
    __unsafe_unretained IBOutlet NSButton *addFieldButton;
    __unsafe_unretained IBOutlet NSButton *toggleViewFieldsButton;
    __unsafe_unretained IBOutlet NSButton* addReferenceButton;
    __unsafe_unretained IBOutlet NSButton* loadBibButton;
    
    __unsafe_unretained IBOutlet NSPopUpButton* typePopUp;
    __unsafe_unretained IBOutlet NSTextField* keyField;
    
    Bibliography* selectedBib;
    Reference* selectedReference;
    NSMutableArray* fieldData;
}

@property (nonatomic) NSMutableArray<Bibliography*>* bibliographies;
@property NSMutableArray<Reference*>* references;

-(void)setBibliographies:(NSMutableArray<Bibliography*>*)bibliographies;
-(void)initialLoad;

-(void)refreshFields;
-(void)refreshBibTable;

@end
