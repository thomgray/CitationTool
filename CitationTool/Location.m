//
//  Location.m
//  CitationParser
//
//  Created by Thomas Gray on 14/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "Location.h"
#import <Cocoa/Cocoa.h>

@interface Location(Private)

-(NSMutableArray<NSValue*>*)getAllRangesInOrder;
-(void)modifyRangesAfterModification:(NSInteger)pos byOffest:(NSInteger)off including:(BOOL)inc;

-(void)editAuthorByInsertion:(NSString*)newAuthor at:(NSInteger)index;

-(void)tryInsertAmpersandBetween:(NSRange)rng1 and:(NSRange)rng2 deletingComma:(BOOL)delComma;
-(void)tryInsertCommaAfter:(NSRange)rng;
-(void)tryDeletingCommaAfter:(NSRange)rng;
-(void)tryRemoveAmpersandBetween:(NSRange)rng1 and:(NSRange)rng2 addingComma:(BOOL)comma;

+(BOOL)isEtAl:(NSString*)str;

@end

@implementation Location

@synthesize surround;
@synthesize attributedSurround;
@synthesize range;
@synthesize authorRangesInSurround;
@synthesize yearRangeInSurround;


-(instancetype)init{
    self = [super init];
    if (self) {
        authorRangesInSurround = [[NSMutableArray alloc]init];
    }
    return self;
}

-(instancetype)initWithRange:(NSRange)rng{
    self = [super init];
    if (self) {
        range = rng;
        authorRangesInSurround = [[NSMutableArray alloc]init];
    }
    return self;
}

-(instancetype)copy{
    Location* out = [[Location alloc]initWithRange:range];
    out.surround = self.surround.copy;
    out.attributedSurround = [attributedSurround mutableCopy];
    out.yearRangeInSurround = self.yearRangeInSurround;
    for (NSInteger i=0; i<authorRangesInSurround.count; i++) {
        [out.authorRangesInSurround addObject:[[authorRangesInSurround objectAtIndex:i] copy]]; //sketchy!?
    }
    return out;
}

-(void)setSurround:(NSString *)str{
    surround = str;
    attributedSurround = [[NSMutableAttributedString alloc]initWithString:str];
}



-(NSComparisonResult)compare:(id)in{
    if (![in isMemberOfClass:[Location class]]) return NSOrderedSame;
    Location * other = (Location*)in;
    if (self.range.location < other.range.location) return NSOrderedAscending;
    else if (self.range.location > other.range.location) return NSOrderedDescending;
    else return NSOrderedSame;
}

-(BOOL)isEqualTo:(id)object{
    if (![object isMemberOfClass:[Location class]]) return FALSE;
    Location* l = (Location*)object;
    return (l.range.location==self.range.location && l.range.length==self.range.length);
}


-(void)offsetRange:(NSInteger)offset{
    range = NSMakeRange(range.location+offset, range.length);
}

-(void)editAuthor:(NSString *)newAuthor at:(NSInteger)index inserting:(BOOL)insert{
    if (insert) {
        [self editAuthorByInsertion:newAuthor at:index];
    }else{
        if ([Location isEtAl:newAuthor] && index>0) {
            NSRange r1 = [[authorRangesInSurround objectAtIndex:index-1]rangeValue];
            NSRange r2 = [[authorRangesInSurround objectAtIndex:index]rangeValue];
            [self tryDeletingCommaAfter:r1];
            [self tryRemoveAmpersandBetween:r1 and:r2 addingComma:NO];
        }else if (![Location isEtAl:newAuthor] && index>0){
            NSRange r1 = [[authorRangesInSurround objectAtIndex:index-1]rangeValue];
            NSRange r2 = [[authorRangesInSurround objectAtIndex:index]rangeValue];
            if (index==authorRangesInSurround.count-1) {
                [self tryInsertAmpersandBetween:r1 and:r2 deletingComma:YES];
            }else{
                [self tryInsertCommaAfter:r1];
            }
        }
        NSRange authorRangeAtOverwrittenIndex = [[authorRangesInSurround objectAtIndex:index]rangeValue];
        NSInteger diff = newAuthor.length-authorRangeAtOverwrittenIndex.length;
        [self modifyRangesAfterModification:authorRangeAtOverwrittenIndex.location byOffest:diff including:NO];
        NSRange newAuthorRange = NSMakeRange(authorRangeAtOverwrittenIndex.location, newAuthor.length);
        [attributedSurround replaceCharactersInRange:authorRangeAtOverwrittenIndex withString:newAuthor];
        [attributedSurround setAttributes:@{NSForegroundColorAttributeName:[NSColor redColor]}range:newAuthorRange];
        surround=attributedSurround.string;
        NSValue* finalAuthorRange = [NSValue valueWithRange:newAuthorRange];
        [authorRangesInSurround replaceObjectAtIndex:index withObject:finalAuthorRange];
    }
    
}

-(void)editAuthorByInsertion:(NSString *)newAuthor at:(NSInteger)index{
    
    if (authorRangesInSurround.count==0) {// there are no authors already...
        NSRange newrange = NSMakeRange(yearRangeInSurround.location, newAuthor.length);
        NSAttributedString* insertString = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ", newAuthor] attributes:@{NSForegroundColorAttributeName : [NSColor redColor]}];
        [attributedSurround insertAttributedString:insertString atIndex:yearRangeInSurround.location];
        yearRangeInSurround = NSMakeRange(yearRangeInSurround.location+insertString.length, yearRangeInSurround.length);
        [attributedSurround addAttributes:@{NSForegroundColorAttributeName:[NSColor blueColor]} range:yearRangeInSurround];
        [authorRangesInSurround addObject:[NSValue valueWithRange:newrange]];
        surround = attributedSurround.string;
    }else if (index<authorRangesInSurround.count) { //then this is being inserted in front of a range
        //delete the & if present and replace with a comma..
        if (index>0){
            NSRange rng1 = [[authorRangesInSurround objectAtIndex:index-1]rangeValue];
            NSRange rng2 = [[authorRangesInSurround objectAtIndex:index]rangeValue];
            [self tryRemoveAmpersandBetween:rng1 and:rng2 addingComma:YES];
        }
        NSInteger newPos = [[authorRangesInSurround objectAtIndex:index]rangeValue].location;
        NSString* subsequentAuthor = [attributedSurround.mutableString substringWithRange:[authorRangesInSurround objectAtIndex:index].rangeValue];
        NSRange newRange = NSMakeRange(newPos, newAuthor.length);
        NSString* replacementString;
        if ([Location isEtAl:subsequentAuthor]){
            replacementString = [NSString stringWithFormat:@"%@ ", newAuthor];
        }else if (index == authorRangesInSurround.count-1){ //i.e this is the penultimate author
            replacementString = [NSString stringWithFormat:@"%@ & ", newAuthor];
        }else{
            replacementString = [NSString stringWithFormat:@"%@, ", newAuthor];
        }
        [self modifyRangesAfterModification:newPos byOffest:replacementString.length including:YES];
        [attributedSurround.mutableString insertString:replacementString atIndex:newPos];
        [attributedSurround addAttributes:@{NSForegroundColorAttributeName: [NSColor redColor]} range:newRange];
        [authorRangesInSurround insertObject:[NSValue valueWithRange:newRange] atIndex:index];
        surround = attributedSurround.string;
    }else{ //this is at the end
        if (index>1 && authorRangesInSurround.count>1){
            NSRange rng1 = [[authorRangesInSurround objectAtIndex:index-2]rangeValue];
            NSRange rng2 = [[authorRangesInSurround objectAtIndex:index-1]rangeValue];
            [self tryRemoveAmpersandBetween:rng1 and:rng2 addingComma:YES];
        }
        NSRange newRange;
        NSRange lastRange = [[authorRangesInSurround lastObject]rangeValue];
        NSString* insertedString;
        if ([Location isEtAl:newAuthor]){
            insertedString = [NSString stringWithFormat:@" %@", newAuthor];
            newRange = NSMakeRange(lastRange.location+lastRange.length+1, newAuthor.length);
        }else{
            insertedString = [NSString stringWithFormat:@" & %@", newAuthor];
            newRange = NSMakeRange(lastRange.location+lastRange.length+3, newAuthor.length);
        }
        [attributedSurround.mutableString insertString:insertedString atIndex:lastRange.location+lastRange.length];
        [self modifyRangesAfterModification:lastRange.location byOffest:insertedString.length including:NO];
        [attributedSurround addAttributes:@{NSForegroundColorAttributeName:[NSColor redColor]} range:newRange];
        [authorRangesInSurround insertObject:[NSValue valueWithRange:newRange] atIndex:index];
        surround = attributedSurround.string;
    }
}

-(void)removeAuthorAtIndex:(NSInteger)index{
    
}

-(void)editYear:(NSString *)newYear{
    NSRange newYearRange = yearRangeInSurround;
    if (newYear.length!=yearRangeInSurround.length) {
        NSInteger diff = newYear.length-yearRangeInSurround.length;
        [self modifyRangesAfterModification:newYearRange.location byOffest:diff including:NO];
        newYearRange = NSMakeRange(yearRangeInSurround.location, yearRangeInSurround.length+diff);
    }
    [attributedSurround replaceCharactersInRange:yearRangeInSurround withString:newYear];
    [attributedSurround setAttributes:@{NSForegroundColorAttributeName:[NSColor redColor]} range:newYearRange];
    surround=attributedSurround.string;
    yearRangeInSurround = newYearRange;
}

-(void)tryInsertAmpersandBetween:(NSRange)rng1 and:(NSRange)rng2 deletingComma:(BOOL)delComma{
    NSInteger endOfR1Pos = rng1.location+rng1.length;
    if (delComma && [attributedSurround.mutableString characterAtIndex:endOfR1Pos]==','){
        [attributedSurround.mutableString deleteCharactersInRange:NSMakeRange(endOfR1Pos, 1)];
        [self modifyRangesAfterModification:rng1.location byOffest:-1 including:NO];
    }
    for (NSInteger i=endOfR1Pos; i<rng2.location; i++) {
        unichar c= [attributedSurround.mutableString characterAtIndex:i];
        if ([[NSCharacterSet whitespaceCharacterSet]characterIsMember:c]) continue;
        else return;
    }
    NSRange inbetweener = NSMakeRange(endOfR1Pos, rng2.location-endOfR1Pos);
    NSString* rep = @" & ";
    [attributedSurround.mutableString replaceCharactersInRange:inbetweener withString:rep];
    [self modifyRangesAfterModification:rng1.location byOffest:(rep.length-inbetweener.length) including:NO];
    surround = attributedSurround.string;
}

-(void)tryRemoveAmpersandBetween:(NSRange)rng1 and:(NSRange)rng2 addingComma:(BOOL)comma{
    NSInteger gapPos = rng1.location+rng1.length;
    NSRange inbetween = NSMakeRange(gapPos, rng2.location-gapPos);
    NSMutableString* gap = [NSMutableString stringWithString:[attributedSurround.mutableString substringWithRange:inbetween]];
    NSRange andRange;
    
    if ([gap containsString:@" & "]) {
        andRange = [gap rangeOfString:@" & "];
        [gap replaceCharactersInRange:andRange withString:@" "];
    }else if ([gap containsString:@" and "]){
        andRange = [gap rangeOfString:@" and "];
        [gap replaceCharactersInRange:andRange withString:@" "];
    }else if ([gap containsString:@" And "]){
        andRange = [gap rangeOfString:@" And "];
        [gap replaceCharactersInRange:andRange withString:@" "];
    }else if (comma){
        NSInteger loc = rng1.location+rng1.length;
        if ([attributedSurround.mutableString characterAtIndex:loc]!=',') {
            [attributedSurround.mutableString insertString:@"," atIndex:loc];
            [self modifyRangesAfterModification:loc byOffest:1 including:YES];
        }
        return;
    }
    
    if (comma) {
        unichar c = [gap characterAtIndex:0];
        if (c!=','){
            [gap insertString:@"," atIndex:0];
        }
    }
    NSInteger diff = (gap.length-inbetween.length);
    
    [self modifyRangesAfterModification:rng1.location byOffest:diff including:NO];
    [attributedSurround.mutableString replaceCharactersInRange:inbetween withString:gap];
}

-(void)tryInsertCommaAfter:(NSRange)rng{
    NSInteger loc = rng.location+rng.length;
    if ([attributedSurround.mutableString characterAtIndex:loc]!=',') {
        [attributedSurround.mutableString insertString:@"," atIndex:loc];
        [self modifyRangesAfterModification:rng.location byOffest:1 including:NO];
    }
}

-(void)tryDeletingCommaAfter:(NSRange)rng{
    NSInteger loc = rng.location+rng.length;
    if ([attributedSurround.mutableString characterAtIndex:loc]==','){
        [attributedSurround.mutableString deleteCharactersInRange:NSMakeRange(loc, 1)];
        [self modifyRangesAfterModification:rng.location byOffest:-1 including:NO];
    }
}

-(NSMutableArray<NSValue*> *)getAllRangesInOrder{
    NSMutableArray* out = [[NSMutableArray alloc]initWithCapacity:1+authorRangesInSurround.count];
    [out addObject:[NSValue valueWithRange:yearRangeInSurround]];
    [out addObjectsFromArray:authorRangesInSurround];
    [out sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSValue *v1 = (NSValue*)obj1;
        NSValue*v2 = (NSValue*)obj2;
        if (v1.rangeValue.location>v2.rangeValue.location) {
            return NSOrderedDescending;
        }else if (v2.rangeValue.location>v1.rangeValue.location) return NSOrderedAscending;
        else return NSOrderedSame;
    }];
    return out;
}

///requires the unmodified range! i.e. the range that has since been modified
-(void)modifyRangesAfterModification:(NSInteger)pos byOffest:(NSInteger)off including:(BOOL)inc{
    for (NSInteger i=0; i<authorRangesInSurround.count; i++) {
        NSRange rng = [[authorRangesInSurround objectAtIndex:i]rangeValue];
        if (inc? rng.location>=pos : rng.location>pos){
            NSValue* rngVal = [NSValue valueWithRange:NSMakeRange(rng.location+off, rng.length)];
            [authorRangesInSurround replaceObjectAtIndex:i withObject:rngVal];
        }
    }
    if (yearRangeInSurround.location > inc? pos-1:pos) {
        yearRangeInSurround = NSMakeRange(yearRangeInSurround.location+off, yearRangeInSurround.length);
    }
}


+(BOOL)isEtAl:(NSString *)str{
    str = [str lowercaseString];
    if ([str isEqualToString:@"et al"] || [str isEqualToString:@"et al."] || [str isEqualToString:@"etal"]
        || [str isEqualToString:@"etal."]) {
        return TRUE;
    }return FALSE;
}

@end
