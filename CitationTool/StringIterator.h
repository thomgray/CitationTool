//
//  StringIterator.h
//  CitationTool
//
//  Created by Thomas Gray on 19/10/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringIterator : NSObject{
    NSInteger length;
}

@property (readonly) NSString* currentWord;
@property (readonly) NSInteger wordIndex;
@property (readonly) NSRange currentWordRange;
@property NSMutableCharacterSet* delimiters;
@property (nonatomic, retain) NSString* source;


-(instancetype)initWithString:(NSString*)str goingForward:(BOOL)fwd;
-(instancetype)initByTakingOver:(StringIterator*)it;
-(void)takeOverIterator:(StringIterator*)it;

-(void)addDelimiters:(NSCharacterSet*)chars;
-(void)removeDelimiters:(NSCharacterSet *)chars;

-(NSString*)nextWord;
-(NSString*)previousWord;

-(NSRange)rangeOfWordAtIndex:(NSInteger)idx goingForward:(BOOL)fwd;
-(NSString*)wordAtIndex:(NSInteger)idx goingForward:(BOOL)fwd;

-(NSRange)peekRangeOfNextWord;
-(NSRange)peekRangeOfPreviousWord;
-(NSString*)peekNextWord;
-(NSString*)peekPreviousWord;

-(NSRange)rangeOfNextDelimit;
-(NSRange)rangeOfPreviousDelimit;

-(void)modifyCurrentWordRange:(NSRange)rng;

@end
