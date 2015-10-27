//
//  BibTexTextView.m
//  CitationTool
//
//  Created by Thomas Gray on 17/10/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import "BibTexTextView.h"
#import "Reference.h"

@interface BibTexTextView (Private)

-(NSRange)getCurrentLineRange;
-(NSRange)getPreviousLineRange;
-(NSRange)getRangeOfLineAtIndex:(NSInteger)i;
-(int)indentOfLine:(NSRange)lineRange;

-(void)insertString:(NSString*)str atIndex:(NSUInteger)index afterCursor:(BOOL)after;

@end

@implementation BibTexTextView

-(void)awakeFromNib{
    self.automaticTextReplacementEnabled = false;
}


-(void)keyDown:(NSEvent *)theEvent{
    [super keyDown:theEvent];
    if (theEvent.characters.length>1) return;
    
    ///implement charlength==0 event to block exceptiions!!
    if(theEvent.characters.length<1) return;
    
    NSRange firstRealChar = [self.string rangeOfCharacterFromSet:[[NSCharacterSet whitespaceAndNewlineCharacterSet]invertedSet]];
    if (!firstRealChar.length) return;
    if ([[self.string substringWithRange:firstRealChar]characterAtIndex:0]!='@') {
        [self insertString:@"@" atIndex:firstRealChar.location afterCursor:NO];
        //[self setSelectedRange:NSMakeRange(selrng.location+1, selrng.length)];
    }
    
    if ([[NSCharacterSet newlineCharacterSet] characterIsMember:[theEvent.characters characterAtIndex:0]]) {
        NSRange lineRange = [self getPreviousLineRange];
        int indent = [self indentOfLine:lineRange];
        
        NSString* thisLine = [[self.string substringWithRange:lineRange]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (thisLine.length>0 && [thisLine characterAtIndex:0]=='@') {
            int lr=0;
            for (NSInteger i=0; i<thisLine.length; i++) {
                unichar c= [thisLine characterAtIndex:i];
                if (c=='{') lr++;
                else if (c=='}') lr--;
            }
            if (lr<=0) return;
            indent++;
            NSString* indentString = @"";
            for (int j=0;j<indent;j++) indentString = [indentString stringByAppendingString:@"\t"];
            [self insertString:indentString atIndex:[self selectedRange].location afterCursor:NO];
            NSString* newline = [NSString stringWithFormat:@"\n%@}", [indentString substringFromIndex:1]];
            [self insertString:newline atIndex:[self selectedRange].location afterCursor:YES];
        }else{
            NSString* indentString = @"";
            for (int j=0;j<indent;j++) indentString = [indentString stringByAppendingString:@"\t"];
            [self insertString:indentString atIndex:[self selectedRange].location afterCursor:NO];
        }
    }
}

-(void)keyUp:(NSEvent *)theEvent{
    [super keyUp:theEvent];
}


-(NSRange)getCurrentLine{
    return [self getRangeOfLineAtIndex:[self selectedRange].location];
}

-(NSRange)getPreviousLineRange{
    NSInteger i = [self selectedRange].location-1;
    if (i<0) return NSMakeRange(0, 0);
    for (; i>=0; i--) {
        unichar c = [self.string characterAtIndex:i];
        if ([[NSCharacterSet newlineCharacterSet]characterIsMember:c]){
            return [self getRangeOfLineAtIndex:i];
        }
    }
    return NSMakeRange(0, 0);
}

-(NSRange)getRangeOfLineAtIndex:(NSInteger)i{
    if (i<0)return NSMakeRange(0, 0);
    NSInteger begin=i-1; NSInteger end=i;
    NSString* str = self.string;
    NSCharacterSet* newlines = [NSCharacterSet newlineCharacterSet];
    
    if (begin<0) begin=0;
    else{
        for (; begin>=0; begin--) {
            unichar c = [str characterAtIndex:begin];
            if ([newlines characterIsMember:c]){
                begin++;
                break;
            }else if (begin==0){
                break;
            }
        }
    }
    
    if (end > str.length-1) end = str.length;
    else{
        for (; end<str.length; end++) {
            unichar c = [str characterAtIndex:end];
            if ([newlines characterIsMember:c]) {
                break;
            }else if (end==str.length-1){
                end++;
                break;
            }
        }
    }
    return NSMakeRange(begin, end-begin);
}

-(int)indentOfLine:(NSRange)lineRange{
    NSString* str = [self.string substringWithRange:lineRange];
    int out=0;
    for (NSInteger i=0; i<str.length; i++) {
        unichar c = [str characterAtIndex:i];
        if ([[[NSCharacterSet whitespaceCharacterSet]invertedSet]characterIsMember:c]) break;
        else if (c=='\t') out++;
    }
    return out;
}

-(void)insertString:(NSString *)str atIndex:(NSUInteger)index afterCursor:(BOOL)after{
    NSRange selRng = [self selectedRange];
    NSString* prev = [self.string substringToIndex:index];
    NSString* aft = [self.string substringFromIndex:index];
    [self setString:[NSString stringWithFormat:@"%@%@%@", prev, str, aft]];
    if ((after && selRng.location>index) || (!after && selRng.location>=index)) {
        [self setSelectedRange:NSMakeRange(selRng.location+str.length, selRng.length)];
    }else{
        [self setSelectedRange:selRng];
    }
}

@end
