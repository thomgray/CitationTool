//
//  Location.m
//  CitationParser
//
//  Created by Thomas Gray on 14/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "Location.h"
#import "CitationIterator.h"
#import <Cocoa/Cocoa.h>

@interface Location(Private)

-(NSMutableArray<NSValue*>*)getAllRangesInOrder;
//-(void)modifyRangesAfterModification:(NSInteger)pos byOffest:(NSInteger)off including:(BOOL)inc;

//-(void)editAuthorByInsertion:(NSString*)newAuthor at:(NSInteger)index;
//
//-(void)tryInsertAmpersandBetween:(NSRange)rng1 and:(NSRange)rng2 deletingComma:(BOOL)delComma;
//-(void)tryInsertCommaAfter:(NSRange)rng;
//-(void)tryDeletingCommaAfter:(NSRange)rng;
//-(void)tryRemoveAmpersandBetween:(NSRange)rng1 and:(NSRange)rng2 addingComma:(BOOL)comma;
//-(void)tryRemoveEmptySpaceFrom:(NSInteger)point goingForward:(BOOL)forward flexible:(BOOL)flexible;

+(BOOL)isEtAl:(NSString*)str;

+(NSColor*)editForegroundColor;
+(NSColor*)editBackgroundColor;
+(NSColor*)boringForegroundColor;

@end

@implementation Location

//@synthesize surround;
//@synthesize surroundRange;
//@synthesize attributedSurround;
@synthesize range;
//@synthesize authorRangesInSurround;
//@synthesize yearRangeInSurround;
@synthesize authorRangesInSource;
@synthesize yearRangeInSource;


-(instancetype)init{
    self = [super init];
    if (self) {
        authorRangesInSource = [[NSMutableArray alloc]init];
    }
    return self;
}

-(instancetype)initWithRange:(NSRange)rng{
    self = [self init];
    if (self) {
        range = rng;
    }
    return self;
}

-(instancetype)copy{
    Location* out = [[Location alloc]initWithRange:range];
//    out.surround = self.surround.copy;
//    out.attributedSurround = [attributedSurround mutableCopy];
//    out.yearRangeInSurround = self.yearRangeInSurround;
    out.yearRangeInSource = self.yearRangeInSource;
//    for (NSInteger i=0; i<authorRangesInSource.count; i++) {
//        [out.authorRangesInSource addObject:[[authorRangesInSurround objectAtIndex:i] copy]]; //sketchy!?
//    }
    for (NSInteger i=0; i<self.authorRangesInSource.count; i++) {
        NSValue* val = [self.authorRangesInSource objectAtIndex:i];
        [out.authorRangesInSource addObject:[val copy]];
    }
    return out;
}

-(void)addRangeToAuthorSourceArray:(NSRange)rng{
    if (!authorRangesInSource) authorRangesInSource = [[NSMutableArray alloc]init];
    NSValue* val = [NSValue valueWithRange:rng];
    [authorRangesInSource addObject:val];
    [authorRangesInSource sortUsingComparator:[Location rangeComparator]];
}

-(NSMutableArray<NSValue *> *)getAllRangesInSourceInExplicitOrder:(BOOL)order{
    NSMutableArray<NSValue*>* arr = [[NSMutableArray alloc]initWithCapacity:authorRangesInSource.count+1];
    [arr addObjectsFromArray:authorRangesInSource];
    [arr addObject:[NSValue valueWithRange:yearRangeInSource]];
    if (!order) return arr;
    [arr sortUsingComparator:[Location rangeComparator]];
    return arr;
}

//-(void)setSurround:(NSString *)str{
//    surround = str;
//    attributedSurround = [[NSMutableAttributedString alloc]initWithString:str];
//}
//
//-(NSString*)surround{
//    return attributedSurround.string;
//}


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

//-(void)editAuthor:(NSString *)newAuthor at:(NSInteger)index inserting:(BOOL)insert{
//    if (insert) {
//        [self editAuthorByInsertion:newAuthor at:index];
//    }else{
//        if ([Location isEtAl:newAuthor] && index>0) {
//            NSRange r1 = [[authorRangesInSurround objectAtIndex:index-1]rangeValue];
//            NSRange r2 = [[authorRangesInSurround objectAtIndex:index]rangeValue];
//            [self tryDeletingCommaAfter:r1];
//            [self tryRemoveAmpersandBetween:r1 and:r2 addingComma:NO];
//        }else if (![Location isEtAl:newAuthor] && index>0){
//            NSRange r1 = [[authorRangesInSurround objectAtIndex:index-1]rangeValue];
//            NSRange r2 = [[authorRangesInSurround objectAtIndex:index]rangeValue];
//            if (index==authorRangesInSurround.count-1) {
//                [self tryInsertAmpersandBetween:r1 and:r2 deletingComma:YES];
//            }else{
//                [self tryInsertCommaAfter:r1];
//            }
//        }
//        NSRange authorRangeAtOverwrittenIndex = [[authorRangesInSurround objectAtIndex:index]rangeValue];
//        NSInteger diff = newAuthor.length-authorRangeAtOverwrittenIndex.length;
//        [self modifyRangesAfterModification:authorRangeAtOverwrittenIndex.location byOffest:diff including:NO];
//        NSRange newAuthorRange = NSMakeRange(authorRangeAtOverwrittenIndex.location, newAuthor.length);
//        [attributedSurround replaceCharactersInRange:authorRangeAtOverwrittenIndex withString:newAuthor];
//        [attributedSurround addAttributes:@{NSForegroundColorAttributeName:[Location editForegroundColor]}range:newAuthorRange];
//        surround=attributedSurround.string;
//        NSValue* finalAuthorRange = [NSValue valueWithRange:newAuthorRange];
//        [authorRangesInSurround replaceObjectAtIndex:index withObject:finalAuthorRange];
//    }
//}
//
//-(void)editAuthorByInsertion:(NSString *)newAuthor at:(NSInteger)index{
//    
//    if (authorRangesInSurround.count==0) {// there are no authors already...
//        NSRange newrange = NSMakeRange(yearRangeInSurround.location, newAuthor.length);
//        NSAttributedString* insertString = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ", newAuthor] attributes:@{NSForegroundColorAttributeName : [Location editForegroundColor]}];
//        [attributedSurround insertAttributedString:insertString atIndex:yearRangeInSurround.location];
//        yearRangeInSurround = NSMakeRange(yearRangeInSurround.location+insertString.length, yearRangeInSurround.length);
//        [authorRangesInSurround addObject:[NSValue valueWithRange:newrange]];
//        surround = attributedSurround.string;
//    }else if (index<authorRangesInSurround.count) { //then this is being inserted in front of a range
//        //delete the & if present and replace with a comma..
//        if (index>0){
//            NSRange rng1 = [[authorRangesInSurround objectAtIndex:index-1]rangeValue];
//            NSRange rng2 = [[authorRangesInSurround objectAtIndex:index]rangeValue];
//            [self tryRemoveAmpersandBetween:rng1 and:rng2 addingComma:YES];
//        }
//        NSInteger newPos = [[authorRangesInSurround objectAtIndex:index]rangeValue].location;
//        NSString* subsequentAuthor = [attributedSurround.mutableString substringWithRange:[authorRangesInSurround objectAtIndex:index].rangeValue];
//        NSRange newRange = NSMakeRange(newPos, newAuthor.length);
//        NSString* replacementString;
//        if ([Location isEtAl:subsequentAuthor]){
//            replacementString = [NSString stringWithFormat:@"%@ ", newAuthor];
//        }else if (index == authorRangesInSurround.count-1){ //i.e this is the penultimate author
//            replacementString = [NSString stringWithFormat:@"%@ & ", newAuthor];
//        }else{
//            replacementString = [NSString stringWithFormat:@"%@, ", newAuthor];
//        }
//        [self modifyRangesAfterModification:newPos byOffest:replacementString.length including:YES];
//        [attributedSurround.mutableString insertString:replacementString atIndex:newPos];
//        [attributedSurround addAttributes:@{NSForegroundColorAttributeName: [NSColor redColor]} range:newRange];
//        [authorRangesInSurround insertObject:[NSValue valueWithRange:newRange] atIndex:index];
//        surround = attributedSurround.string;
//    }else{ //this is at the end
//        if (index>1 && authorRangesInSurround.count>1){
//            NSRange rng1 = [[authorRangesInSurround objectAtIndex:index-2]rangeValue];
//            NSRange rng2 = [[authorRangesInSurround objectAtIndex:index-1]rangeValue];
//            [self tryRemoveAmpersandBetween:rng1 and:rng2 addingComma:YES];
//        }
//        NSRange newRange;
//        NSRange lastRange = [[authorRangesInSurround lastObject]rangeValue];
//        NSString* insertedString;
//        if ([Location isEtAl:newAuthor]){
//            insertedString = [NSString stringWithFormat:@" %@", newAuthor];
//            newRange = NSMakeRange(lastRange.location+lastRange.length+1, newAuthor.length);
//        }else{
//            insertedString = [NSString stringWithFormat:@" & %@", newAuthor];
//            newRange = NSMakeRange(lastRange.location+lastRange.length+3, newAuthor.length);
//        }
//        [attributedSurround.mutableString insertString:insertedString atIndex:lastRange.location+lastRange.length];
//        [self modifyRangesAfterModification:lastRange.location byOffest:insertedString.length including:NO];
//        [attributedSurround addAttribute:NSForegroundColorAttributeName value:[Location editForegroundColor] range:newRange];
//        [authorRangesInSurround insertObject:[NSValue valueWithRange:newRange] atIndex:index];
//        surround = attributedSurround.string;
//    }
//}
//
//-(void)removeAuthorAtIndex:(NSInteger)index{
//    NSString* authorString = [surround substringWithRange:[authorRangesInSurround objectAtIndex:index].rangeValue];
//    if (index==authorRangesInSurround.count-1 && authorRangesInSurround.count>1) { //last of several
//        [self tryRemoveAmpersandBetween:[authorRangesInSurround objectAtIndex:index-1].rangeValue and:[authorRangesInSurround objectAtIndex:index].rangeValue addingComma:NO];
//        if (authorRangesInSurround.count>2 && ![Location isEtAl:authorString]) {
//            [self tryInsertAmpersandBetween:[authorRangesInSurround objectAtIndex:index-2].rangeValue and:[authorRangesInSurround objectAtIndex:index-1].rangeValue deletingComma:YES];
//        }
//    }else if (index==0 && authorRangesInSurround.count>1){ //if this is first: remove amp / comma after
//        [self tryRemoveAmpersandBetween:[authorRangesInSurround objectAtIndex:index].rangeValue and:[authorRangesInSurround objectAtIndex:index+1].rangeValue addingComma:NO];
//        [self tryDeletingCommaAfter:[authorRangesInSurround objectAtIndex:index].rangeValue];
//    }
//    NSRange rangeToRemove = [[authorRangesInSurround objectAtIndex:index]rangeValue];
//    authorString = [surround substringWithRange:rangeToRemove];
//    if (rangeToRemove.location+rangeToRemove.length<attributedSurround.length) {
//        unichar c = [attributedSurround.string characterAtIndex:rangeToRemove.location+rangeToRemove.length];
//        if (c==',') rangeToRemove = NSMakeRange(rangeToRemove.location, rangeToRemove.length+1);
//    }
//    [self tryRemoveEmptySpaceFrom:rangeToRemove.location+rangeToRemove.length goingForward:YES flexible:NO];
//    [self modifyRangesAfterModification:rangeToRemove.location byOffest:-rangeToRemove.length including:NO];
//    [authorRangesInSurround removeObjectAtIndex:index];
//    [attributedSurround deleteCharactersInRange:rangeToRemove];
//    [attributedSurround addAttribute:NSBackgroundColorAttributeName value:[Location editBackgroundColor] range:NSMakeRange(rangeToRemove.location, rangeToRemove.length)];
//}
//
//-(void)editYear:(NSString *)newYear{
//    NSRange newYearRange = yearRangeInSurround;
//    if (newYear.length!=yearRangeInSurround.length) {
//        NSInteger diff = newYear.length-yearRangeInSurround.length;
//        [self modifyRangesAfterModification:yearRangeInSurround.location byOffest:diff including:NO];
//        newYearRange = NSMakeRange(yearRangeInSurround.location, newYear.length);
//    }
//    [attributedSurround replaceCharactersInRange:yearRangeInSurround withString:newYear];
//    [attributedSurround addAttribute:NSForegroundColorAttributeName value:[Location editForegroundColor] range:newYearRange];
//    surround=attributedSurround.string;
//    yearRangeInSurround = newYearRange;
//}
//
//-(void)tryInsertAmpersandBetween:(NSRange)rng1 and:(NSRange)rng2 deletingComma:(BOOL)delComma{
//    NSInteger endOfR1Pos = rng1.location+rng1.length;
//    if (delComma && [attributedSurround.mutableString characterAtIndex:endOfR1Pos]==','){
//        [attributedSurround.mutableString deleteCharactersInRange:NSMakeRange(endOfR1Pos, 1)];
//        [self modifyRangesAfterModification:rng1.location byOffest:-1 including:NO];
//    }
//    for (NSInteger i=endOfR1Pos; i<rng2.location; i++) {
//        unichar c= [attributedSurround.mutableString characterAtIndex:i];
//        if ([[NSCharacterSet whitespaceCharacterSet]characterIsMember:c]) continue;
//        else return;
//    }
//    NSRange inbetweener = NSMakeRange(endOfR1Pos, rng2.location-endOfR1Pos);
//    NSString* rep = @" & ";
//    [attributedSurround.mutableString replaceCharactersInRange:inbetweener withString:rep];
//    [self modifyRangesAfterModification:rng1.location byOffest:(rep.length-inbetweener.length) including:NO];
//    surround = attributedSurround.string;
//}
//
//-(void)tryRemoveAmpersandBetween:(NSRange)rng1 and:(NSRange)rng2 addingComma:(BOOL)comma{
//    NSInteger gapPos = rng1.location+rng1.length;
//    NSRange inbetween = NSMakeRange(gapPos, rng2.location-gapPos);
//    NSMutableString* gap = [NSMutableString stringWithString:[attributedSurround.mutableString substringWithRange:inbetween]];
//    NSRange andRange;
//    
//    if ([gap containsString:@" & "]) {
//        andRange = [gap rangeOfString:@" & "];
//        [gap replaceCharactersInRange:andRange withString:@" "];
//    }else if ([gap containsString:@" and "]){
//        andRange = [gap rangeOfString:@" and "];
//        [gap replaceCharactersInRange:andRange withString:@" "];
//    }else if ([gap containsString:@" And "]){
//        andRange = [gap rangeOfString:@" And "];
//        [gap replaceCharactersInRange:andRange withString:@" "];
//    }else if (comma){
//        NSInteger loc = rng1.location+rng1.length;
//        if ([attributedSurround.mutableString characterAtIndex:loc]!=',') {
//            [attributedSurround.mutableString insertString:@"," atIndex:loc];
//            [self modifyRangesAfterModification:loc byOffest:1 including:YES];
//        }
//        return;
//    }
//    
//    if (comma) {
//        unichar c = [gap characterAtIndex:0];
//        if (c!=','){
//            [gap insertString:@"," atIndex:0];
//        }
//    }
//    NSInteger diff = (gap.length-inbetween.length);
//    
//    [self modifyRangesAfterModification:rng1.location byOffest:diff including:NO];
//    [attributedSurround.mutableString replaceCharactersInRange:inbetween withString:gap];
//}
//
//-(void)tryInsertCommaAfter:(NSRange)rng{
//    NSInteger loc = rng.location+rng.length;
//    if ([attributedSurround.mutableString characterAtIndex:loc]!=',') {
//        [attributedSurround.mutableString insertString:@"," atIndex:loc];
//        [self modifyRangesAfterModification:rng.location byOffest:1 including:NO];
//    }
//}
//
//-(void)tryDeletingCommaAfter:(NSRange)rng{
//    NSInteger loc = rng.location+rng.length;
//    if ([attributedSurround.mutableString characterAtIndex:loc]==','){
//        [attributedSurround.mutableString deleteCharactersInRange:NSMakeRange(loc, 1)];
//        [self modifyRangesAfterModification:rng.location byOffest:-1 including:NO];
//    }
//}
//
//-(void)tryRemoveEmptySpaceFrom:(NSInteger)point goingForward:(BOOL)forward flexible:(BOOL)flexible{
//    int diff = 0;
//    BOOL started = flexible? false:true;
//    for (NSInteger i = point; (forward? i<surround.length:i>=0); (forward? i++:i--)) {
//        unichar c = [attributedSurround.string characterAtIndex:i];
//        if ([[NSCharacterSet whitespaceCharacterSet]characterIsMember:c]) {
//            if (!started){
//                started = TRUE;
//                point = i;
//            }
//            diff++;
//        }else if(!started) continue;
//        else break;
//    }
//    if (!diff) return;
//    if (!forward) point -=diff;
//    NSRange removerng = NSMakeRange(point, diff);
//    [attributedSurround deleteCharactersInRange:removerng];
//    //surround = attributedSurround.string;
//    [self modifyRangesAfterModification:point byOffest:-diff including:NO];
//}
//
//-(NSMutableArray<NSValue*> *)getAllRangesInOrder{
//    NSMutableArray* out = [[NSMutableArray alloc]initWithCapacity:1+authorRangesInSurround.count];
//    [out addObject:[NSValue valueWithRange:yearRangeInSurround]];
//    [out addObjectsFromArray:authorRangesInSurround];
//    [out sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//        NSValue *v1 = (NSValue*)obj1;
//        NSValue*v2 = (NSValue*)obj2;
//        if (v1.rangeValue.location>v2.rangeValue.location) {
//            return NSOrderedDescending;
//        }else if (v2.rangeValue.location>v1.rangeValue.location) return NSOrderedAscending;
//        else return NSOrderedSame;
//    }];
//    return out;
//}
//
//-(void)modifyRangesAfterModification:(NSInteger)pos byOffest:(NSInteger)off including:(BOOL)inc{
//    for (NSInteger i=0; i<authorRangesInSurround.count; i++) {
//        NSRange rng = [[authorRangesInSurround objectAtIndex:i]rangeValue];
//        if ((inc? rng.location>=pos : rng.location>pos)){
//            NSValue* rngVal = [NSValue valueWithRange:NSMakeRange(rng.location+off, rng.length)];
//            [authorRangesInSurround replaceObjectAtIndex:i withObject:rngVal];
//        }
//    }
//    if (yearRangeInSurround.location > (inc? pos-1:pos)) {
//        yearRangeInSurround = NSMakeRange(yearRangeInSurround.location+off, yearRangeInSurround.length);
//    }
//}

+(NSComparator)rangeComparator{
    NSComparator out = ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSRange r1 = ((NSValue*)obj1).rangeValue;
        NSRange r2 = ((NSValue*)obj2).rangeValue;
        if (r1.location>r2.location) return NSOrderedDescending;
        else if (r1.location<r2.location) return NSOrderedAscending;
        else{
            if (r1.length>r2.length) return NSOrderedDescending;
            else if (r1.length<r2.length) return  NSOrderedAscending;
            else return NSOrderedSame;
        }
    };
    return out;
}

+(BOOL)isEtAl:(NSString *)str{
    str = [[str lowercaseString]stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
    if ([str isEqualToString:@"et al"] || [str isEqualToString:@"et. al"] || [str isEqualToString:@"etal"]
        || [str isEqualToString:@"et.al"] || [str isEqualToString:@"et-al"]) {
        return TRUE;
    }return FALSE;
}

+(NSColor *)editBackgroundColor{
    return [NSColor colorWithCalibratedRed:1 green:.3 blue:.3 alpha:.4];
}

+(NSColor *)editForegroundColor{
    return [NSColor colorWithCalibratedRed:.5 green:0 blue:0 alpha:1];
}

+(NSColor*)boringForegoundColor{
    return [NSColor colorWithCalibratedWhite:0 alpha:.5];
}

-(NSAttributedString *)getSurroundFromSource:(NSAttributedString *)source{
    NSRange totalRange = [CitationIterator mergeRanges:self.authorRangesInSource];
    totalRange = [CitationIterator mergeRanges:totalRange and:[self yearRangeInSource]];
    NSInteger bottom = totalRange.location>150? totalRange.location-150:0;
    NSInteger top = totalRange.location+totalRange.length+150<source.length? totalRange.location+totalRange.length+150:source.length;
    
    NSRange surroundRange = NSMakeRange(bottom, top-bottom);
    NSMutableAttributedString* out = [[NSMutableAttributedString alloc]initWithAttributedString:[source attributedSubstringFromRange:surroundRange]];
    
    for (NSInteger i=0; i<out.length; i++) {
        NSDictionary* atts = [out attributesAtIndex:i effectiveRange:nil];
        NSColor* col = [atts valueForKey:NSForegroundColorAttributeName];
        if (!col) col = [NSColor colorWithCalibratedWhite:0 alpha:1];
        col = [col colorWithAlphaComponent:.5];
        for (NSInteger k=0; k<authorRangesInSource.count; k++){
            NSValue* val = [authorRangesInSource objectAtIndex:k];
            NSRange rng = [CitationIterator transformRange:val.rangeValue withinRange:surroundRange];
            if (i >=rng.location && i<rng.location+rng.length) {
                goto here;
            }
        }
        NSRange rng = [CitationIterator transformRange:yearRangeInSource withinRange:surroundRange];
        if (i>=rng.location && i<rng.location+rng.length) {
            goto here;
        }
        [out addAttribute:NSForegroundColorAttributeName value:col range:NSMakeRange(i, 1)];
    here: continue;
    }
    return out;
}

@end
