//
//  CitationIterator.h
//  CitationTool
//
//  Created by Thomas Gray on 19/10/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import "StringIterator.h"
#import "Citation.h"

@class Citation;


@interface CitationIterator : StringIterator

-(Citation*)getCitation:(StringIterator*)it forDate:(Year *)yr;

+(NSCharacterSet*)extraGrammar;
+(NSCharacterSet*)numeralChars;
+(NSRange)mergeRanges:(NSRange)rng1 and:(NSRange)rng2;
+(NSRange)mergeRanges:(NSArray<NSValue*>*)rnges;
+(NSRange)transformRange:(NSRange)rng withinRange:(NSRange)outerRange;


@end
