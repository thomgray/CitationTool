//
//  AppDelegate.h
//  CitationTool3
//
//  Created by Thomas Gray on 16/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CitationModel.h"
#import "BibListController.h"
#import "PreferencesController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property CitationModel *citeModel;
@property (unsafe_unretained) IBOutlet BibListController* bibController;
@property PreferencesController * preferenceWindow;

- (IBAction)openPreferences:(id)sender;
-(IBAction)launchCiteTool:(id)sender;

-(void)notifyUpdatedBibliographies;
-(void)registerBibUpdate;


+(NSImage*)getImageNamed:(NSString*)name;

@end

