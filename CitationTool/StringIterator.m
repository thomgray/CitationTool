//
//  StringIterator.m
//  CitationTool
//
//  Created by Thomas Gray on 19/10/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import "StringIterator.h"

@interface StringIterator ()

@end

@implementation StringIterator

@synthesize currentWordRange;
@synthesize currentWord;
@synthesize wordIndex;
@synthesize source;
@synthesize delimiters;

-(instancetype)init{
    self = [super init];
    if (self) {
        delimiters = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
        currentWordRange = NSMakeRange(0, 0);
        wordIndex = 0;
    }
    return self;
}

-(instancetype)initWithString:(NSString *)str goingForward:(BOOL)forward{
    self = [super init];
    if (self) {
        source = str;
        length = str.length;
        wordIndex = 0;
        delimiters = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
        if (forward) {
            currentWordRange = NSMakeRange(0, 0);
        }else{
            currentWordRange = NSMakeRange(str.length-1, 0);
        }
    }
    return self;
}

-(instancetype)initByTakingOver:(StringIterator *)it{
    self = [super init];
    if (self) {
        source = it.source;
        currentWordRange = it.currentWordRange;
        delimiters = [it.delimiters copy];
        currentWord = [it.currentWord copy];
        wordIndex =it.wordIndex;
        length = source.length;
    }
    return self;
}

-(void)takeOverIterator:(StringIterator *)it{
    source = it.source;
    length = source.length;
    currentWordRange = it.currentWordRange;
    currentWord = it.currentWord;
    wordIndex = it.wordIndex;
    delimiters = it.delimiters;
}


#pragma mark Iteration

-(NSString *)nextWord{
    NSInteger top;
    NSInteger bottom = currentWordRange.location+currentWordRange.length;
    for (;TRUE; bottom++) {
        if (bottom>=length-1) {
            return nil;
        }
        unichar c = [source characterAtIndex:bottom];
        if (![delimiters characterIsMember:c]) {
            break;
        }
    }
    for (top=bottom;TRUE; top++) {
        unichar c = [source characterAtIndex:top];
        if ([delimiters characterIsMember:c]) {
            wordIndex++;
            currentWordRange = NSMakeRange(bottom, top-bottom);
            currentWord = [source substringWithRange:currentWordRange];
            return [source substringWithRange:currentWordRange];
        }else if (top==length-1){
            wordIndex++;
            top++;
            currentWordRange = NSMakeRange(bottom, top-bottom);
            currentWord = [source substringWithRange:currentWordRange];
            return [source substringWithRange:currentWordRange];
        }
    }
}

-(NSString *)previousWord{
    NSInteger top= currentWordRange.location-1;
    NSInteger bottom;
    for (;TRUE; top--) {
        if (top<0) {
            return nil;
        }
        unichar c = [source characterAtIndex:top];
        if (![delimiters characterIsMember:c]) {
            break;
        }
    }
    top++;
    for (bottom=top-1;TRUE; bottom--) {
        unichar c = [source characterAtIndex:bottom];
        if ([delimiters characterIsMember:c]) {
            wordIndex--;
            bottom++;
            currentWordRange = NSMakeRange(bottom, top-bottom);
            currentWord = [source substringWithRange:currentWordRange];
            return [source substringWithRange:currentWordRange];
        }else if (bottom==0){
            wordIndex--;
            currentWordRange = NSMakeRange(bottom, top-bottom);
            currentWord = [source substringWithRange:currentWordRange];
            return [source substringWithRange:currentWordRange];
        }
    }
}

-(NSRange)peekRangeOfNextWord{
    NSInteger top;
    NSInteger bottom = currentWordRange.location+currentWordRange.length;
    for (;TRUE; bottom++) {
        if (bottom>=length-1) {
            return NSMakeRange(NSNotFound, 0);
        }
        unichar c = [source characterAtIndex:bottom];
        if (![delimiters characterIsMember:c]) {
            break;
        }
    }
    for (top=bottom;TRUE; top++) {
        unichar c = [source characterAtIndex:top];
        if ([delimiters characterIsMember:c]) {
            return NSMakeRange(bottom, top-bottom);
        }else if (top==length-1){
            top++;
            return NSMakeRange(bottom, top-bottom);
        }
    }

}

-(NSString *)peekNextWord{
    NSRange rng = [self peekRangeOfNextWord];
    if (rng.location!=NSNotFound) return [source substringWithRange:rng];
    else return nil;
}

-(NSRange)peekRangeOfPreviousWord{
    NSInteger top= currentWordRange.location-1;
    NSInteger bottom;
    for (;TRUE; top--) {
        if (top<0) {
            return NSMakeRange(NSNotFound, 0);
        }
        unichar c = [source characterAtIndex:top];
        if (![delimiters characterIsMember:c]) {
            break;
        }
    }
    top++;
    for (bottom=top-1;TRUE; bottom--) {
        unichar c = [source characterAtIndex:bottom];
        if ([delimiters characterIsMember:c]) {
            bottom++;
            return  NSMakeRange(bottom, top-bottom);
        }else if (bottom==0){
            return NSMakeRange(bottom, top-bottom);
        }
    }
}

-(NSString *)peekPreviousWord{
    NSRange rng = [self peekRangeOfPreviousWord];
    if (rng.location!=NSNotFound) return [source substringWithRange:rng];
    else return nil;
}

-(NSRange)rangeOfWordAtIndex:(NSInteger)idx goingForward:(BOOL)fwd{
    StringIterator* sit = [[StringIterator alloc]initWithString:source goingForward:fwd];
    [sit setDelimiters:delimiters];
    
    if (fwd) {
        if (idx<0) return NSMakeRange(NSNotFound, 0);
        while (sit.nextWord) {
            if (sit.wordIndex==idx) {
                return sit.currentWordRange;
            }
        }
    }else{
        if (idx>0) return NSMakeRange(NSNotFound, 0);
        while (sit.previousWord) {
            if (sit.wordIndex==idx) {
                return sit.currentWordRange;
            }
        }
    }
    return NSMakeRange(NSNotFound, 0);
}

-(NSString *)wordAtIndex:(NSInteger)idx goingForward:(BOOL)fwd{
    NSRange rng = [self rangeOfWordAtIndex:idx goingForward:fwd];
    if (rng.location == NSNotFound) {
        return nil;
    }else return [source substringWithRange:rng];
}

-(NSRange)rangeOfNextDelimit{
    NSInteger top;
    NSInteger bottom = currentWordRange.location+currentWordRange.length;
    if (bottom>=source.length) return NSMakeRange(NSNotFound, 0);
    for (top=bottom; TRUE; top++) {
        unichar c = [source characterAtIndex:top];
        if (![delimiters characterIsMember:c]) {
            return NSMakeRange(bottom, top-bottom);
        }else if (top==source.length-1){
            top++;
            return NSMakeRange(bottom, top-bottom);
        }
    }
    return NSMakeRange(NSNotFound, 0);
}

-(NSRange)rangeOfPreviousDelimit{
    NSInteger top = currentWordRange.location;
    NSInteger bottom = currentWordRange.location-1;
    if (bottom<0) return NSMakeRange(NSNotFound, 0);
    for (;TRUE; bottom--) {
        unichar c = [source characterAtIndex:bottom];
        if (![delimiters characterIsMember:c]) {
            bottom++;
            return NSMakeRange(bottom, top-bottom);
        }else if (bottom==0) return NSMakeRange(bottom, top-bottom);
    }
    return NSMakeRange(NSNotFound, 0);
}

#pragma mark Behaviour

-(void)addDelimiters:(NSCharacterSet *)chars{
    [delimiters formUnionWithCharacterSet:chars];
}

-(void)removeDelimiters:(NSCharacterSet *)chars{
    [delimiters formIntersectionWithCharacterSet:[chars invertedSet]];
}
#pragma mark Cheeky Overrides

-(void)modifyCurrentWordRange:(NSRange)rng{
    currentWordRange =rng;
}


@end



