//
//  CitationModel.h
//  CitationTool3
//
//  Created by Thomas Gray on 21/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Citation.h"
#import "EditorController.h"
#import "LocationButton.h"
#import "PopUpView.h"
#import "Bibliography.h"
#import "SourceView.h"

@class EditorController;


@interface CitationModel : NSObject <NSTableViewDataSource, NSTableViewDelegate, NSTextViewDelegate>{
    IBOutlet NSTableView* citeTable;
    EditorController* editorController;
    NSMutableArray* citeCountListOns;
    
    __unsafe_unretained IBOutlet NSTextField* surroundField;
    IBOutlet PopUpView *popUpView;
    __unsafe_unretained IBOutlet SourceView *sourceView;
}

@property (nonatomic) NSMutableArray * citations;
@property NSMutableArray* tableData;
@property NSMutableArray<Reference*>* references;
@property NSMutableArray<Bibliography*>* bibliographies;

- (IBAction)listClick:(id)sender;
- (IBAction)advancedButtonClick:(id)sender;
-(IBAction)viewClick:(id)sender;

-(void)mouseEntered:(NSButton*)sender;
-(void)mouseExited:(NSButton*)sender;

-(void)updateCitations:(NSMutableArray*)cits;

@end
