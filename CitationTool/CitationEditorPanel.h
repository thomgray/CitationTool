#import <Cocoa/Cocoa.h>
#import "EditorController.h"

@interface CitationEditorPanel : NSPanel{
    
    __unsafe_unretained IBOutlet NSButton *rightArrow;
    __unsafe_unretained IBOutlet NSButton *downArrow;
    __unsafe_unretained IBOutlet NSButton *upArrow;
    __unsafe_unretained IBOutlet NSButton *leftArrow;
    __unsafe_unretained IBOutlet NSButton *ignoreButton;
    __unsafe_unretained IBOutlet EditorController *controller;
}



@end
