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
#import "PopUpView.h"
#import "Bibliography.h"
#import "SourceView.h"

@class EditorController;


@interface CitationModel : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSTextViewDelegate>{
    IBOutlet NSTableView* citeTable;
    EditorController* editorController;
    NSMutableArray* citeCountListOns;
    __unsafe_unretained IBOutlet SourceView *sourceView;
    __unsafe_unretained IBOutlet NSTextView *bibliographyView;
}

@property (nonatomic) NSMutableArray * citations;
@property NSMutableArray* tableData;
@property NSMutableArray<Reference*>* references;
@property NSMutableArray<Bibliography*>* bibliographies;
@property NSInteger defaultBibIndex;

- (IBAction)listClick:(id)sender;
- (IBAction)advancedButtonClick:(id)sender;

-(NSString*)getCitedReferences;

-(void)refreshBibliography;
-(void)refreshReferences;

-(void)updateCitations:(NSMutableArray*)cits;
-(void)updateSource:(NSAttributedString*)str;

-(void)saveProgressAtPath:(NSString*)path;
-(void)openSavedProject:(NSString*)path;

@end
