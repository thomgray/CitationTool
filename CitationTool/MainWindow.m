//
//  MainWindow.m
//  CitationTool3
//
//  Created by Thomas Gray on 19/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "MainWindow.h"
#import "AppDelegate.h"

@interface MainWindow()

-(void) privateLoadSource:(NSURL*)url;
-(void) sortCustomImages;

@end

@implementation MainWindow

@synthesize citeModel;
@synthesize bibWindow;
@synthesize citations;

- (instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)awakeFromNib{
//    [self searchForBibs];
    [self sortCustomImages];
    
//    NSString *bibpath = @"/Users/thomdikdave/Desktop/untitled.bib";
//    bibliographies = [[NSMutableArray alloc]initWithCapacity:1];
//    [bibliographies addObject:[[Bibliography alloc]initWithFile:bibpath]];
//    NSString* path = @"/Users/thomdikdave/Desktop/chapter5.txt";
//    sourceView.string = [NSString stringWithContentsOfFile:path
//                                             encoding:NSUTF8StringEncoding error:nil];
    //[self getCitations:nil];

}

#pragma mark Actions


- (IBAction)getCitations:(id)sender {
    sourceString = [[NSMutableAttributedString alloc]initWithString:sourceView.string];
    if (sourceString.length==0) return;
    
    Parser* parser = [[Parser alloc]init];
    [parser setSourceString:[sourceString string]];
    citations = [parser getCitations];

    if (citeModel.references.count>0) {
        for (NSInteger i=0; i<citations.count; i++){
            Citation* cit = [citations objectAtIndex:i];
            [cit findPossibleReferences:citeModel.references];
        }
    }

    [citeModel setCitations:citations];
    [citeModel setBibliographies:citeModel.bibliographies];
    [citationListView reloadData];
    [citeModel refreshBibliography];
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

-(IBAction)saveSourceFile:(id)sender{
    NSSavePanel* saver = [NSSavePanel savePanel];
    [saver setNameFieldLabel:@"File:"];
    NSArray* titles = [sourceView.string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSString* title;
    for (NSInteger i=0; i<titles.count; i++) {
        NSString* str = [titles objectAtIndex:i];
        NSString* thisstr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (thisstr.length>0) {
            title = thisstr;
            break;
        }
    }
    if (!title) title = @"untitled";
    else if (title.length>100){
        NSInteger i = 100;
        for (; i>0; i--) {
            if ([[NSCharacterSet whitespaceCharacterSet]characterIsMember:[title characterAtIndex:i]]) {
                title = [title substringToIndex:i];
                title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                break;
            }else if (i==0){
                title = @"untitled";
            }
        }
    }
    [saver setNameFieldStringValue:[NSString stringWithFormat:@"%@.txt", title]];
    [saver setIsMiniaturized:NO];
    [saver setAllowedFileTypes:@[@"txt"]];
    [saver beginWithCompletionHandler:^(NSInteger result) {
        if (result==NSFileHandlingPanelOKButton) {
            NSURL* url = [saver URL];
            NSString* path = [url path];
            if (![[path pathExtension] isEqualToString:@"txt"]) {
                path = [path stringByDeletingPathExtension];
                path = [path stringByAppendingString:@".txt"];
            }
            [sourceView.string writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }];
}

-(void)privateLoadSource:(NSURL *)url{
    NSString* str = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    sourceString = [[NSMutableAttributedString alloc]initWithString:str];
    if (sourceString) sourceView.string  = sourceString.string;
    [self getCitations:nil];
}

//-(IBAction)viewMasterBib:(id)sender{
//    bibWindow = [[BibListController alloc]initWithWindowNibName:@"BibListController"];
//    [bibWindow setBibliographies:bibliographies];
//    [bibWindow setReferences:references];
//    [bibWindow showWindow:self];
//}

-(IBAction)exportBib:(id)sender{
    NSSavePanel* saver = [NSSavePanel savePanel];
    [saver setNameFieldLabel:@"Bibliography:"];
    [saver setIsMiniaturized:NO];
    [saver setNameFieldStringValue:@"bibliography.bib"];
    [saver beginWithCompletionHandler:^(NSInteger result) {
        if (result==NSFileHandlingPanelOKButton) {
            NSURL* url = [saver URL];
            NSString* path = [url path];
            if (![[path pathExtension] isEqualToString:@"bib"]) {
                path =[path stringByDeletingPathExtension];
                path = [path stringByAppendingString:@".bib"];
            }
            NSString* bibToExport = [citeModel getCitedReferences];
            [bibToExport writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }];
}



#pragma mark Layout Bollocks

-(void)sortCustomImages{
    NSImage* addDown = [AppDelegate getImageNamed:@"addIconDown_19"];
    NSImage* addUp = [AppDelegate getImageNamed:@"addIconUp_19"];
    
    [sourceAddButton setImage:addUp];
    [sourceAddButton setAlternateImage:addDown];
    
    NSImage* getUp = [AppDelegate getImageNamed:@"searchIconUp_19"];
    NSImage* getDown = [AppDelegate getImageNamed:@"searchIconDown_19"];
    [citationsGetButton setImage:getUp];
    [citationsGetButton setAlternateImage:getDown];
    
    NSImage* exportUp = [AppDelegate getImageNamed:@"exportIconUp_19"];
    NSImage* exportDown = [AppDelegate getImageNamed:@"exportIconDown_19"];
    [exportBibButton setImage:exportUp];
    [exportBibButton setAlternateImage:exportDown];
    
    [saveSourceButton setImage:[AppDelegate getImageNamed:@"saveIconUp_19"]];
    [saveSourceButton setAlternateImage:[AppDelegate getImageNamed:@"saveIconDown_19"]];
}

#pragma mark Split View Delegate Methods

-(BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview{
    if ([splitView isVertical]) {
        if (subview == [splitView.subviews firstObject]) {
            return YES;
        }
    }else{
        if (subview==[splitView.subviews lastObject]) {
            return YES;
        }
    }
    return FALSE;
}

-(CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex{
    if ([splitView isVertical]) {
        CGFloat width = splitView.frame.size.width;
        return width-250.0f;
    }else{
        CGFloat height = splitView.frame.size.height;
         return height-150.0f;
    }
}

-(CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex{
    if ([splitView isVertical]) {
        return 250.0f;
    }else{
        return 300.0f;
    }
}

@end











