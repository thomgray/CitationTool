//
//  EditorController.h
//  CitationTool3
//
//  Created by Thomas Gray on 22/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Citation.h"
#import "Parser.h"
#import "CitationModel.h"
#import "Bibliography.h"

@class CitationModel;

@interface EditorController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, NSSplitViewDelegate>{
    
    __unsafe_unretained IBOutlet NSTextField *yearField;
    __unsafe_unretained IBOutlet NSTableView *authorsTable;
    __unsafe_unretained IBOutlet NSTableView *citeTable;
    __unsafe_unretained IBOutlet NSTextFieldCell *sampleView;
    __unsafe_unretained IBOutlet NSTextField *surroundField;
    __unsafe_unretained IBOutlet NSTableView *referenceList;
    __unsafe_unretained IBOutlet NSScrollView *citeScrollView;
    
    NSInteger index;
}

@property (nonatomic) Citation * citation;
@property (nonatomic) NSMutableArray* citeList;
@property (readonly) NSMutableArray* citeListCopy;
@property (unsafe_unretained) NSTextView* sourceView;
@property (unsafe_unretained) CitationModel* model;
@property NSMutableArray<Bibliography*>* bibliographies;
@property NSMutableArray<Reference*>* references;

//-(instancetype)initWithCitation:(Citation*)cit;
-(instancetype)initWithCitations:(NSMutableArray*)citations startingAt:(NSInteger)index;
-(void)setIndex:(NSInteger)i;
//-(void)windowDidResignKey:(NSNotification*)note;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)addAuthor:(id)sender;
- (IBAction)removeAuthor:(id)sender;
- (IBAction)forgetAuthor:(id)sender;
- (IBAction)nextRef:(id)sender;
- (IBAction)prevRef:(id)sender;
- (IBAction)nextCite:(id)sender;
- (IBAction)prevCite:(id)sender;

@end
