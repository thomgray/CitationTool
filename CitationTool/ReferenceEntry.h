//
//  ReferenceEntry.h
//  CitationTool3
//
//  Created by Thomas Gray on 10/10/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Bibliography.h"
#import "Reference.h"
#import "BibTexTextView.h"

@interface ReferenceEntry : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSTextDelegate, NSTextFieldDelegate, NSTabViewDelegate>{
    
    __unsafe_unretained IBOutlet NSButton* addToBibCheck;
    __unsafe_unretained IBOutlet NSPopUpButton* addToBibPopup;
    
    __unsafe_unretained IBOutlet NSPopUpButton* typePopUp;
    __unsafe_unretained IBOutlet NSButton* toggleViewAllFieldButton;
    __unsafe_unretained IBOutlet NSButton* addFieldButton;
    __unsafe_unretained IBOutlet NSTableView* fieldTable;
    
    __unsafe_unretained IBOutlet BibTexTextView* texView;
    
    __unsafe_unretained IBOutlet NSTextField* keyField;
    
    __unsafe_unretained IBOutlet NSTabView* tabView;
    
    NSInteger defaultSelectedBib;
    
}

@property (nonatomic) id parent;
@property NSArray<Bibliography*>* bibliographies;
@property NSMutableArray<Reference*>* references;
@property Reference* reference;

-(void)runModal;
-(IBAction)addField:(id)sender;
-(IBAction)removeField:(id)sender;

@end
