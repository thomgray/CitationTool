//
//  Parser.h
//  CitationParser
//
//  Created by Thomas Gray on 13/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Citation.h"
#import "Year.h"
#import "Location.h"
#import "CitationIterator.h"

@class Citation;
@class CitationAnalyser;

@interface Parser : NSObject{
    int nPar;
    //CitationIterator* citAnalyser;
    
    NSCharacterSet*numerals;
    NSCharacterSet*grammar;
    NSCharacterSet *lcases;
}

@property (readonly) NSMutableArray<Citation*> *citations;
@property (readwrite) NSInteger earliestDate;
@property (readonly) NSInteger latestDate;
@property (readonly) NSString* sourceString;

-(instancetype)init;

-(BOOL)isDate:(NSString *)str;

-(NSMutableArray<Citation*>*)getCitations;

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
