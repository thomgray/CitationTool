//
//  BibListWindow.h
//  CitationTool
//
//  Created by Thomas Gray on 25/10/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BibListWindow : NSWindow{
    __unsafe_unretained IBOutlet NSButton* addReferenceButton;
    __unsafe_unretained IBOutlet NSButton* addBibliograpyButton;
    __unsafe_unretained IBOutlet NSButton* addFieldButton;
    __unsafe_unretained IBOutlet NSButton* viewAllFieldsToggleButton;
}


@end
