//
//  CitationIterator.m
//  CitationTool
//
//  Created by Thomas Gray on 19/10/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import "CitationIterator.h"
#import "Parser.h"

@interface CitationIterator ()

@property NSArray* namePrefixes;
@property NSArray* nonNames;
@property NSCharacterSet* extraGrammar;
@property NSCharacterSet* separators;

-(void)loadNamePrefixes;
-(void)loadNonNames;
//-(NSString*)nextWordPrefixingRange:(NSInteger)idx;
//-(NSString*)previousWordAffixingRange:(NSInteger)idx;


-(BOOL)tryAddName:(Citation*)cit;
-(BOOL)tryAddEtAl:(Citation*)cit;

-(BOOL)stringIsAnd:(NSString*)str;
-(BOOL)stringIsDate:(NSString*)str;
-(BOOL)stringIsProbableName:(NSString*)str;

-(BOOL)shouldEndIteration:(StringIterator*)it;

-(NSRange)trimmedCurrentRange:(NSCharacterSet* _Nullable)chars;




@end



@implementation CitationIterator

@synthesize namePrefixes;
@synthesize extraGrammar;
@synthesize separators;
@synthesize nonNames;

#pragma mark Initialisers

-(instancetype)init{
    self = [super init];
    if (self) {
        [self addDelimiters:[NSCharacterSet characterSetWithCharactersInString:@"\\/;:"]];
        [self loadNamePrefixes];
        [self loadNonNames];
        extraGrammar = [CitationIterator extraGrammar];
        separators = [NSCharacterSet characterSetWithCharactersInString:@"{}(),.;:"];
    }
    return self;
}

-(instancetype)initWithString:(NSString *)str goingForward:(BOOL)fwd{
    self = [super initWithString:str goingForward:fwd];
    if (self) {
        [self addDelimiters:[NSCharacterSet characterSetWithCharactersInString:@"\\/;:"]];
        [self loadNamePrefixes];
        [self loadNonNames];
        extraGrammar = [CitationIterator extraGrammar];
        separators = [NSCharacterSet characterSetWithCharactersInString:@"{}(),.;:"];
    }
    
    return self;
}

-(instancetype)initByTakingOver:(StringIterator *)it{
    self = [super initByTakingOver:it];
    if (self) {
        if ([it isMemberOfClass:[CitationIterator class]]) {
            extraGrammar = ((CitationIterator*)it).extraGrammar;
            namePrefixes = ((CitationIterator*)it).namePrefixes;
            separators = ((CitationIterator*)it).separators;
            nonNames = ((CitationIterator*)it).nonNames;
        }else{
            extraGrammar = [CitationIterator extraGrammar];
            [self loadNamePrefixes];
            [self loadNonNames];
            separators = [NSCharacterSet characterSetWithCharactersInString:@"{}(),.;:"];
        }
    }
    return self;
}

-(void)takeOver:(StringIterator *)it{
    [self modifyCurrentWordRange:it.currentWordRange];
}

-(void)loadNamePrefixes{
    NSString* path = [[[NSBundle mainBundle]resourcePath]stringByAppendingString:@"/prefixes.txt"];
    NSArray* temp = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray* temp2 = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i<temp.count; i++) {
        NSString* str = [temp objectAtIndex:i];
        if (str.length>0) {
            [temp2 addObject:str];
            [temp2 addObject:[str lowercaseString]];
        }
    }
    namePrefixes = [[NSArray alloc]initWithArray:temp2];
}

-(void)loadNonNames{
    NSString* path = [[[NSBundle mainBundle]resourcePath]stringByAppendingString:@"/nonNames.txt"];
    NSArray* temp = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray* temp2 = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i<temp.count; i++) {
        NSString* str = [temp objectAtIndex:i];
        if (str.length) {
            [temp2 addObject:str];
        }
    }
    nonNames = [[NSArray alloc]initWithArray:temp2];
}

#pragma mark Name Analysis

-(Citation *)getCitation:(StringIterator *)it forDate:(Year *)yr{
    [self takeOverIterator:it];
    Citation* citation = [[Citation alloc]initWithYear:yr];
    citation.locations = [[NSMutableArray alloc]initWithObjects:[[Location alloc]init], nil];
    BOOL started = FALSE;
    while ([self previousWord]) {
        NSString* word = self.currentWord;
        
        
        NSString* trimmed = [word stringByTrimmingCharactersInSet:extraGrammar];
    
        if ([self tryAddName:citation]) {
            started = TRUE;
        }else if ([self tryAddEtAl:citation]){
            started = TRUE;
        }else if ([self stringIsAnd:trimmed]){
            continue;
        }else if ([self stringIsDate:trimmed]){
            if (started) {
                break;
            }else continue;
        }else break;
        
        
        if ([self shouldEndIteration:it]) break;
    }
    return citation;
}


-(BOOL)tryAddEtAl:(Citation *)cit{
    Location* loc = [cit.locations firstObject];
    NSString* str = self.currentWord;
    NSString* trimmed = [str stringByTrimmingCharactersInSet:extraGrammar];
    trimmed = [trimmed lowercaseString];
    if ([trimmed isEqualToString:@"etal"] || [trimmed isEqualToString:@"et-al"] || [trimmed isEqualToString:@"et.al"] || [trimmed isEqualToString:@"et.-al"]) {
        [cit.authors insertObject:ET_AL atIndex:0];
        NSRange etAlRange = [self trimmedCurrentRange:nil];
        NSInteger stopIndex = etAlRange.location+etAlRange.length;
        if (stopIndex<self.source.length && [self.source characterAtIndex:stopIndex]=='.') {
            etAlRange = NSMakeRange(etAlRange.location, etAlRange.length+1);
        }
        [loc addRangeToAuthorSourceArray:etAlRange];
        return TRUE;
    }else if ([trimmed isEqualToString:@"al"]){
        NSRange thisrang = [self trimmedCurrentRange:extraGrammar];
        NSRange peekRange = [self peekRangeOfPreviousWord];
        NSString* peek = [[[self.source substringWithRange:peekRange]stringByTrimmingCharactersInSet:extraGrammar]lowercaseString];
        if ([peek isEqualToString:@"et"]) {
            peekRange = [self.source rangeOfString:peek options:NSCaseInsensitiveSearch range:peekRange];
            NSRange rang = [CitationIterator mergeRanges:peekRange and:thisrang];
            [self previousWord];
            [cit.authors insertObject:ET_AL atIndex:0];
            NSInteger top = rang.location+rang.length;
            if (top<self.source.length && [self.source characterAtIndex:top]=='.') {
                rang = NSMakeRange(rang.location, rang.length+1);
            }
            [loc addRangeToAuthorSourceArray:rang];
            return TRUE;
        }else return FALSE;
    }
    return FALSE;
}

-(BOOL)tryAddName:(Citation *)cit{
    Location* loc = [cit.locations firstObject];
    NSString* str = [self.currentWord stringByTrimmingCharactersInSet:extraGrammar];
    if ([self stringIsProbableName:str]) {
        NSRange authorRange = [self.source rangeOfString:str options:NSLiteralSearch range:self.currentWordRange];
        NSString* prev;
        if ([self shouldEndIteration:nil]) goto ending;
        while ((prev = [self peekPreviousWord])) {
            NSString * trimmedPrev = [prev stringByTrimmingCharactersInSet:[CitationIterator extraGrammar]];
            if (!trimmedPrev.length) break;
            if ([namePrefixes containsObject:[prev stringByTrimmingCharactersInSet:extraGrammar]]) {
                [self previousWord];
                NSRange newrange = [self trimmedCurrentRange:extraGrammar];
                authorRange = [CitationIterator mergeRanges:newrange and:authorRange];
            }else if ([self stringIsProbableName:trimmedPrev]){
                unichar c = [prev characterAtIndex:prev.length-1];
                if ([[NSCharacterSet letterCharacterSet]characterIsMember:c]) {
                    [self previousWord];
                    NSRange newrange = [self trimmedCurrentRange:extraGrammar];
                    authorRange = [CitationIterator mergeRanges:newrange and:authorRange];
                    //if ([self shouldEndIteration:nil]) break;
                }else break;
            }else break;
            if ([self shouldEndIteration:nil]) break;
        }
    ending:;
        NSString* author = [self.source substringWithRange:authorRange];
        [cit.authors insertObject:author atIndex:0];
        [loc addRangeToAuthorSourceArray:authorRange];
        return TRUE;
    }
    return FALSE;
}

-(BOOL)stringIsAnd:(NSString *)str{
    str = [str lowercaseString];
    return [str isEqualToString:@"and"] || [str isEqualToString:@"&"];
}

-(BOOL)stringIsDate:(NSString *)str{
    if (!str.length) return false;
    Year* yr = [Parser getYearFromString:str];
    return (yr!=nil);
}

-(BOOL)stringIsProbableName:(NSString *)str{
    if (!str.length) return false;
    if ([[NSCharacterSet uppercaseLetterCharacterSet]characterIsMember:[str characterAtIndex:0]]) {
        if ([nonNames containsObject:str]) {
            return FALSE;
        }
        return TRUE;
    }
    return FALSE;
}

-(NSRange)trimmedCurrentRange:(NSCharacterSet *)chars{
    if (!chars) chars = extraGrammar;
    NSRange rng = [self currentWordRange];
    NSString* trim = [self.currentWord stringByTrimmingCharactersInSet:chars];
    if (trim.length==0) return NSMakeRange(NSNotFound, 0);
    
    return [self.source rangeOfString:trim options:NSLiteralSearch range:rng];
}


+(NSRange)mergeRanges:(NSRange)rng1 and:(NSRange)rng2{
    NSInteger bottom = (rng1.location<rng2.location)? rng1.location:rng2.location;
    NSInteger top = (rng1.location+rng1.length > rng2.location+rng2.length)? rng1.location+rng1.length:rng2.location+rng2.length;
    return NSMakeRange(bottom, top-bottom);
}

+(NSRange)mergeRanges:(NSArray<NSValue *> *)rnges{
    if (rnges.count==0) {
        return NSMakeRange(NSNotFound, 0);
    }
    NSRange out = [rnges firstObject].rangeValue;
    for (NSInteger i=1; i<rnges.count; i++) {
        out = [CitationIterator mergeRanges:out and:[rnges objectAtIndex:i].rangeValue];
    }
    return out;
}

+(NSRange)transformRange:(NSRange)rng withinRange:(NSRange)outerRange{
    return NSMakeRange(rng.location-outerRange.location, rng.length);
}

-(BOOL)shouldEndIteration:(StringIterator *)it{
    NSRange rng = [self rangeOfPreviousDelimit];
    if (!rng.length) return FALSE;
    NSString* gapString = [self.source substringWithRange:[self rangeOfPreviousDelimit]];
    for (NSInteger i=0; i<gapString.length; i++) {
        unichar c = [gapString characterAtIndex:i];
        if ([[NSCharacterSet newlineCharacterSet]characterIsMember:c]) {
            return TRUE;
        }
    }
    if (self.currentWord.length) {
        unichar c = [self.currentWord characterAtIndex:0];
        if (c=='(' || c=='{' || c=='[') {
            return TRUE;
        }
    }
//    NSString* prev = [self peekPreviousWord];
//    if (prev.length && [prev characterAtIndex:prev.length-1]=='.') {
//        prev= [[prev stringByTrimmingCharactersInSet:[CitationIterator extraGrammar]]lowercaseString];
//        if ([prev isEqualToString:@"al"] || [prev isEqualToString:@"et.al"] || [prev isEqualToString:@"et-al"] || [prev isEqualToString:@"et-.al"]) {
//            return FALSE;
//        }else return TRUE;
//    }
    return FALSE;
}

+(NSCharacterSet*)extraGrammar{
    return [NSCharacterSet characterSetWithCharactersInString:@"\"'\\/{}()[],.;:`!?"];
}

+(NSCharacterSet*)numeralChars{
    return [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
}


@end


































