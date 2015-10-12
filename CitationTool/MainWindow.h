//
//  MainWindow.h
//  CitationTool3
//
//  Created by Thomas Gray on 19/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Parser.h"
#import "CitationList.h"
#import "CitationModel.h"
#import "Bibliography.h"
#import "BibListController.h"


@interface MainWindow : NSWindow{
        
    __unsafe_unretained IBOutlet NSTextView *sourceView;
    __unsafe_unretained IBOutlet NSTableView *citationListView;
    __unsafe_unretained IBOutlet NSTextView *bibliographyView;
    
    float sourceCiteMeetingRatio;
    float sourceCiteArseRatio;
    float border;
    float labelGap;
    NSMutableAttributedString* sourceString;
}

#pragma mark Related Fields

@property NSMutableArray<Bibliography*>* bibliographies;
@property NSMutableArray<Reference*>* references;
@property NSMutableArray<Citation*>* citations; ///just fold the citations together and forget citation list, it was only useful in the parsing methods

#pragma mark IB fields
@property IBOutlet CitationModel * citeModel;
@property BibListController* bibWindow;

- (IBAction)loadBibFile:(id)sender;
- (IBAction)loadSourceFile:(id)sender;
- (IBAction)viewMasterBib:(id)sender;

@end
