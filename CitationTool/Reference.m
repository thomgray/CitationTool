//
//  Reference.m
//  CitationTool3
//
//  Created by Thomas Gray on 20/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "Reference.h"
#import "Parser.h"


@interface Reference()

-(NSMutableArray*)getRawFieldArray:(NSString*)str;
-(NSMutableDictionary*)getFieldDictionary:(NSMutableArray*)array;
-(void)parseForFields:(NSString*) str;
-(NSMutableArray*)makeNameArray:(NSString*)str;

@end

@implementation Reference

-(instancetype)init{
    self = [super init];
    if (self) {
        emptyChars = [NSMutableCharacterSet newlineCharacterSet];
        [emptyChars  addCharactersInString:@" \t"];
        braceChars = [NSCharacterSet characterSetWithCharactersInString:@"{}"];
    }
    return self;
}

-(instancetype)initWithBibEntry:(NSString*)bibString{
    self = [self init];
    if (self) {
        fields = [[NSMutableDictionary alloc]init];
        [self getDataFromBib:bibString];
    }
    return self;
}

@synthesize key;
@synthesize type;
@synthesize fields;

@synthesize editorArray;
@synthesize authorArray;
@synthesize yearModifier;
@synthesize yearInt;



-(void)getDataFromBib:(NSString *)bibString {
    NSInteger i;
    for (i =0; TRUE; i++) {
        unichar c = [bibString characterAtIndex:i];
        if (c=='{') {
            break;
        }
    }
    ///i== index of first '{'
    
    type = [[bibString substringToIndex:i] stringByTrimmingCharactersInSet:emptyChars];
    type = [type lowercaseString];
    int lr=1;
    i++;
    NSInteger j;
    for (j=i; j<bibString.length; j++) {
        unichar c = [bibString characterAtIndex:j];
        if (c=='{') lr++;
        else if (c=='}') lr--;
        
        if (lr==0)break;
        else if (j==bibString.length-1)@throw [NSException exceptionWithName:@"Parse Exception" reason:@"No final brace" userInfo:nil];
    }
    NSString* theRestOfIt = [bibString substringWithRange:NSMakeRange(i, j-i)];
    [self parseForFields:theRestOfIt];
}

-(void) parseForFields:(NSString *)str{
    NSMutableArray* rawFields = [self getRawFieldArray:str];
    if (rawFields.count>0) {
        NSString* possKey = rawFields[0];
        if (![possKey containsString:@"="]) {
            key = possKey;
            [rawFields removeObject:possKey];
        }
    }
    
    fields = [self getFieldDictionary:rawFields];
    ///Initialize the custom properties:
    
    editorArray = [self makeNameArray:[fields valueForKey:EDITOR]];
    authorArray = [self makeNameArray:[fields valueForKey:AUTHOR]];
    if ([fields valueForKey:YEAR]) yearInt = [[fields valueForKey:YEAR] integerValue];
}

-(NSMutableArray*) getRawFieldArray:(NSString *)str{
    ///these are separated by commas, ignoring cases inside braces
    NSMutableArray* out = [[NSMutableArray alloc]init];
    int  lr=0;
    NSInteger m=0;
    for (NSInteger i =0; i<str.length; i++) {
        unichar c = [str characterAtIndex:i];
        if (c=='{') lr++;
        else if (c=='}') lr--;
        
        if (c==',' && lr==0){
            NSString* substring = [str substringWithRange:NSMakeRange(m, i-m)];
            substring = [substring stringByTrimmingCharactersInSet:emptyChars];
            [out addObject:substring];
            m=i+1;
        }else if (i==str.length-1){
            NSString* substring = [str substringFromIndex:m];
            substring = [substring stringByTrimmingCharactersInSet:emptyChars];
            [out addObject:substring];
        }
    }
    return out;
}

-(NSMutableDictionary*)getFieldDictionary:(NSMutableArray *)array{
    NSMutableDictionary *out = [[NSMutableDictionary alloc]init];
    NSArray* establishedFields = [Reference getEstablishedFields];
    for (NSString* field in establishedFields){
        [out setObject:@"" forKey:field];
    }
    for (NSString* field in array){
        if (![field containsString:@"="]) continue;
        int i;
        for (i=0;i<field.length;i++)    if ([field characterAtIndex:i]=='=') break;
        NSString* fieldKey = [[field substringToIndex:i] stringByTrimmingCharactersInSet:emptyChars];
        fieldKey = [fieldKey lowercaseString];
        NSString* fieldVal = [[field substringFromIndex:i+1]stringByTrimmingCharactersInSet:emptyChars];
        fieldVal = [fieldVal substringWithRange:NSMakeRange(1, fieldVal.length-2)]; //to remove outside braces
        
        @try{
            fieldVal = [LaTeXString translateString:fieldVal].string;
        }@catch (NSException* e){}
    
        [out setObject:fieldVal forKey:fieldKey];
    }
    return out;
}


+(NSInteger)getIndexOfFirst:(unichar)c inString:(NSString *)str{
    for (NSUInteger i =0; i<str.length; i++) {
        unichar d= [str characterAtIndex:i];
        if (c==d) {
            return i;
        }
    }
    return -1;
}



-(NSMutableArray*)makeNameArray:(NSString*)str{ //needs to account for other formats: e.g. `Hilary Putnam and others'
    if (!str) return nil;
    NSCharacterSet* empty = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSArray* names1 = [str componentsSeparatedByString:@" and "];
    NSMutableArray * names2 = [[NSMutableArray alloc]init];
    NSMutableArray * out = [[NSMutableArray alloc]init];
    
    for (int i=0; i<names1.count;i++) {
        NSString* name = [names1 objectAtIndex:i];
        name = [name stringByTrimmingCharactersInSet:empty];
        if (name.length>0) [names2 addObject:name];
    }
    
    for (NSString * name in names2){
//        Name *n = [self getNameFromString:name];
//        [out addObject:n];
        Name *finalName = [Name getNameFromString:name];
        [out addObject:finalName];
    }
    return out;
}


-(BOOL) matchesCitation:(Citation *)cite{
    if (cite.authors.count > authorArray.count) return false;
    if (yearInt != cite.year.year) return false;
    for (int i=0; i<cite.authors.count; i++) {
        NSString* inSurname = [[cite.authors objectAtIndex:i]lowercaseString];
        Name* thisName = [authorArray objectAtIndex:i];
        NSString* thisSurname = [thisName.surname lowercaseString];
        if ((authorArray.count>i+1) && [inSurname isEqualToString:ET_AL]) break;
        else if (![thisSurname isEqualToString:inSurname]) return FALSE;
    }
    //NSLog(@"Found a match: %@ ---matching with----- %@", [self.fields valueForKey:AUTHOR], [cite authorsString]);
    return true;
}

-(NSString*)toStringTypeTitle{
    NSString* out = [NSString stringWithFormat:@"(%@) %@", [type capitalizedString], [fields valueForKey:TITLE]];
    return out;
}


# pragma mark Handy Static Methods

+(NSArray *)getEntryTypes{
    return [[NSArray alloc]initWithObjects:@"article", @"book", @"booklet", @"conference", @"inbook", @"incollection", @"inproceedings", @"manual", @"masterthesis", @"misc", @"phdthesis", @"proceedings", @"techreport", @"unpublished", nil];
}

+(NSArray*)getEstablishedFields{
    return [[NSArray alloc]initWithObjects:AUTHOR,ADDRESS,ANNOTE,BOOKTITLE,CHAPTER,CROSSREF,EDITION,EDITOR, HOWPUBLISHED, INSTITUTION, JOURNAL, MONTH,NOTE,NUMBER, ORGANIZATION, PAGES,PUBLISHER,SCHOOL, SERIES,TITLE, VOLUME, YEAR, nil];
}

+(NSArray*)articleFields{
    return [[NSArray alloc]initWithObjects:AUTHOR, TITLE, JOURNAL, YEAR, VOLUME, NUMBER, PAGES, MONTH, nil];
}
+(NSArray*)bookFields{
    return [[NSArray alloc]initWithObjects:TITLE, PUBLISHER, YEAR, AUTHOR, EDITOR, VOLUME, NUMBER, SERIES, ADDRESS, EDITION, MONTH, nil];
}
+(NSArray*)bookletFields{
    return [[NSArray alloc]initWithObjects:TITLE, AUTHOR, HOWPUBLISHED, ADDRESS, MONTH, YEAR, nil];
}
+(NSArray*)conferenceFields{
    return [[NSArray alloc]initWithObjects:AUTHOR, TITLE, BOOKTITLE, YEAR, EDITOR, VOLUME, PAGES, NUMBER, ORGANIZATION, SERIES, PUBLISHER, ADDRESS,MONTH, nil];
}
+(NSArray*)inbookFields{
    return [[NSArray alloc]initWithObjects:TITLE, PUBLISHER, YEAR, AUTHOR, EDITOR, CHAPTER, NUMBER, VOLUME, SERIES, MONTH, ADDRESS, EDITION, PAGES, nil];
}
+(NSArray*)incollectionFields{
    return [[NSArray alloc]initWithObjects:TITLE, PUBLISHER, YEAR, AUTHOR, EDITOR, VOLUME, NUMBER, SERIES, ADDRESS, EDITION, MONTH, nil];
}
+(NSArray*)inproceedingsFields{
    return [[NSArray alloc]initWithObjects:AUTHOR, TITLE, BOOKTITLE, YEAR, EDITOR, VOLUME, PAGES, NUMBER,ORGANIZATION, SERIES, PUBLISHER, ADDRESS, MONTH, nil];
}
+(NSArray*)manualFields{
    return [[NSArray alloc]initWithObjects:TITLE, AUTHOR, ORGANIZATION, ADDRESS, EDITION, MONTH, YEAR, nil];
}
+(NSArray*)masterthesisFields{
    return [[NSArray alloc]initWithObjects:AUTHOR, TITLE, SCHOOL, YEAR, ADDRESS, MONTH, nil];
}
+(NSArray*)miscFields{
    return [[NSArray alloc]initWithObjects:TITLE, HOWPUBLISHED, AUTHOR, MONTH, YEAR, nil];
}
+(NSArray*)phdthesisFields{
    return [[NSArray alloc]initWithObjects:AUTHOR, TITLE, SCHOOL, YEAR, ADDRESS, MONTH, nil];
}
+(NSArray*)proceedingsFields{
    return [[NSArray alloc]initWithObjects:TITLE, YEAR, EDITOR, NUMBER, PUBLISHER, ORGANIZATION, ADDRESS, MONTH, VOLUME, nil];
}
+(NSArray*)techreportFields{
    return [[NSArray alloc]initWithObjects:AUTHOR, TITLE, INSTITUTION, YEAR, NUMBER, ADDRESS, MONTH, nil];
}
+(NSArray*)unpublishedFields{
    return [[NSArray alloc]initWithObjects:AUTHOR, NOTE, TITLE, MONTH, YEAR, nil];
}
+(NSArray*)getCorrespondingPrincipleFields:(NSString *)type{
    if ([type isEqualToString:@"article"]) {
        return [Reference articleFields];
    }else if ([type isEqualToString:@"book"]){
        return [Reference bookFields];
    }else if ([type isEqualToString:@"booklet"]){
        return [Reference bookletFields];
    }else if ([type isEqualToString:@"conference"]){
        return [Reference conferenceFields];
    }else if ([type isEqualToString:@"inbook"]){
        return [Reference inbookFields];
    }else if ([type isEqualToString:@"incollection"]){
        return [Reference incollectionFields];
    }else if ([type isEqualToString:@"inproceedings"]){
        return [Reference inproceedingsFields];
    }else if ([type isEqualToString:@"manual"]){
        return [Reference manualFields];
    }else if ([type isEqualToString:@"masterthesis"]){
        return [Reference masterthesisFields];
    }else if ([type isEqualToString:@"misc"]){
        return [Reference miscFields];
    }else if ([type isEqualToString:@"phdthesis"]){
        return [Reference phdthesisFields];
    }else if ([type isEqualToString:@"proceedings"]){
        return [Reference proceedingsFields];
    }else if ([type isEqualToString:@"techreport"]){
        return [Reference techreportFields];
    }else if ([type isEqualToString:@"unpublished"]){
        return [Reference unpublishedFields];
    }else return [Reference getEstablishedFields];
}


+(NSMutableArray*)makeArrayOfNames:(NSString *)names{
    NSArray * ar1 = [names componentsSeparatedByString:@" and "];
    NSMutableArray * ar2 = [[NSMutableArray alloc]init];
    NSMutableArray * out = [[NSMutableArray alloc]init];

    for (NSString* name in ar1){
        int rangeStart, rangeLength=0;
        NSString* trimmedName;
        for (int i=0; i<name.length; i++) {
            unichar c = [name characterAtIndex:i];
            if (c==' ' || c=='\t' || c=='\n') continue;
            else if (i==name.length-1) return nil;
            else{
                rangeStart = i; break;
            }
        }
        for (int i=rangeStart; i<name.length; i++) {
            rangeLength++;
        }
        trimmedName = [name substringWithRange:NSMakeRange(rangeStart,rangeLength)];
        [ar2 addObject:trimmedName];
    }
    return out;
}


+(NSMutableArray*)getReferencesFromFile:(NSString *)path{
    NSString* longString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray* refStrings = [Reference getReferenceStringsFromWhole:longString];
    NSMutableArray* references = [[NSMutableArray alloc]initWithCapacity:refStrings.count];
    for (NSString* refString in refStrings){
        [references addObject:[[Reference alloc]initWithBibEntry:refString]];
    }
    return references;
}

+(NSMutableArray*)getReferenceStringsFromWhole:(NSString*)wholeString{
    NSInteger i;
    NSArray* keys = [Reference getEntryTypes];
    NSCharacterSet * emptychars = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSMutableArray* stringReferences = [[NSMutableArray alloc]init];
    
    for (i=0; TRUE; i++) {
        if (i==wholeString.length){
            goto break_loop;
        }
        unichar c = [wholeString characterAtIndex:i];
        if (c=='@') {
            for (NSInteger j=i+1; TRUE; j++) {
                if (j==wholeString.length){
                    goto break_loop;
                }
                unichar d = [wholeString characterAtIndex:j];
                if (d=='@') {
                    i=j-1;
                    goto end_of_loop;
                }else if (d=='{'){
                    NSString *key = [wholeString substringWithRange:NSMakeRange(i+1, j-i-1)];
                    key = [key stringByTrimmingCharactersInSet:emptychars];
                    if ([keys containsObject:key]) {
                        int lr=1;
                        j++;
                        while (TRUE) {
                            if (j==wholeString.length) {
                                goto end_of_loop;
                            }
                            if([wholeString characterAtIndex:j]=='{') lr++;
                            else if ([wholeString characterAtIndex:j]=='}') lr--;
                            
                            if (lr==0) { //we have what we want!
                                NSString* stringref = [wholeString substringWithRange:NSMakeRange(i+1, j-i)];
                                [stringReferences addObject:stringref];
                                i=j;
                                goto end_of_loop;
                            }
                            j++;
                        }
                    }else{
                        i=j;
                        goto end_of_loop;
                    }
                }
                
            }
        }
        end_of_loop: continue;
    }
break_loop:
    
    return stringReferences;
}


-(BOOL)isEqualToReference:(Reference *)ref{
    if (ref.authorArray.count!=self.authorArray.count) return FALSE;
    if (ref.yearInt!=self.yearInt) return FALSE;
    if (![ref.type isEqualToString: self.type]) return FALSE;

    
    NSString* title1 = [self.fields valueForKey:TITLE];
    NSString* title2 = [ref.fields valueForKey:TITLE];
    
    if (title1 && title2 && ![title1 isEqualToString:title2]) return FALSE;
    
    for (NSInteger i=0; i<self.authorArray.count; i++) {
        Name* n1 = [self.authorArray objectAtIndex:i];
        Name* n2 = [ref.authorArray objectAtIndex:i];
        if (![n1 isEqualToName:n2]) return FALSE;
    }
    return TRUE;
}







@end
