//
//  AppDelegate.m
//  CitationTool3
//
//  Created by Thomas Gray on 16/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "AppDelegate.h"
#import "Bibliography.h"
#import "Reference.h"

@interface AppDelegate ()
    
@end

@implementation AppDelegate

@synthesize preferenceWindow;
@synthesize citeModel;
@synthesize bibController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [bibController initialLoad];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return TRUE;    
}

-(void)notifyUpdatedBibliographies{
    if (citeModel) {
        [citeModel refreshReferences];
    }
}

-(void)registerBibUpdate{
    if (bibController) {
        [bibController refreshBibTable];
    }
}


- (IBAction)openPreferences:(id)sender {
    preferenceWindow = [[PreferencesController alloc]initWithWindowNibName:@"PreferencesWindow"];
    [preferenceWindow showWindow:nil];
}

-(void)launchCiteTool:(id)sender{
    citeModel = [[CitationModel alloc]initWithWindowNibName:@"CitationModel"];
    [citeModel setReferences:bibController.references];
    [citeModel setBibliographies:bibController.bibliographies];
    [citeModel showWindow:nil];
}

+(NSImage *)getImageNamed:(NSString *)name{
    NSString* path = [[[NSBundle mainBundle]resourcePath]stringByAppendingString:@"/Images/"];
    path = [path stringByAppendingFormat:@"%@.png", name];
    NSImage* out = [[NSImage alloc]initWithContentsOfFile:path];
    return out;
}


-(IBAction)openMenuItem:(id)sender{
    if (citeModel && citeModel.window==[[NSApplication sharedApplication]keyWindow]) {
        NSOpenPanel* opener = [NSOpenPanel openPanel];
        [opener setAllowsMultipleSelection:NO];
        [opener setAllowedFileTypes:@[@"cit"]];
        
        NSInteger result = [opener runModal];
        if (result== NSOKButton) {
            NSString* path = [[opener URL]path];
            [citeModel openSavedProject:path];
        }
    }
}

-(IBAction)saveMenuItem:(id)sender{
    if (citeModel && citeModel.window==[[NSApplication sharedApplication]keyWindow]) {
        NSSavePanel* saver = [NSSavePanel savePanel];
        [saver setAllowedFileTypes:@[@"cit"]];
        
        NSInteger result = [saver runModal];
        if (result== NSOKButton) {
            NSString* path = [[saver URL]path];
            [citeModel saveProgressAtPath:path];
        }
    }
}

@end
