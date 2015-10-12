//
//  AppDelegate.h
//  CitationTool3
//
//  Created by Thomas Gray on 16/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindow.h"
#import "PreferencesController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (unsafe_unretained) IBOutlet MainWindow *mainWindow;
@property PreferencesController * preferenceWindow;

- (IBAction)openPreferences:(id)sender;


@end

