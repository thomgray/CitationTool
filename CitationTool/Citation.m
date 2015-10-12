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
-(NSString*)authorsString{
    NSString* out = @"";
    for (int i = 0; i<authors.count;i++){
        NSString* author = [authors objectAtIndex:i];
        out = [out stringByAppendingFormat:@"%@", author];
        
        if (i==authors.count-1) break;
        out = [out stringByAppendingString:@", "];
    }
    return out;
}

-(instancetype)copy{
    NSMutableArray* authorCopy = [[NSMutableArray alloc]initWithArray:self.authors copyItems:YES];
    Citation* out = [[Citation alloc]initWithYear:year.year andModifier:year.modifier andAuthors:authorCopy];
    NSMutableArray* locCopy = [[NSMutableArray alloc]init];
    for (Location* l in self.locations){
        [locCopy addObject:[l copy]];
    }
    NSMutableArray* possRefsCopy = [[NSMutableArray alloc]initWithCapacity:possibleReferences.count];
    for (Reference* ref in possibleReferences){
        [possRefsCopy addObject:ref];
    }
    [out setPossibleReferences:possRefsCopy];
    [out setReference:reference];
    [out setLocations:locCopy];
    return out;
}

-(NSString*) toString{
    NSString*out = [self authorsString];
    out = [out stringByAppendingFormat:@" %@", [self yearString]];
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
    for (Reference* ref in refs){
        if ([ref matchesCitation:self]){
            [possibleReferences addObject:ref];
        }
    }
    for (Reference* ref in possibleReferences){
        if ([ref isEqualToReference:reference]) return;
    }
    reference=nil;
}


@end
