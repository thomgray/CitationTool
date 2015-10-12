//
//  CitationAnalyser.m
//  CitationTool
//
//  Created by Thomas Gray on 15/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "CitationAnalyser.h"

@interface CitationAnalyser()

-(void)loadCommonDictionary;
-(void) loadNamePrefixes;
-(NSString*)trimWord:(NSString*)wrd;

-(BOOL)isEtAl:(WordIterator*)wit;
-(BOOL)isProbableName:(NSString*)in;
-(BOOL)isDate:(NSString*)str;
-(BOOL)isRightwardDelimiter:(unichar)in;
-(BOOL)isLeftwardDelimiter:(unichar) in;

@end

@implementation CitationAnalyser

@synthesize lcases;
@synthesize ucases;
@synthesize numerals;
@synthesize permissibleGrammar;

-(instancetype)init{
    self= [super init];
    if (self) {
        //this isn't realy needed I don't think
        NSString* dicpath = [[NSBundle mainBundle]resourcePath];
        dicpath = [dicpath stringByAppendingString:@"/en_GB-large.txt"];
        NSString* wholedic = [NSString stringWithContentsOfFile:dicpath encoding:NSUTF8StringEncoding error:nil];
        dictionary = [wholedic componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSMutableArray* dictemp = [[NSMutableArray alloc]init];
        for (NSString* entry in dictionary)
            if (entry.length>0) [dictemp addObject:entry];
        dictionary = [NSArray arrayWithArray:dictemp];
        
        
        [self loadCommonDictionary];
        [self loadNamePrefixes];
        lcases = [NSCharacterSet lowercaseLetterCharacterSet];
        ucases = [NSCharacterSet uppercaseLetterCharacterSet];
        numerals = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        permissibleGrammar = [CitationAnalyser grammarCharacters];
        NSString* path = [NSString stringWithFormat:@"%@/nonNames.txt",[[NSBundle mainBundle]resourcePath]];
        NSArray* temp = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        nonNames = [NSMutableArray arrayWithArray:temp];
        
    }
    return self;
}

-(Citation*)getCitation:(WordIterator *)it forDate:(Year *)yr{
    WordIterator *wit = [[WordIterator alloc]initByTakingOver:it];
    Citation* citation = [[Citation alloc]initWithYear:yr];
    NSMutableArray* authors = [[NSMutableArray alloc]init];
    BOOL started = FALSE;
    NSInteger begin = it.currentWordRange.location;
    while ([wit previousWord]) {
        if ([self isEtAl:wit]){
            [authors addObject:ET_AL];
            started = TRUE;
            begin = wit.currentWordRange.location;
            continue;
        }
        
        NSString* rawword = wit.currentWord;
        NSString* trimword = [self trimExtraneousGrammar:rawword];
        
        if ([self isProbableName:trimword]){
            if([self isRightwardDelimiter:[rawword characterAtIndex:rawword.length-1]]) break; ///worth keeping in?
            [authors addObject:trimword];
            started = TRUE;
            begin = wit.currentWordRange.location;
            if ([self isLeftwardDelimiter:[rawword characterAtIndex:0]]) break;
        }else if([trimword isEqualTo:@"&"] ||
                 [trimword isEqualTo:@"and"] ||
                 [trimword isEqualTo:@"And"]) {
            begin = wit.currentWordRange.location;
            continue;
        }else if([self isDate:trimword] && !started){
            begin = wit.currentWordRange.location;
            continue;
        }else break;
    }
    
    
    Location* loc = [[Location alloc]initWithRange:NSMakeRange(begin, it.currentWordRange.location+it.currentWordRange.length-begin)];
    //loc.range = NSMakeRange(begin, it.currentWordRange.location+it.currentWordRange.length-begin);
    
    authors = [self fixNamesArray:authors];
    citation.authors = authors;
    [citation.locations addObject:loc];
    return citation;
}

/*
 must be trimmed for grammar
 */
-(BOOL) isProbableName:(NSString*)in{
    if (![ucases characterIsMember:[in characterAtIndex:0]]) return FALSE;
    else if ([nonNames containsObject:in]) return false;
    else if ([namePrefixes containsObject:in]) return TRUE;
    for (int i=1;i<in.length;i++){
        unichar c = [in characterAtIndex:i];
        if ([lcases characterIsMember:c] ||
            [ucases characterIsMember:c] ||
            c=='-') ///implements other permissible characters here
        {
            
        }else return FALSE;
    }
    return TRUE;
}

/*
 must be trimmed for grammar
 */
-(BOOL) isDate:(NSString *)str{
    if (str.length<4 || str.length>5) return FALSE;
    for (int i=0; i<4; i++) {
        if(![numerals characterIsMember:[str characterAtIndex:i]]) return FALSE;
    }
    if (str.length==4)return TRUE;
    return ([lcases characterIsMember:[str characterAtIndex:4]]);
}

-(BOOL) isEtAl:(WordIterator *)wit{
    NSString * str = wit.currentWord;
    str = [self trimExtraneousGrammar:str];
    str = [str lowercaseString];
    if ([str isEqualTo:@"al"]){
        NSString* prev= [wit peekPreviousWord];
        prev = [self trimExtraneousGrammar:prev];
        prev = [prev lowercaseString];
        if ([prev isEqualTo:@"et"]) {
            [wit previousWord];
            return TRUE;
        }else return FALSE;
    }else if ([str isEqualTo:@"etal"] || [str isEqualTo:@"et-al"]){
        return TRUE;
    }else return FALSE;
}

-(NSString*)trimWord:(NSString *)rawname{
    NSString* cleanName;
    cleanName = [self trimExtraneousGrammar:rawname];
    for (int i=0; i<cleanName.length;i++){
        unichar c = [cleanName characterAtIndex:i];
        if ([ucases characterIsMember:c]||
            [lcases characterIsMember:c] ||
            c=='-'){ ///implements other admissible characters here
            
        }else return Nil;
    }
    return cleanName;
}


-(NSMutableArray*)fixNamesArray:(NSMutableArray *)in{
    NSMutableArray* out= [[NSMutableArray alloc]init];
    for (int i = (int)in.count-1; i>=0; i--){
        NSString* name = [in objectAtIndex:i];
        if ([namePrefixes containsObject:name] && i>0){
            i--;
            NSString* nextbit = [in objectAtIndex:i];
            NSString* propername = [name stringByAppendingFormat:@" %@", nextbit];
            [out addObject:propername];
        }else{
            [out addObject:name];
        }
    }
    return out;
}

-(void)loadCommonDictionary{
    NSMutableArray *tempDic = [[NSMutableArray alloc]init];
    for (NSString *s in dictionary){
        BOOL isLowerCase;
        unichar c = [s characterAtIndex:0];
        isLowerCase = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:c];
        if (isLowerCase){
            [tempDic addObject:s];
        }
    }
    commonDictionary = [NSArray arrayWithArray:tempDic];
}

-(NSString*)restrictToAlphaNumerics:(NSString*) in{
    NSCharacterSet *alphanumericCharacterSet;
    NSString *out = @"";
    for (int i=0;i<in.length;i++){
        unichar c = [in characterAtIndex:i];
        if ([alphanumericCharacterSet characterIsMember:c]){
            out = [out stringByAppendingFormat:@"%c", c];
        }
    }
    return out;
}

-(void) loadNamePrefixes{
    NSString* path = [[NSBundle mainBundle]bundlePath];
    path = [path stringByAppendingString:@"/Contents/Resources/prefixes.txt"];
    
    NSString *prefs= [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *tempar = [prefs componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *tempar2 = [[NSMutableArray alloc]init];
    for (NSString* s in tempar) if (![s isEqualTo:@""]) [tempar2 addObject:s];
    tempar = [[NSArray alloc]initWithArray:tempar2];
    for (NSString* s in tempar){
        [tempar2 addObject:[s lowercaseString]];
    }
    namePrefixes = [[NSArray alloc]initWithArray:tempar2];
}

+(NSCharacterSet*)grammarCharacters{
    return [NSCharacterSet characterSetWithCharactersInString:@"()[]{}\\,.:;-/\'\"`"];
}

-(NSString*)trimExtraneousGrammar:(NSString*)in{
    return [in stringByTrimmingCharactersInSet:permissibleGrammar];
}

-(BOOL) isRightwardDelimiter:(unichar)in{
    return (in==')' || in=='.');
}
-(BOOL) isLeftwardDelimiter:(unichar)in{
    return (in=='(');
}


+(BOOL)isBlankString:(NSString *)in{
    for (int i=0; i<in.length;i++){
        unichar c = [in characterAtIndex:i];
        if (c==' ' || c=='\t'){
        }else return FALSE;
    }
    return TRUE;
}

@end
