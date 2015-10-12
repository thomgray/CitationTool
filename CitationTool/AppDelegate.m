//
//  AppDelegate.m
//  CitationTool3
//
//  Created by Thomas Gray on 16/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
    
@end

@implementation AppDelegate

@synthesize preferenceWindow;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return TRUE;    
}


- (IBAction)openPreferences:(id)sender {
    preferenceWindow = [[PreferencesController alloc]initWithWindowNibName:@"PreferencesWindow"];
    [preferenceWindow showWindow:nil];
}

@end
