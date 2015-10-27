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
@synthesize path;


-(instancetype)initWithFile:(NSString *)pth{
    self= [super init];
    if (self) {
        path=pth;
        name = [[pth lastPathComponent]stringByDeletingPathExtension];
        references = [Reference getReferencesFromFile:pth];
        [self sortReferencesByKeys:@[AUTHOR, YEAR]];
    }
    return self;
}

+(instancetype)mergeBibliographies:(NSArray *)bibs{
    Bibliography* out = [[Bibliography alloc]init];
    for (NSInteger i=0; i<bibs.count; i++) {
        Bibliography*  bib = [bibs objectAtIndex:i];
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

-(void)sortReferencesByKeys:(NSArray<NSString *> *)keys{
    [Reference sortArray:references withFields:keys];
}

+(NSMutableArray<Reference*>*)allReferences:(NSArray<Bibliography*>*)bibs{
    NSMutableArray<Reference*>* out = [[NSMutableArray alloc]init];
    for (NSInteger j=0; j<bibs.count;j++){
        Bibliography* bib = [bibs objectAtIndex:j];
        for (NSInteger k=0; k<bib.references.count;k++) {
            Reference* ref = [bib.references objectAtIndex:k];
            for (NSInteger i=0; i<out.count; i++) {
                Reference* refInOut = [out objectAtIndex:i];
                if ([ref isEqualToReference:refInOut]) {
                    NSArray* keys = [ref.fields allKeys];
                    for (NSInteger l=0; l<keys.count;l++){
                        NSString* key = [keys objectAtIndex:l];
                        NSString * refInOutVal = [refInOut.fields objectForKey:key];
                        NSString* refVal = [ref.fields objectForKey:key];
                        if (refInOutVal.length==0 && refVal.length>0) {
                            [refInOut.fields setObject:refVal forKey:key];
                        }
                    }
                    goto nextReference;
                }
            }
            [out addObject:ref];
        nextReference: continue;
        }
    }
    return out;
}

+(void)addReferencesFrom:(Bibliography *)bib toReferenceArray:(NSMutableArray<Reference *> *)refs{
    for (NSInteger j=0; j<bib.references.count;j++) {
        Reference* ref = [bib.references objectAtIndex:j];
        for (NSInteger i=0; i<refs.count; i++) {
            Reference* refInOut = [refs objectAtIndex:i];
            if ([ref isEqualToReference:refInOut]) {
                NSArray* keys = [ref.fields allKeys];
                for (NSInteger k=0; k<keys.count;k++){
                    NSString* key = [keys objectAtIndex:k];
                    NSString * refInOutVal = [refInOut.fields objectForKey:key];
                    NSString* refVal = [ref.fields objectForKey:key];
                    if (refInOutVal.length==0 && refVal.length>0) {
                        [refInOut.fields setObject:refVal forKey:key];
                    }
                }
                goto nextReference;
            }
        }
        [refs addObject:ref];
    nextReference: continue;
    }
}

-(void)saveToBibFile{
    NSMutableString* saveStr = [[NSMutableString alloc]init];
    for (NSInteger i=0; i<references.count; i++) {
        Reference* ref = [references objectAtIndex:i];
        [saveStr appendFormat:@"%@\n", [ref getTexString]];
    }
    [saveStr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}








@end
