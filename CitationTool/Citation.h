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

@interface Citation : NSObject

#define ET_AL @"et al."

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
-(NSString*)authorsString;
-(NSString*)locString;
-(NSString*)toString;


@end
