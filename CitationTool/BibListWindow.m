//
//  BibListWindow.m
//  CitationTool
//
//  Created by Thomas Gray on 25/10/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import "BibListWindow.h"
#import "AppDelegate.h"

@implementation BibListWindow

-(void)awakeFromNib{
    NSImage* addUp = [AppDelegate getImageNamed:@"addIconUp_19"];
    NSImage* addDown = [AppDelegate getImageNamed:@"addIconDown_19"];
    
    [addFieldButton setImage:addUp];
    [addFieldButton setAlternateImage:addDown];
    [addBibliograpyButton setImage:addUp];
    [addBibliograpyButton setAlternateImage:addDown];
    
    NSImage* viewup = [AppDelegate getImageNamed:@"viewIconUp_19"];
    NSImage* viewdown = [AppDelegate getImageNamed:@"viewIconDown_19"];
    [viewAllFieldsToggleButton setImage:viewup];
    [viewAllFieldsToggleButton setAlternateImage:viewdown];
    
    NSImage* addUp19 = [AppDelegate getImageNamed:@"addIconUp_19"];
    NSImage* addDown19 = [AppDelegate getImageNamed:@"addIconDown_19"];
    [addReferenceButton setImage:addUp19];
    [addReferenceButton setAlternateImage:addDown19];
}


@end
