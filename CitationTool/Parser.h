//
//  Parser.h
//  CitationParser
//
//  Created by Thomas Gray on 13/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Citation.h"
#import "WordIterator.h"
#import "CitationList.h"
#import "Year.h"
#import "Location.h"
#import "CitationAnalyser.h"

@class CitationList;
@class CitationAnalyser;

@interface Parser : NSObject{
    int nPar;
    CitationAnalyser* citAnalyser;
    
    NSCharacterSet*numerals;
    NSCharacterSet*grammar;
    NSCharacterSet *lcases;
}

@property (readonly) CitationList *citations;
@property (readwrite) NSInteger earliestDate;
@property (readonly) NSInteger latestDate;
@property (readonly) NSString* sourceString;

-(instancetype)init;

-(BOOL)isDate:(NSString *)str;

-(CitationList *)getCitations;

-(void)loadFile:(NSString*)path;

-(void)test;

-(void)setSourceString:(NSString *)sourceString;

+(NSString *)stringByRemovingCharactersInSet: (NSCharacterSet*)set
                                  fromString: (NSString *)str;
+(NSString *)stringByIncludingCharactersInSet: (NSCharacterSet*)set
                                   withString:(NSString*)str;

+(Year*)getYearFromString:(NSString*)str;

#pragma mark Useful Static Methods

+(BOOL)string:(NSString*)string isEmptyOrExclusivelyCharacters:(NSCharacterSet*)charset;
+(NSString*)stringByTrimmingEmptySpace:(NSString*)str;

@end
