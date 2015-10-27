#import "CitationEditorPanel.h"
#import "AppDelegate.h"

@implementation CitationEditorPanel

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (BOOL)canBecomeMainWindow {
    return YES;
}

-(void)awakeFromNib{    
    [rightArrow setImage:[AppDelegate getImageNamed:@"arrowRight"]];
    [leftArrow setImage:[AppDelegate getImageNamed:@"arrowLeft"]];
    [upArrow setImage:[AppDelegate getImageNamed:@"arrowUp"]];
    [downArrow setImage:[AppDelegate getImageNamed:@"arrowDown"]];
    [ignoreButton setImage:[AppDelegate getImageNamed:@"cancel"]];
    
    NSImage* addUp = [AppDelegate getImageNamed:@"addIconUp_15"];
    NSImage* addDown = [AppDelegate getImageNamed:@"addIconDown_15"];
    NSImage* forgetUp = [AppDelegate getImageNamed:@"forgetIconUp_15"];
    NSImage* forgetDown = [AppDelegate getImageNamed:@"forgetIconDown_15"];
    NSImage* removeUp = [AppDelegate getImageNamed:@"removeIconUp_15"];
    NSImage* removeDown = [AppDelegate getImageNamed:@"removeIconDown_15"];
    
    [addAuthorButton setImage:addUp];
    [addAuthorButton setAlternateImage:addDown];
    [addReferenceButton setImage:addUp];
    [addReferenceButton setAlternateImage:addDown];
    [removeAuthorButton setImage:removeUp];
    [removeAuthorButton setAlternateImage:removeDown];
    [forgetAuthorButton setImage:forgetUp];
    [forgetAuthorButton setAlternateImage:forgetDown];
    [ignoreButton setImage:forgetUp];
    [ignoreButton setAlternateImage:forgetDown];
}

-(void)moveRight:(id)sender{
    [controller nextRef:self];
}

-(void)moveLeft:(id)sender{
    [controller prevRef:self];
}




@end