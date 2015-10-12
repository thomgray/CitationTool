//
//  PreferencesController.h
//  CitationTool3
//
//  Created by Thomas Gray on 28/09/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSWindowController <NSTableViewDataSource>{
    
    __unsafe_unretained IBOutlet NSTableView *nonNamesList;
    
    
    NSMutableArray* nonNames;
    
}

- (IBAction)removeNonName:(id)sender;
- (IBAction)addNonName:(id)sender;

@end
