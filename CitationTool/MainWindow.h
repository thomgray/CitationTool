//
//  MainWindow.h
//  CitationTool3
//
//  Created by Thomas Gray on 19/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Parser.h"
#import "CitationModel.h"
#import "Bibliography.h"
#import "BibListController.h"


@interface MainWindow : NSWindow <NSSplitViewDelegate>{
        
    __unsafe_unretained IBOutlet NSTextView *sourceView;
    __unsafe_unretained IBOutlet NSTableView *citationListView;
    __unsafe_unretained IBOutlet NSTextView *bibliographyView;
    
    __weak IBOutlet NSButton *sourceAddButton;    
    __weak IBOutlet NSButton *citationsGetButton;
    __weak IBOutlet NSButton *exportBibButton;
    __weak IBOutlet NSButton *saveSourceButton;
    
    float sourceCiteMeetingRatio;
    float sourceCiteArseRatio;
    float border;
    float labelGap;
    NSMutableAttributedString* sourceString;
}

#pragma mark Related Fields

@property NSMutableArray<Citation*>* citations;

#pragma mark IB fields
@property IBOutlet CitationModel * citeModel;
@property BibListController* bibWindow;

- (IBAction)loadSourceFile:(id)sender;
//- (IBAction)viewMasterBib:(id)sender;
- (IBAction)getCitations:(id)sender;


@end
