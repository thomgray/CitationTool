//
//  Citations.h
//  CitationParser
//
//  Created by Thomas Gray on 13/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Citation.h"
#import "Location.h"

@class Citation;

@interface CitationList :NSObject

@property (readonly) NSMutableArray *citations;
@property (readonly) NSMutableArray *possibleCitations;

-(BOOL)addPossibleCitation:(Citation*)cite;
-(BOOL)addWholeCitation:(Citation*)cite;
-(void)printBib;
-(void)sortAlphabetically;

-(NSInteger)referencesTotal;
-(NSInteger)citationsTotal;

@end
