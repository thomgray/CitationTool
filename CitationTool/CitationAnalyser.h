//
//  CitationAnalyser.h
//  CitationTool
//
//  Created by Thomas Gray on 15/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Citation.h"
#import "Year.h"

@class Citation;

@interface CitationAnalyser : NSObject{
    NSArray *dictionary;
    NSArray *commonDictionary;
    NSArray *namePrefixes;
    NSMutableArray* nonNames;
}


@property (readonly) NSCharacterSet *lcases;
@property (readonly) NSCharacterSet *ucases;
@property (readonly) NSCharacterSet *numerals;
@property (readonly) NSCharacterSet *permissibleGrammar;

-(NSMutableArray*)fixNamesArray:(NSMutableArray*)in;

-(Citation*)getCitation:(WordIterator*)it forDate:(Year*)yr;

-(NSString*)trimExtraneousGrammar:(NSString*)in;

+(NSCharacterSet*)grammarCharacters;
+(BOOL)isBlankString:(NSString*)in;


@end
