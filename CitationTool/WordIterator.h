//
//  WordIterator.h
//  CitationParser
//
//  Created by Thomas Gray on 13/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordIterator : NSObject{
    NSInteger length;
    NSMutableCharacterSet* delimiters;
}

@property (readonly) NSString* currentWord;
@property (readonly) NSInteger wordIndex;
@property (readonly) NSInteger position;
@property (readonly) NSString* paragraph;
@property (readonly) BOOL goingForward;
@property (readonly) NSRange currentWordRange;

-(instancetype)initWithParagraph:(NSString*)str;
-(instancetype)initByTakingOver:(WordIterator*)wit;

-(NSString*)nextWord;
-(NSString*)previousWord;

-(NSString*)peekPreviousWord;
-(NSString*)peekNextWord;

-(NSString*)wordAtIndex:(NSInteger)i;

-(NSRange)rangeOfWordAtIndex:(NSInteger) i;


+(BOOL)isBlankString:(NSString*)in;

@end
