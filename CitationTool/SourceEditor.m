//
//  SourceEditor.m
//  CitationTool
//
//  Created by Thomas Gray on 21/10/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import "SourceEditor.h"

@interface SourceEditor (Private)

-(void)editSourceRange:(NSRange)range replaceWith:(NSString*)str markEdit:(BOOL)edit;
-(void)deleteFromSource:(NSRange)rng markEdit:(BOOL)edit;
-(void)insertString:(NSString*)insertion inSourceAt:(NSInteger)index editing:(BOOL)edit;


-(void)insertAuthorForLocation:(Location*)loc forIndex:(NSInteger)index withNewAuthor:(NSString*)newAuthor;
-(void)editAuthorNonDynamically:(Location *)loc atIndex:(NSInteger)idx newAuthor:(NSString *)newAuthor inserting:(BOOL)insert;

-(BOOL)tryInsertAmpersandAfter:(NSRange)rng1 deletingComma:(BOOL)delComma;
-(BOOL)tryInsertCommaAfter:(NSRange)rng;
-(BOOL)tryDeletingCommaAfter:(NSRange)rng;
-(BOOL)tryRemoveAmpersandAfter:(NSRange)rng1 addingComma:(BOOL)comma;
-(BOOL)tryRemoveEmptySpaceFrom:(NSInteger)point goingForward:(BOOL)forward flexible:(BOOL)flexible;

+(BOOL)isEtAl:(NSString*)str;
+(NSColor *)editBackgroundColor;
+(NSColor *)editForegroundColor;
+(NSColor *)boringForegoundColor;

@end



@implementation SourceEditor

@synthesize sourceString;
@synthesize citations;

-(instancetype)initWithCitations:(NSMutableArray<Citation *> *)cits andSourceString:(NSMutableAttributedString *)str{
    self = [super init];
    if (self) {
        [self setSourceString:str];
        [self setCitations:cits];
    }
    return self;
}

-(void)editYearForCitation:(Citation *)cit newValue:(NSString *)newYear dynamically:(BOOL)dyn{
    if (!dyn) return;
    for (NSInteger i=0; i<cit.locations.count; i++) {
        Location* loc = [cit.locations objectAtIndex:i];
        [self editYear:loc newValue:newYear];
    }
}

-(void)editYear:(Location*)loc newValue:(NSString*)newYear{
    NSRange oldrange = loc.yearRangeInSource;
    NSRange newRange = NSMakeRange(oldrange.location, newYear.length);
    [loc setYearRangeInSource:newRange];
    [self editSourceRange:oldrange replaceWith:newYear markEdit:YES];
}


-(void)editAuthorForCitation:(Citation *)cit atIndex:(NSInteger)idx newAuthor:(NSString *)newAuthor inserting:(BOOL)inserting dynamically:(BOOL)dyn{
    for (NSInteger j=0; j<cit.locations.count; j++){
        Location* loc = [cit.locations objectAtIndex:j];
        if (dyn) {
            [self editAuthor:loc atIndex:idx newAuthor:newAuthor inserting:inserting];
        }else{
            [self editAuthorNonDynamically:loc atIndex:idx newAuthor:newAuthor inserting:inserting];
        }
    }
}

-(void)editAuthor:(Location*)loc atIndex:(NSInteger)idx newAuthor:(NSString *)newAuthor inserting:(BOOL)insert{
    if (insert) {
        [self insertAuthorForLocation:loc forIndex:idx withNewAuthor:newAuthor];
    }else{
        NSRange rng = [loc.authorRangesInSource objectAtIndex:idx].rangeValue;
        NSString* oldauthor = [sourceString.string substringWithRange:rng];
        if ([SourceEditor isEtAl:newAuthor] && ![SourceEditor isEtAl:oldauthor]) {///from name to etal
            if (idx>0) {
                NSRange prevrange = [loc.authorRangesInSource objectAtIndex:idx-1].rangeValue;
                if ([self tryRemoveAmpersandAfter:prevrange addingComma:NO]) {
                    rng = [loc.authorRangesInSource objectAtIndex:idx].rangeValue;
                }
            }
        }else if (![SourceEditor isEtAl:newAuthor] && [SourceEditor isEtAl:oldauthor]){ // from etal to name
            if (idx >0 && idx==loc.authorRangesInSource.count-1) {
                NSRange prevrng = [loc.authorRangesInSource objectAtIndex:idx-1].rangeValue;
                if ([self tryInsertAmpersandAfter:prevrng deletingComma:YES]) {
                    rng = [loc.authorRangesInSource objectAtIndex:idx].rangeValue;
                }
            }
        }
        [loc.authorRangesInSource replaceObjectAtIndex:idx withObject:[NSValue valueWithRange:NSMakeRange(rng.location, newAuthor.length)]];
        [self editSourceRange:rng replaceWith:newAuthor markEdit:YES];
    }
}

-(void)insertAuthorForLocation:(Location *)loc forIndex:(NSInteger)index withNewAuthor:(NSString *)newAuthor{
    if (loc.authorRangesInSource.count==0) { //this is first & only author
        NSInteger insertionPoint = loc.yearRangeInSource.location;
        for (; insertionPoint>0; insertionPoint--) {
            unichar c = [sourceString.string characterAtIndex:insertionPoint];
            if ([[NSCharacterSet whitespaceAndNewlineCharacterSet]characterIsMember:c]) {
                break;
            }
        }
        NSRange newAuthRange = NSMakeRange(insertionPoint, newAuthor.length);
        newAuthor = [newAuthor stringByAppendingString:@" "];
        [self insertString:newAuthor inSourceAt:insertionPoint editing:YES];
        [loc.authorRangesInSource addObject:[NSValue valueWithRange:newAuthRange]];
    }else if (index<loc.authorRangesInSource.count){ //inserted in front of author;
        NSRange leadingAuthorRange = [loc.authorRangesInSource objectAtIndex:index].rangeValue;
        NSString* leadingAuthorString = [sourceString.string substringWithRange:leadingAuthorRange];
        if (index>0) { //try delete ampersand
            NSRange trailineAuthorRange = [loc.authorRangesInSource objectAtIndex:index-1].rangeValue;
            [self tryRemoveAmpersandAfter:trailineAuthorRange addingComma:YES];
            leadingAuthorRange = [loc.authorRangesInSource objectAtIndex:index].rangeValue;
        }
        NSInteger insertionPoint = leadingAuthorRange.location;
        NSRange newAuthorRange = NSMakeRange(insertionPoint, newAuthor.length);
        if ([SourceEditor isEtAl:leadingAuthorString]){
            newAuthor = [newAuthor stringByAppendingString:@" "];
        }else if (index==loc.authorRangesInSource.count-1) { //this is penultimate;
            newAuthor = [newAuthor stringByAppendingString:@" & "];
        }else{
            newAuthor = [newAuthor stringByAppendingString:@", "];
        }
        [self insertString:newAuthor inSourceAt:insertionPoint editing:YES];
        [loc.authorRangesInSource insertObject:[NSValue valueWithRange:newAuthorRange] atIndex:index];
    }else{ //this is at the end of a list of authors
        if (loc.authorRangesInSource.count>1) {
            NSRange penultimateOne = [loc.authorRangesInSource objectAtIndex:index-2].rangeValue;
            [self tryRemoveAmpersandAfter:penultimateOne addingComma:YES];
        }
        NSInteger insertionPoint = [loc.authorRangesInSource objectAtIndex:index-1].rangeValue.location;
        for (; insertionPoint<sourceString.length; insertionPoint++) {
            unichar c = [sourceString.string characterAtIndex:insertionPoint];
            if ([[NSCharacterSet whitespaceAndNewlineCharacterSet]characterIsMember:c]) {
                break;
            }
        }
        NSRange newAuthorRange;
        if ([SourceEditor isEtAl:newAuthor]) {
            newAuthorRange = NSMakeRange(insertionPoint+1, newAuthor.length);
            newAuthor = [NSString stringWithFormat:@" %@", newAuthor];
            [self insertString:newAuthor inSourceAt:insertionPoint editing:YES];
        }else{
            newAuthorRange = NSMakeRange(insertionPoint+3, newAuthor.length);
            [self insertString:@" & " inSourceAt:insertionPoint editing:NO];
            [self insertString:newAuthor inSourceAt:insertionPoint+3 editing:YES];
        }
        [loc.authorRangesInSource addObject:[NSValue valueWithRange:newAuthorRange]];
    }
}

-(void)editAuthorNonDynamically:(Location *)loc atIndex:(NSInteger)idx newAuthor:(NSString *)newAuthor inserting:(BOOL)insert{
    if (insert) {
        NSInteger bottomRange = loc.yearRangeInSource.location>150? loc.range.location:0;
        NSRange searchRange = NSMakeRange(bottomRange, loc.yearRangeInSource.location-bottomRange);
        NSRange newRange = [sourceString.string rangeOfString:newAuthor options:NSBackwardsSearch range:searchRange];
        if (newRange.location==NSNotFound) {
            NSInteger topRange = loc.yearRangeInSource.location+loc.yearRangeInSource.length+150<sourceString.length? loc.yearRangeInSource.location+loc.yearRangeInSource.length+150: sourceString.length;
            searchRange = NSMakeRange(loc.yearRangeInSource.location+loc.yearRangeInSource.length, topRange-loc.yearRangeInSource.location-loc.yearRangeInSource.length);
            newRange = [sourceString.string rangeOfString:newAuthor options:NSLiteralSearch range:searchRange];
        }
        if (newRange.location!=NSNotFound) {
            [loc.authorRangesInSource replaceObjectAtIndex:idx withObject:[NSValue valueWithRange:newRange]];
        }else{
            NSValue* dudRange;
            if (loc.authorRangesInSource.count>idx) {
                dudRange = [[loc.authorRangesInSource objectAtIndex:idx]copy];
            }else if (loc.authorRangesInSource.count){
                dudRange = [[loc.authorRangesInSource objectAtIndex:loc.authorRangesInSource.count-1]copy];
            }else{
                dudRange = [NSValue valueWithRange:loc.yearRangeInSource];
            }
            [loc.authorRangesInSource replaceObjectAtIndex:idx withObject:dudRange];
        }
    }else{
        NSRange oldAuthorRange = [loc.authorRangesInSource objectAtIndex:idx].rangeValue;
        NSString* oldAuthorString = [sourceString.string substringWithRange:oldAuthorRange];
        if ([oldAuthorString containsString:newAuthor]) {
            NSRange newRange = [sourceString.string rangeOfString:newAuthor options:NSLiteralSearch range:oldAuthorRange];
            [loc.authorRangesInSource replaceObjectAtIndex:idx withObject:[NSValue valueWithRange:newRange]];
        }
    }
}

-(void)removeAuthor:(Location *)loc atIndex:(NSInteger)index{
    if (index==loc.authorRangesInSource.count-1 && loc.authorRangesInSource.count>1) { //last of several
        NSRange newLastAuthorRng = [loc.authorRangesInSource objectAtIndex:index-1].rangeValue;
        NSString* newLastAutorString = [sourceString.string substringWithRange:newLastAuthorRng];
        if (![SourceEditor isEtAl:newLastAutorString] && loc.authorRangesInSource.count>2) {
            NSRange penultimate = [loc.authorRangesInSource objectAtIndex:index-2].rangeValue;
            [self tryInsertAmpersandAfter:penultimate deletingComma:YES];
            newLastAuthorRng = [loc.authorRangesInSource objectAtIndex:index-1].rangeValue;
        }
        NSInteger removebottom = newLastAuthorRng.location + newLastAuthorRng.length;
        NSRange removeAuthorRange = [loc.authorRangesInSource objectAtIndex:index].rangeValue;
        NSRange removeRange = NSMakeRange(removebottom, removeAuthorRange.location+removeAuthorRange.length-removebottom);
        [self deleteFromSource:removeRange markEdit:YES];
        [loc.authorRangesInSource removeObjectAtIndex:index];
        [self tryRemoveEmptySpaceFrom:removeRange.location-1 goingForward:NO flexible:NO];
    }else if (index==0 && loc.authorRangesInSource.count==1){ //removing only one;
        NSRange removeAuthorRange = [loc.authorRangesInSource objectAtIndex:index].rangeValue;
        if ([sourceString.string characterAtIndex:removeAuthorRange.location+removeAuthorRange.length]==',') {
            removeAuthorRange = NSMakeRange(removeAuthorRange.location, removeAuthorRange.length+1);
        }
        NSInteger point = removeAuthorRange.location+removeAuthorRange.length;
        for (; point<sourceString.length; point++) {
            unichar c= [sourceString.string characterAtIndex:point];
            if (![[NSCharacterSet whitespaceAndNewlineCharacterSet]characterIsMember:c]) break;
        }
        removeAuthorRange = NSMakeRange(removeAuthorRange.location, point-removeAuthorRange.location);
        [self deleteFromSource:removeAuthorRange markEdit:YES];
    }else{ //removing from more than one, and removed author is not at the end
        NSRange removeRange;
        NSRange authorToRemoveRange = [loc.authorRangesInSource objectAtIndex:index].rangeValue;
        NSInteger point = authorToRemoveRange.location+authorToRemoveRange.length;
        if ([sourceString.string characterAtIndex:point]==',') point++;
        for (; point<sourceString.length; point++) {
            unichar c = [sourceString.string characterAtIndex:point];
            if (![[NSCharacterSet whitespaceAndNewlineCharacterSet]characterIsMember:c]) break;
        }
        removeRange = NSMakeRange(authorToRemoveRange.location, point-authorToRemoveRange.location);
        [self deleteFromSource:removeRange markEdit:YES];
        [loc.authorRangesInSource removeObjectAtIndex:index];
    }
}


-(void)removeAuthorForCitation:(Citation *)cit atIndex:(NSInteger)index{
    for (NSInteger k=0; k<cit.locations.count; k++) {
        Location* loc =[cit.locations objectAtIndex:k];
        [self removeAuthor:loc atIndex:index];
    }
}

-(void)adjustLocationsForCitationsAtIndex:(NSInteger)idx byOffset:(NSInteger)off inclusively:(BOOL)inc{
    for (NSInteger m=0; m<citations.count; m++){
        Citation* cit =[citations objectAtIndex:m];
        for (NSInteger n=0; n<cit.locations.count; n++) {
            Location* loc = [cit.locations objectAtIndex:n];
            NSMutableArray<NSValue*>* newRanges = [[NSMutableArray alloc]initWithCapacity:loc.authorRangesInSource.count];
            for (NSInteger i=0; i<loc.authorRangesInSource.count; i++) {
                NSRange rng = [loc.authorRangesInSource objectAtIndex:i].rangeValue;
                if (rng.location>= (inc? idx:idx+1)) {
                    rng = NSMakeRange(rng.location+off, rng.length);
                }
                [newRanges addObject:[NSValue valueWithRange:rng]];
            }
            [loc setAuthorRangesInSource:newRanges];
            if ([loc yearRangeInSource].location >= (inc? idx:idx+1)) {
                [loc setYearRangeInSource:NSMakeRange(loc.yearRangeInSource.location+off, loc.yearRangeInSource.length)];
            }
        }
    }
}


#pragma mark General Editor Methods

-(void)insertString:(NSString*)insertion inSourceAt:(NSInteger)index editing:(BOOL)edit{
    NSAttributedString* instr;
    if (edit) {
        instr = [[NSAttributedString alloc]initWithString:insertion attributes:@{NSForegroundColorAttributeName:[SourceEditor editForegroundColor]}];
    }else instr = [[NSAttributedString alloc]initWithString:insertion];
    
    [sourceString insertAttributedString:instr atIndex:index];
    [self adjustLocationsForCitationsAtIndex:index byOffset:insertion.length inclusively:YES];
}

-(void)editSourceRange:(NSRange)range replaceWith:(NSString *)str markEdit:(BOOL)edit{
    [self adjustLocationsForCitationsAtIndex:range.location byOffset:(str.length-range.length) inclusively:NO];
    [sourceString replaceCharactersInRange:range withString:str];
    if (edit) {
        [sourceString addAttribute:NSForegroundColorAttributeName value:[SourceEditor editForegroundColor] range:NSMakeRange(range.location, str.length)];
    }
}

-(void)deleteFromSource:(NSRange)rng markEdit:(BOOL)edit{
    [self adjustLocationsForCitationsAtIndex:rng.location byOffset:-rng.length inclusively:NO];
    [sourceString deleteCharactersInRange:rng];
    if (edit) {
        [sourceString addAttribute:NSBackgroundColorAttributeName value:[SourceEditor editBackgroundColor] range:NSMakeRange(rng.location, 1)];
    }
}


-(BOOL)tryInsertAmpersandAfter:(NSRange)rng1 deletingComma:(BOOL)delComma{
    NSInteger topOfRng1 = rng1.location+rng1.length;
    if (delComma && [sourceString.string characterAtIndex:topOfRng1]==',') {
        NSRange commaRange = NSMakeRange(topOfRng1, 1);
        [self deleteFromSource:commaRange markEdit:NO];
    }else{
        for (; topOfRng1<sourceString.length; topOfRng1++) {
            unichar c = [sourceString.string characterAtIndex:topOfRng1];
            if ([[NSCharacterSet whitespaceAndNewlineCharacterSet]characterIsMember:c]) {
                break;
            }
        }
    }
    NSInteger top = topOfRng1;
    for (; top<sourceString.length; top++) {
        unichar c = [sourceString.string characterAtIndex:top];
        if (![[NSCharacterSet whitespaceAndNewlineCharacterSet]characterIsMember:c]) {
            break;
        }
    }
    if (top==topOfRng1) {
        return FALSE;
    }
    NSRange toRemove = NSMakeRange(topOfRng1, top-topOfRng1);
    NSString* amp = @" & ";
    [self editSourceRange:toRemove replaceWith:amp markEdit:NO];
    return TRUE;
}

-(BOOL)tryInsertCommaAfter:(NSRange)rng{
    NSInteger i = rng.location+rng.length;
    unichar c= [sourceString.string characterAtIndex:i];
    if (c!=',') {
        NSAttributedString* insertion = [[NSAttributedString alloc]initWithString:@","];
        [sourceString insertAttributedString:insertion atIndex:i];
        [self adjustLocationsForCitationsAtIndex:i byOffset:1 inclusively:YES];
        return TRUE;
    }else return FALSE;
}

-(BOOL)tryDeletingCommaAfter:(NSRange)rng{
    NSInteger i = rng.location+rng.length;
    unichar c= [sourceString.string characterAtIndex:i];
    if (c==',') {
        [sourceString deleteCharactersInRange:NSMakeRange(i, 1)];
        [self adjustLocationsForCitationsAtIndex:i byOffset:-1 inclusively:YES];
        return TRUE;
    }else return FALSE;
}

-(BOOL)tryRemoveAmpersandAfter:(NSRange)rng1 addingComma:(BOOL)comma{
    NSInteger bottom = rng1.location+rng1.length;
    unichar c = [sourceString.string characterAtIndex:bottom];
    if (c!=',' && comma) {
        [sourceString insertAttributedString:[[NSAttributedString alloc]initWithString:@","] atIndex:bottom];
        [self adjustLocationsForCitationsAtIndex:bottom byOffset:1 inclusively:YES];
    }
    for (; bottom<sourceString.length; bottom++) {
        if ([[NSCharacterSet whitespaceAndNewlineCharacterSet]characterIsMember:[sourceString.string characterAtIndex:bottom]]) {
            break;
        }
    }
    NSInteger top = bottom;
    for (; top<sourceString.length; top++) {
        if (![[NSCharacterSet whitespaceAndNewlineCharacterSet]characterIsMember:[sourceString.string characterAtIndex:top]]) {
            break;
        }
    }
    if (top==bottom) return FALSE;
    
    NSInteger topNextWord = top;
    for (; topNextWord<sourceString.length; topNextWord++) {
        unichar c= [sourceString.string characterAtIndex:topNextWord];
        if ([[NSCharacterSet whitespaceAndNewlineCharacterSet]characterIsMember:c]) {
            break;
        }
    }
    if (topNextWord==top) return FALSE;
    
    NSRange wordRange = NSMakeRange(top, topNextWord-top);
    NSString* str = [sourceString.string substringWithRange:wordRange];
    if ([str isEqualToString:@"&"]  || [str isEqualToString:@"and"] || [str isEqualToString:@"And"]) {
        NSRange toGo = NSMakeRange(bottom, topNextWord-bottom);
        [self deleteFromSource:toGo markEdit:NO];
        return TRUE;
    }
    return FALSE;
}

-(BOOL)tryRemoveEmptySpaceFrom:(NSInteger)point goingForward:(BOOL)forward flexible:(BOOL)flexible{
    int diff = 0;
    BOOL started = !flexible;
    for (NSInteger i = point; (forward? i<sourceString.length:i>=0); (forward? i++:i--)) {
        unichar c = [sourceString.string characterAtIndex:i];
        if ([[NSCharacterSet whitespaceCharacterSet]characterIsMember:c]) {
            if (!started){
                started = TRUE;
                point = i;
            }
            diff++;
        }else if(!started) continue;
        else break;
    }
    if (!diff) return FALSE;
    if (!forward) point -=diff;
    NSRange removerng = NSMakeRange(point, diff);
    [self deleteFromSource:removerng markEdit:NO];
    return TRUE;
}


#pragma mark Static Methods

+(BOOL)isEtAl:(NSString *)str{
    str = [[str lowercaseString]stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
    if ([str isEqualToString:@"et al"] || [str isEqualToString:@"et. al"] || [str isEqualToString:@"etal"]
        || [str isEqualToString:@"et.al"] || [str isEqualToString:@"et-al"]) {
        return TRUE;
    }return FALSE;
}

+(NSColor *)editBackgroundColor{
    return [NSColor colorWithCalibratedRed:1 green:.3 blue:.3 alpha:.4];
}

+(NSColor *)editForegroundColor{
    return [NSColor colorWithCalibratedRed:.5 green:0 blue:0 alpha:1];
}

+(NSColor*)boringForegoundColor{
    return [NSColor colorWithCalibratedWhite:0 alpha:.5];
}

@end
