//
//  Reference.h
//  CitationTool3
//
//  Created by Thomas Gray on 20/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Year.h"
#import "Name.h"
#import "Citation.h"
#import "LaTeXString.h"

@class Citation;

#define AUTHOR @"author"
#define ADDRESS @"address"
#define ANNOTE @"annote"
#define BOOKTITLE @"booktitle"
#define CHAPTER @"chapter"
#define CROSSREF @"crossref"
#define EDITION @"edition"
#define EDITOR @"editor"
#define HOWPUBLISHED @"howpublished"
#define INSTITUTION @"institution"
#define JOURNAL @"journal"
#define MONTH @"month"
#define NOTE @"note"
#define NUMBER @"number"
#define ORGANIZATION @"organization"
#define PAGES @"pages"
#define PUBLISHER @"publisher"
#define SCHOOL @"school"
#define SERIES @"series"
#define TITLE @"title"
#define VOLUME @"volume"
#define YEAR @"year"

@interface Reference : NSObject{
    NSMutableCharacterSet * emptyChars;
    NSCharacterSet * braceChars;
}

# pragma mark -BibTeX fields

@property NSString* key;
@property NSString* type;

@property NSMutableDictionary* fields;

#pragma mark -Custom Fields

@property NSMutableArray* authorArray; //name array
@property NSMutableArray* editorArray; //name array
@property NSInteger yearInt;
@property unichar yearModifier; //not set initially, but may be saved for future reference

#pragma mark -Methods

-(instancetype)initWithBibEntry:(NSString*)bibString;

-(void)getDataFromBib:(NSString*)bibString;

-(BOOL)matchesCitation:(Citation*)cite;

-(NSString*)toStringTypeTitle;

+(NSInteger)getIndexOfFirst:(unichar)c inString:(NSString*)str;
+(NSMutableArray*)makeArrayOfNames:(NSString*)names;

+(NSMutableArray*)getReferencesFromFile:(NSString*)path;
+(NSMutableArray*)getReferenceStringsFromWhole:(NSString*)wholeString;

-(BOOL)isEqualToReference:(Reference*)ref;

#pragma mark Static Fields (and Type) Retrievers

+(NSArray *)getEntryTypes;
+(NSArray*) getEstablishedFields;

+(NSArray*)articleFields;
+(NSArray*)bookFields;
+(NSArray*)bookletFields;
+(NSArray*)conferenceFields;
+(NSArray*)inbookFields;
+(NSArray*)incollectionFields;
+(NSArray*)inproceedingsFields;
+(NSArray*)manualFields;
+(NSArray*)masterthesisFields;
+(NSArray*)miscFields;
+(NSArray*)phdthesisFields;
+(NSArray*)proceedingsFields;
+(NSArray*)techreportFields;
+(NSArray*)unpublishedFields;

+(NSArray*)getCorrespondingPrincipleFields:(NSString*)type;


@end
