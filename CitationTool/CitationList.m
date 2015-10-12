//
//  Citations.m
//  CitationParser
//
//  Created by Thomas Gray on 13/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "CitationList.h"

@implementation CitationList
@synthesize citations;
@synthesize possibleCitations;

-(instancetype)init{
    self = [super init];
    if (!self)return self;
    citations = [[NSMutableArray alloc]init];
    possibleCitations = [[NSMutableArray alloc]init];
    return self;
}


-(BOOL)addWholeCitation:(Citation *)cit{
    for (int i =0; i<citations.count; i++) {
        Citation *c = [citations objectAtIndex:i];
        if ([c isEquivalent: cit]){
            //NSLog(@"Bib: repeated citation %@", cit.toString);
            [c.locations addObjectsFromArray:cit.locations];
            return TRUE;
        }
    }
    [citations addObject:cit];
    return TRUE;
}

-(BOOL)addPossibleCitation:(Citation *)cit{
    [possibleCitations addObject:cit];
    return TRUE;
}

-(void)printBib{
    NSLog(@"Printing Bibliography\n");
    for (int i =0; i<citations.count; i++) {
        Citation *cit = [citations objectAtIndex:i];
        NSLog(@"%@, %@; referenced at: ",  cit.authorsString, cit.yearString);
        NSArray *locations = cit.locations;
        for (int i=0; i<locations.count; i++){
            Location *l = [locations objectAtIndex:i];
        }
    }
    if (possibleCitations.count==0) return;
    NSLog(@"Citations I might have missed:\n");
    for(Citation *cit in possibleCitations){
        NSLog(@"\t%@ %@", cit.authorsString, cit.yearString);
    }
}

-(void)sortAlphabetically{
    [citations sortUsingSelector:@selector(compare:)];
    //[Comparator sortCitationArrayAlpabetically:citations];
}

-(NSInteger)referencesTotal{
    return citations.count;
}

-(NSInteger)citationsTotal{
    NSInteger out = 0;
    for (Citation *cit in citations){
        out+= cit.locations.count;
    }
    return out;
}

-(instancetype)copy{
    CitationList *out = [[CitationList alloc]init];
    for (Citation *cit in citations){
        [out.citations addObject:[cit copy]];
    }
    return out;
}


@end
