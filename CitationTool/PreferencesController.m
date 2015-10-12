//
//  PreferencesController.m
//  CitationTool3
//
//  Created by Thomas Gray on 28/09/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import "PreferencesController.h"

@interface PreferencesController ()

@end

@implementation PreferencesController

- (void)windowDidLoad {
    [super windowDidLoad];
    NSString* path= [NSString stringWithFormat:@"%@/nonNames.txt", [[NSBundle mainBundle]resourcePath]];
    NSString* nonNamesString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray* nonNamesTempArray = [nonNamesString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    nonNames = [NSMutableArray arrayWithArray:nonNamesTempArray];
    [nonNames removeObject:@""];
    
    
    [nonNamesList reloadData];
}

- (IBAction)removeNonName:(id)sender {
}

- (IBAction)addNonName:(id)sender {
}


#pragma mark Table View Delegate Methods:

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return nonNames.count;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return [nonNames objectAtIndex:row];
}



@end
