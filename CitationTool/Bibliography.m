//
//  Bibliography.m
//  CitationTool3
//
//  Created by Thomas Gray on 20/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "Bibliography.h"

@interface Bibliography()


@end

@implementation Bibliography

@synthesize references;
@synthesize name;


-(instancetype)initWithFile:(NSString *)path{
    self= [super init];
    if (self) {
        name = [path lastPathComponent];
        references = [Reference getReferencesFromFile:path];
    }
    return self;
}

+(instancetype)mergeBibliographies:(NSArray *)bibs{
    Bibliography* out = [[Bibliography alloc]init];
    for (Bibliography* bib in bibs){
        [out.references addObjectsFromArray:bib.references];
    }
    NSMutableArray* newRefs = [[NSMutableArray alloc]init];
    for (NSInteger i =0; i<out.references.count; i++) {
        for (NSInteger j=i-1; j>=0; j--) {
            if ([[out.references objectAtIndex:i]isEqualToReference:[out.references objectAtIndex:j]]){
                goto _here;
            }
        }
        [newRefs addObject:[out.references objectAtIndex:i]];
    _here:
        continue;
    }
    out.references = newRefs;
    return out;
}

+(NSMutableArray<Reference*>*)allReferences:(NSArray<Bibliography*>*)bibs{
    NSMutableArray<Reference*>* out = [[NSMutableArray alloc]init];
    for (Bibliography* bib in bibs){
        [out addObjectsFromArray:bib.references];
    }
    return out;
}

@end
