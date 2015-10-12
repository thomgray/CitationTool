#import "CitationEditorPanel.h"

@implementation CitationEditorPanel

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (BOOL)canBecomeMainWindow {
    return YES;
}

-(void)awakeFromNib{
    NSString* path = [NSString stringWithFormat:@"%@/Images/", [[NSBundle mainBundle]resourcePath]] ;
    NSImage *right = [[NSImage alloc]initWithContentsOfFile:[path stringByAppendingString:@"arrowRight.png"]];
    NSImage *left = [[NSImage alloc]initWithContentsOfFile:[path stringByAppendingString:@"arrowLeft.png"]];
    NSImage *up = [[NSImage alloc]initWithContentsOfFile:[path stringByAppendingString:@"arrowUp.png"]];
    NSImage *down = [[NSImage alloc]initWithContentsOfFile:[path stringByAppendingString:@"arrowDown.png"]];
    
    NSImage * cancel = [[NSImage alloc]initByReferencingFile:[path stringByAppendingString:@"cancel.png"]];
    
    [rightArrow setImage:right];
    [leftArrow setImage:left];
    [upArrow setImage:up];
    [downArrow setImage:down];
    [ignoreButton setImage:cancel];
}

-(void)moveRight:(id)sender{
    [controller nextRef:self];
}

-(void)moveLeft:(id)sender{
    [controller prevRef:self];
}




@end