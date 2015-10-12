//
//  Parser.m
//  CitationParser
//
//  Created by Thomas Gray on 13/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "Parser.h"

@interface Parser(){
    long wordCount;
}

-(void)getCitationsPerPar;

-(NSString*)removeNonAlphaNumerics:(NSString*)in;

-(Year*)getDateWithMod:(NSString*)in;
-(NSString*)getSurround:(WordIterator*)it;
-(void)getSurroundForCitation:(Citation*)loc;



@end

@implementation Parser

@synthesize citations;
@synthesize earliestDate;
@synthesize latestDate;
@synthesize sourceString;


-(instancetype) init{
    self = [super init];
    if (!self) return self;
    
        latestDate = [[[NSCalendar currentCalendar]components:NSCalendarUnitYear fromDate:[NSDate date]]year];
        earliestDate = 1900;
    
    numerals = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    grammar = [NSCharacterSet characterSetWithCharactersInString:@"(),.;:[]`{}|\'\""];
    lcases = [NSCharacterSet lowercaseLetterCharacterSet];
    
    citAnalyser = [[CitationAnalyser alloc]init];
    return self;
}

-(void)loadFile:(NSString *)path{
    sourceString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //NSLog(@"paragraph # = %lu", (unsigned long)sourceParagraphs.count);
}
-(void) setSourceString:(NSString *)sstr{
    sourceString = sstr;
}


-(CitationList*)getCitations{
    citations  = [[CitationList alloc]init];
    wordCount = 0;
    
    WordIterator *it = [[WordIterator alloc]initWithParagraph:sourceString];
    NSString *word;
    while ((word=[it nextWord])) {
        wordCount++;
        
        Year *date = [self getDateWithMod:word];
        if (date){
            Citation* cit = [citAnalyser getCitation:it forDate:date];
            [self getSurroundForCitation:cit];
            
            if (cit.authors.count>0){
                [citations addWholeCitation:cit];
                cit.assured = TRUE;
            }else{
                [citations addPossibleCitation:cit];
                cit.assured = FALSE;
            }
        }
    }
    [citations sortAlphabetically];
    return citations;
}

-(void)getCitationsPerPar{
    WordIterator *it = [[WordIterator alloc]initWithParagraph:sourceString];
    NSString *word;
    while ((word=[it nextWord])) {
        wordCount++;
        
        Year *date = [self getDateWithMod:word];
        //NSLog(@"getCitationsPerPar: processing %@", word);
        if (date){
            //NSLog(@"Found a date: %ld", (long)date.year);
            Citation* cit = [citAnalyser getCitation:it forDate:date];
            Location *l = [cit.locations firstObject];
            l.surround = [self getSurround:it];
            //l.range = it.currentWordRange;
            
            //[cit addLocation:l];
            
            if (cit.authors.count>0){
                [citations addWholeCitation:cit];
                cit.assured = TRUE;
            }else{
                [citations addPossibleCitation:cit];
                cit.assured = FALSE;
            }
        }
    }
}

-(NSString*)getSurround:(WordIterator *)it{
    NSString * out;
    NSInteger i = it.position;
    NSInteger top = i+100>it.paragraph.length? it.paragraph.length:i+100;
    NSInteger bottom = i-150<0? 0:i-150;
    out = [it.paragraph substringWithRange:NSMakeRange(bottom, top-bottom)];
    if (top!=it.paragraph.length) {
        out = [out stringByAppendingString:@"..."];
    }
    if (bottom>0) {
        out = [NSString stringWithFormat:@"...%@", out];
    }
    return out;
}

-(void)getSurroundForCitation:(Citation *)cit{
    Location* loc = [cit.locations firstObject];
    NSString* citationString = [sourceString substringWithRange:loc.range];
    NSInteger top = loc.range.location+loc.range.length+100>sourceString.length? sourceString.length : loc.range.location+loc.range.length+100;
    NSInteger bottom = loc.range.location<100? 0 : loc.range.location-100;
    NSInteger addition = loc.range.location-bottom;
    [loc setSurround:[sourceString substringWithRange:NSMakeRange(bottom, top-bottom)]];
    for (NSInteger i=0; i<cit.authors.count; i++) {
        NSString* author = [cit.authors objectAtIndex:i];
        NSRange authInRange = [citationString rangeOfString:author];
        NSValue* rngVal = [NSValue valueWithRange:NSMakeRange(authInRange.location+addition, authInRange.length)];
        [loc.authorRangesInSurround addObject:rngVal];
    }
    
    NSRange yearInRange = [citationString rangeOfString:[cit yearString]];
    loc.yearRangeInSurround = NSMakeRange(yearInRange.location+addition, yearInRange.length);
}

-(BOOL)isDate:(NSString *)str{
    if ([self getDateWithMod:str]){
        return TRUE;
    }else return FALSE;
}

-(Year*)getDateWithMod:(NSString *)in{
    Year *out;
    in = [citAnalyser trimExtraneousGrammar:in];
    if (in.length<4 || in.length>5) return Nil;
    NSString* number = [in substringToIndex:4];
    for (int i=0;i<number.length;i++){
        unichar c = [number characterAtIndex:i];
        if (![citAnalyser.numerals characterIsMember:c]) return Nil;
    }
    NSInteger date = [number integerValue];
    if (date<earliestDate || date>latestDate)return Nil;
    
    out = [[Year alloc]init:date];
    if (in.length==4) return out;
    unichar c = [in characterAtIndex:4];
    if (![citAnalyser.lcases characterIsMember:c]) return Nil;
    //NSLog(@"getDateWithMod: modifer %c for date %ld", c, (long)date);
    out.modifier = c;
    return out;
}



-(NSString*)removeNonAlphaNumerics:(NSString *)in{
    NSCharacterSet *alphas = [NSCharacterSet alphanumericCharacterSet];
    return [Parser stringByIncludingCharactersInSet:alphas withString:in];
}


+(NSString*) stringByRemovingCharactersInSet:(NSCharacterSet *)set fromString:(NSString *)str{
    NSString *out = @"";
    for (int i =0; i<str.length; i++) {
        unichar c = [str characterAtIndex:i];
        if ([set characterIsMember:c]){
        }else{
            out = [out stringByAppendingFormat:@"%c",c];
        }
    }
    return out;
}

+(NSString*)stringByIncludingCharactersInSet:(NSCharacterSet *)set withString:(NSString *)str{
    NSString*out = @"";
    for (int i = 0; i<str.length; i++) {
        unichar c = [str characterAtIndex:i];
        if ([set characterIsMember:c]){
            out = [out stringByAppendingFormat:@"%c", c];
        }
    }
    return out;
}

#pragma mark Useful Static Methods

+(BOOL)string:(NSString *)string isEmptyOrExclusivelyCharacters:(NSCharacterSet *)charset{
    if (string.length==0)return true;
    for (int i = 0; i<string.length; i++) {
        unichar c = [string characterAtIndex:i];
        if (![charset characterIsMember:c]) return false;
    }
    return true;
}

+(NSString*)stringByTrimmingEmptySpace:(NSString *)str{
    NSCharacterSet* space = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [str stringByTrimmingCharactersInSet:space];
}

+(Year*)getYearFromString:(NSString *)str{
    NSCharacterSet* numerals = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    Year *out = [[Year alloc]init];
    int i=0;
    while (true) {
        unichar c = [str characterAtIndex:i];
        if (![numerals characterIsMember:c]) break;
        else if (i==str.length-1) { i++; break; }
        i++;
    }
    
    if (str.length>i+1) return nil;

    NSString* yearstring = [str substringToIndex:i];
    out.year = yearstring.integerValue;
    if (str.length>yearstring.length) out.modifier = [str characterAtIndex:i];
    return out;
}







-(void) test{
    
}
@end

