//
//  Citation.m
//  CitationParser
//
//  Created by Thomas Gray on 13/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "Citation.h"

@implementation Citation

@synthesize authors;
@synthesize year;
@synthesize locations;
@synthesize possibleReferences;
@synthesize reference;
@synthesize assured;

-(instancetype)initWithYear:(NSInteger)yr andModifier:(unichar)m{
    self= [super init];
    if (!self)return self;
    
    authors = [[NSMutableArray alloc]init];
    locations = [[NSMutableArray alloc]init];
    possibleReferences = [[NSMutableArray alloc]init];
    
    self.year = [[Year alloc]init:yr withMod:m];
    return self;
}

-(instancetype)initWithYear:(Year*)yr{
    self = [super init];
    if (self) {
        authors = [[NSMutableArray alloc]init];
        locations = [[NSMutableArray alloc]init];
        possibleReferences = [[NSMutableArray alloc]init];
        year = yr;
    }
    return self;
}
    

-(instancetype)initWithYear:(NSInteger)yr andModifier:(unichar)m andAuthors:(NSMutableArray *)auths{
    self= [super init];
    if (!self)return self;
    
    locations = [[NSMutableArray alloc]init];
    self.year = [[Year alloc]init:yr withMod:m];
    possibleReferences = [[NSMutableArray alloc]init];
    authors = auths;
    
    return self;
}

-(BOOL)isEquivalent:(Citation *)in{
    if (![in.year isEqualTo:self.year]){
        return FALSE;
    }
    if (in.authors.count!=self.authors.count) return FALSE;
    int authorC = (int)in.authors.count;
    BOOL checks[authorC];
    for (int i=0; i<authorC; i++) checks[i] = TRUE;
    
    for (int i=0; i<self.authors.count;i++){
        for(int j=0; j<self.authors.count;j++){
            if ([[self.authors objectAtIndex:i] isEqualTo:[in.authors objectAtIndex:j]] &&
                checks[j]){
                checks[j] = FALSE;
                break;
            }else if(j==self.authors.count-1) return FALSE;
        }
    }
    
    return TRUE;
}


-(void)addLocation:(Location *)loc{
    [locations addObject:loc];
}

-(NSString*)yearString{
    return self.year.toString;
}
-(NSString*)locString{
    return @"whatever";
}

-(NSString *)authorsStringWithFinalDelimiter:(NSString *)delimit{
    NSString* out = @"";
    for (int i = 0; i<authors.count;i++){
        NSString* author = [authors objectAtIndex:i];
        out = [out stringByAppendingFormat:@"%@", author];
        
        if (i==authors.count-1) break;
        else if (i==authors.count-2){
            if ([Citation isEtAl:[authors objectAtIndex:i+1]] || !delimit) {
                out = [out stringByAppendingString:@", "];
            }else{
                out = [out stringByAppendingString:[NSString stringWithFormat:@" %@ ", delimit]];
            }
        }else{
            out = [out stringByAppendingString:@", "];
        }
    }
    return out;
}

-(instancetype)copy{
    NSMutableArray* authorCopy = [[NSMutableArray alloc]initWithArray:self.authors copyItems:YES];
    Citation* out = [[Citation alloc]initWithYear:year.year andModifier:year.modifier andAuthors:authorCopy];
    NSMutableArray* locCopy = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i<locations.count; i++){
        Location* l = [locations objectAtIndex:i];
        [locCopy addObject:[l copy]];
    }
    NSMutableArray* possRefsCopy = [[NSMutableArray alloc]initWithCapacity:possibleReferences.count];
    for (NSInteger i=0; i<possibleReferences.count; i++){
        Reference* ref = [possibleReferences objectAtIndex:i];
        [possRefsCopy addObject:ref];
    }
    [out setPossibleReferences:possRefsCopy];
    [out setReference:reference];
    [out setLocations:locCopy];
    return out;
}

-(NSString*) toString{
    NSString*out = [self authorsStringWithFinalDelimiter:@"and"];
    out = [out stringByAppendingFormat:@" (%@)", [self yearString]];
    return out;
}

-(NSComparisonResult)compare:(id)cit{
    if ([cit isKindOfClass:[Citation class]]) {}
    else return NSOrderedSame;
    Citation * other = (Citation*)cit;
    
    long min = self.authors.count<= other.authors.count? self.authors.count: other.authors.count;
    for (int i=0; i<min; i++) {
        NSComparisonResult out;
        NSString *athis = [self.authors objectAtIndex:i];
        NSString* aother = [other.authors objectAtIndex:i];
        out = [athis compare:aother];
        if (out!=NSOrderedSame) {
            return out;
        }
    }
    if (self.authors.count < other.authors.count) return NSOrderedAscending;
    else if (self.authors.count > other.authors.count) return NSOrderedDescending;
    
    return [self.year compare:other.year];
}

-(void)findPossibleReferences:(NSArray<Reference*> *)refs{
    if (!possibleReferences) possibleReferences = [[NSMutableArray alloc]init];
    [possibleReferences removeAllObjects];
    for (NSInteger i=0; i<refs.count; i++){
        Reference* ref = [refs objectAtIndex:i];
        if ([ref matchesCitation:self]){
            [possibleReferences addObject:ref];
        }
    }
    for (NSInteger i=0; i<possibleReferences.count; i++){
        Reference* ref = [possibleReferences objectAtIndex:i];
        if ([ref isEqualToReference:reference]) return;
    }
    reference=nil;
}

+(BOOL)isEtAl:(NSString *)str{
    str = [[str lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
    return [str isEqualToString:@"et al"] || [str isEqualToString:@"etal"] || [str isEqualToString:@"et-al"] || [str isEqualToString:@"et. al"] || [str isEqualToString:@"et.-al"] || [str isEqualToString:@"et.al"];
}


#pragma mark Range Management

+(void)adjustLocationsForCitations:(NSArray<Citation *> *)citations atIndex:(NSInteger)i byOffset:(NSInteger)off inclusively:(BOOL)inc{
    for (NSInteger k=0; k<citations.count; k++){
        Citation* cit = [citations objectAtIndex:k];
        for (NSInteger l=0; l<cit.locations.count ; l++) {
            Location* loc = [cit.locations objectAtIndex:l];
            NSMutableArray<NSValue*>* newRanges = [[NSMutableArray alloc]initWithCapacity:loc.authorRangesInSource.count];
            for (NSInteger i=0; i<loc.authorRangesInSource.count; i++) {
                NSRange rng = [loc.authorRangesInSource objectAtIndex:i].rangeValue;
                if (rng.location>= inc? i:i+1) {
                    rng = NSMakeRange(rng.location+off, rng.length);
                }
                [newRanges addObject:[NSValue valueWithRange:rng]];
            }
            [loc setAuthorRangesInSource:newRanges];
            if ([loc yearRangeInSource].location >= inc? i:i+1) {
                [loc setYearRangeInSource:NSMakeRange(loc.yearRangeInSource.location+off, loc.yearRangeInSource.length)];
            }
        }
    }
}











@end
