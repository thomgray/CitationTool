//
//  WordIterator.m
//  CitationParser
//
//  Created by Thomas Gray on 13/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "WordIterator.h"

@implementation WordIterator

@synthesize wordIndex;
@synthesize currentWord;
@synthesize position;
@synthesize paragraph;
@synthesize goingForward;
@synthesize currentWordRange;


-(instancetype)init{
    self = [super init];
    if (self) {
        delimiters = [NSMutableCharacterSet newlineCharacterSet];
        [delimiters addCharactersInString:@"\t ;:/\\"];
        goingForward = TRUE;
    }
    return self;
}

-(instancetype)initWithParagraph:(NSString*)str{
    self = [self init];
    if (!self) return self;
        
    paragraph = str;
    length = paragraph.length;
    position = 0;
    wordIndex = -1;
    
    return self;
}

-(instancetype)initByTakingOver:(WordIterator *)wit{
    self = [self init];
    if (self) {
        paragraph = wit.paragraph;
        position = wit.position;
        currentWord = wit.currentWord;
        length = [paragraph length];
        wordIndex = wit.wordIndex;
        goingForward = wit.goingForward;
    }
    return self;
}



-(NSString*)nextWord{
    if (!goingForward) {
        goingForward = TRUE;
        [self nextWord];
    }
    if (position<0) position = 0;
    while (true) {
        if (position>=length){
            currentWord = nil;
            return currentWord;
        }
        unichar c = [paragraph characterAtIndex:position];
        if ([delimiters characterIsMember:c]) position++;
        else break;
    }//position is now at the start of a new word (or returned nil aready if end was reached)
    
    NSInteger newpos = position+1;
    while (true) {
        if (newpos>=length || [delimiters characterIsMember:[paragraph characterAtIndex:newpos]]) {
            currentWordRange = NSMakeRange(position, newpos-position);
            currentWord = [paragraph substringWithRange:currentWordRange];
            position = newpos;
            wordIndex++;
            //NSLog(@"Previous word: %@", currentWord);
            return currentWord;
        }
        newpos++;
    }
}


-(NSString*)previousWord{
    if (goingForward) {
        goingForward = FALSE;
        [self previousWord];
    }
    if (position>=length) position = length-1;
    while (true) {
        if (position<0){
            currentWord = nil;
            return currentWord;
        }
        unichar c = [paragraph characterAtIndex:position];
        if ([delimiters characterIsMember:c]) position--;
        else break;
    }//position is now at the start of a new word (or returned nil aready if end was reached)
    
    NSInteger newpos = position-1;
    while (true) {
        if (newpos<0 || [delimiters characterIsMember:[paragraph characterAtIndex:newpos]]) {
            currentWordRange = NSMakeRange(newpos+1, position-newpos);
            currentWord = [paragraph substringWithRange:currentWordRange];
            position = newpos;
            wordIndex--;
            //NSLog(@"Previous word: %@", currentWord);
            return currentWord;
        }
        newpos--;
    }
}

-(NSString*)peekNextWord{
    NSInteger oldpos = position;
    NSString *oldword = currentWord;
    NSRange oldrange = currentWordRange;
    BOOL oldstate = goingForward;
    
    NSString *out = [self nextWord];
    
    position = oldpos;
    currentWord = oldword;
    currentWordRange = oldrange;
    goingForward = oldstate;
    
    wordIndex--;
    return out;
}


-(NSString*)peekPreviousWord{
    NSInteger oldpos = position;
    NSString *oldword = currentWord;
    NSRange oldrange = currentWordRange;
    BOOL oldstate = goingForward;
    
    NSString *out = [self previousWord];
    
    position = oldpos;
    currentWord = oldword;
    currentWordRange = oldrange;
    goingForward = oldstate;
    
    wordIndex++;
    return out;
}

-(NSString*)wordAtIndex:(NSInteger)i{
    WordIterator * wit = [[WordIterator alloc]initWithParagraph:paragraph];
    NSString* out;
    while ((out = [wit nextWord])) {
        if (wit.wordIndex==i) {
            return wit.currentWord;
        }
    }
    return nil;
}

-(NSRange)rangeOfWordAtIndex:(NSInteger) idx{
    BOOL word = FALSE;
    NSInteger index = -1;
    for (int i=0; i<paragraph.length; i++) {
        unichar c = [paragraph characterAtIndex:i];
        if ([delimiters characterIsMember:c]){
            word = FALSE;
        }else{
            if (!word){
                word = TRUE;
                index++;
                if (index==idx) {
                    int j=i;
                    while (TRUE) {
                        unichar d = [paragraph characterAtIndex:j];
                        if ([delimiters characterIsMember:d]) {
                            return NSMakeRange(i, j-i);
                        }else if (j==paragraph.length-1){
                            return NSMakeRange(i, j-i+1);
                        }
                        j++;
                    }
                }
            }
        }
    }
    NSException *e =  [[NSException alloc]initWithName:@"BadParameterException" reason:[NSString stringWithFormat:@"There is no %ldth word in the paragraph (out of bounds)", (long)idx] userInfo:nil];
    @throw e;
}


+(BOOL)isBlankString:(NSString *)in{
    for (int i=0; i<in.length;i++){
        unichar c = [in characterAtIndex:i];
        if (c==' ' || c=='\t'){
        }else return FALSE;
    }
    return TRUE;
}


@end