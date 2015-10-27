//
//  Citation.h
//  CitationParser
//
//  Created by Thomas Gray on 13/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parser.h"
#import "Year.h"
#import "Location.h"
#import "Reference.h"

@class Reference;

#define ET_AL @"et al."

@interface Citation : NSObject

@property (readwrite) Year* year;
@property (readwrite) NSMutableArray* authors;
@property (readwrite) NSMutableArray* locations;
@property (readwrite) BOOL assured;
@property (readwrite) NSMutableArray* possibleReferences;
@property (readwrite) Reference* reference;

-(instancetype) initWithYear: (NSInteger) year
                 andModifier:(unichar)m;

-(instancetype) initWithYear:(NSInteger)year
                 andModifier:(unichar)m
                  andAuthors:(NSMutableArray*)auths;

-(instancetype)initWithYear:(Year*)year;

-(BOOL)isEquivalent:(Citation*)in;

-(void)addLocation:(Location*)loc;
-(void)findPossibleReferences:(NSArray<Reference*>*)refs;

-(NSComparisonResult)compare:(id)cit;

-(NSString*)yearString;
-(NSString*)authorsStringWithFinalDelimiter:(NSString*)delimit;

-(NSString*)locString;
-(NSString*)toString;

+(BOOL)isEtAl:(NSString*)str;

+(void)adjustLocationsForCitations:(NSArray<Citation*>*)citations atIndex:(NSInteger)i byOffset:(NSInteger)off inclusively:(BOOL)inc;

@end
