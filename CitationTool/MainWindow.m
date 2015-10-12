//
//  MainWindow.m
//  CitationTool3
//
//  Created by Thomas Gray on 19/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "MainWindow.h"

@interface MainWindow()

-(void) privateLoadSource:(NSURL*)url;
-(void) searchForBibs;

@end

@implementation MainWindow

@synthesize citeModel;
@synthesize bibWindow;
@synthesize citations;
@synthesize bibliographies;
@synthesize references;

- (instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)awakeFromNib{
    [self searchForBibs];
//    NSString *bibpath = @"/Users/thomdikdave/Desktop/untitled.bib";
//    bibliographies = [[NSMutableArray alloc]initWithCapacity:1];
//    [bibliographies addObject:[[Bibliography alloc]initWithFile:bibpath]];
    NSString* path = @"/Users/thomdikdave/Desktop/chapter5.txt";
    sourceView.string = [NSString stringWithContentsOfFile:path
                                             encoding:NSUTF8StringEncoding error:nil];
    [self getCitations:nil];

}

-(void)searchForBibs{
    if (!bibliographies) bibliographies = [[NSMutableArray alloc]init];
    NSFileManager* filemanager = [NSFileManager defaultManager];
    NSURL* home = [[NSURL alloc]initFileURLWithPath:NSHomeDirectory()];
    NSDirectoryEnumerator* enumerator = [filemanager enumeratorAtURL:home includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^BOOL(NSURL * _Nonnull url, NSError * _Nonnull error) {
        if (error){
            NSLog(@"Error enumerating: %@ %@", url, error);
            return NO;
        }else return YES;
    }];

    NSMutableArray* bibPaths = [[NSMutableArray alloc]init];
    for (NSURL* file in enumerator){
        NSString* name;
        [file getResourceValue:&name forKey:NSURLNameKey error:nil];
        
        if ([name hasSuffix:@"bib"]){
            [bibPaths addObject:[file path]];
        }
    }
    for (NSString* path in bibPaths){
        [bibliographies addObject:[[Bibliography alloc]initWithFile:path]];
    }
    references = [Bibliography allReferences:bibliographies];
}



- (IBAction)getCitations:(id)sender {
    sourceString = [[NSMutableAttributedString alloc]initWithString:sourceView.string];
    if (sourceString.length==0) return;
    
    Parser* parser = [[Parser alloc]init];
    [parser setSourceString:[sourceString string]];
    CitationList * cites = [parser getCitations];
    citations = [[NSMutableArray alloc]initWithArray:cites.possibleCitations];
    [citations addObjectsFromArray:cites.citations];

    if (references.count>0) {
        for (Citation* cit in citations){
            [cit findPossibleReferences:references];
        }
    }

    [citeModel setCitations:citations];
    [citeModel setReferences:references];
    [citeModel setBibliographies:bibliographies];
    [citationListView reloadData];
}





- (IBAction)loadBibFile:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setCanChooseDirectories:NO];
    
    NSInteger i = [openDlg runModal];
    if (i==NSOKButton) {
        NSURL *file = [openDlg URL];
        if (!bibliographies) bibliographies  = [[NSMutableArray alloc]initWithCapacity:1];
        [bibliographies addObject:[[Bibliography alloc]initWithFile:file.path]];
        //// Scan to check references for citations
    }
}

- (IBAction)loadSourceFile:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setCanChooseDirectories:NO];
    
    NSInteger i =[openDlg runModal];

    if (i==NSOKButton) {
        NSURL *file = [openDlg URL];
        [self privateLoadSource:file];
    }
}

-(void)privateLoadSource:(NSURL *)url{
    NSString* str = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    sourceString = [[NSMutableAttributedString alloc]initWithString:str];
    if (sourceString) sourceView.string  = sourceString.string;
    [self getCitations:nil];
}

-(IBAction)viewMasterBib:(id)sender{
    bibWindow = [[BibListController alloc]initWithWindowNibName:@"BibListController"];
    [bibWindow setBibliographies:bibliographies];
    [bibWindow showWindow:self];
}

#pragma mark Layout Bollocks


@end
