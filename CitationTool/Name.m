//
//  Name.m
//  CitationTool3
//
//  Created by Thomas Gray on 20/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "Name.h"

@implementation Name

@synthesize surname;
@synthesize forenames;
@synthesize forenameArray;

- (instancetype)init
{
    self = [super init];
    if (self) {
        forenameArray = [[NSMutableArray alloc]init];
    }
    return self;
}

-(instancetype)initFromString:(NSString *)str{
    self = [super init];
    if (self) {
        self = [Name getNameFromString:str];
    }
    return self;
}


+(Name*)getNameFromString:(NSString *)name{
    NSCharacterSet* empties = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSMutableCharacterSet* delimiters = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [delimiters addCharactersInString:@".,"];
    
    Name * out = [[Name alloc]init];
//    if ([name containsString:@","]){ //get the surname, then parse for first names after comma
        NSInteger i=0;
        for (; i<name.length; i++) {
            unichar c=[name characterAtIndex:i];
            if (i==name.length-1){
                out.surname = name;
                return out;
            }else if (c!=',') continue;
            
            out.surname = [[name substringToIndex:i]capitalizedString];
            name = [name substringFromIndex:i+1];
            name = [name stringByTrimmingCharactersInSet:empties];
            break;
        }
        if (!name.length) return out;
        //if (i>=name.length) return out;
        NSArray *arr1 = [name componentsSeparatedByCharactersInSet:delimiters];
        for (i=0; i<arr1.count;i++) {
            NSString* n = [arr1 objectAtIndex:i];
            n = [n capitalizedString];
            //n= [n stringByTrimmingCharactersInSet:empties]; //not needed! as spliterating the name does this
            if (n.length>0){
                [out.forenameArray addObject:n];
            }
        }
        return out;
//    }else{ ///no commas, treat final word as surname, other as first names in order
//        NSArray* ar1 = [name componentsSeparatedByCharactersInSet:delimiters];
//        NSMutableArray *arr2 = [[NSMutableArray alloc]init];
//        for (int i=0; i<ar1.count; i++) {
//            NSString * str = [ar1 objectAtIndex:i];
//            str = [str capitalizedString];
//            //str = [str stringByTrimmingCharactersInSet:empties]; //ditto
//            if (str.length>0) [arr2 addObject:str];
//        }
//        if (arr2.count>0){
//            out.surname = [arr2 objectAtIndex:arr2.count-1];
//            [arr2 removeObjectAtIndex:arr2.count-1];
//        }
//        out.forenameArray = arr2;
//        return out;
//    }
}

-(NSString*)surnameWithInitials{
    NSString* inits = @"";
    for (NSInteger i=0;i<forenameArray.count; i++) {
        NSString* forename =[forenameArray objectAtIndex:i];
        if (forename.length<1)continue;
        inits = [inits stringByAppendingFormat:@"%c.", [forename characterAtIndex:0]];
    }
    return [surname stringByAppendingFormat:@" %@", inits];
}

-(BOOL)isEtAl{
    NSString* name = [[surname lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
    return [name isEqualToString:@"et al"] || [name isEqualToString:@"etal"] || [name isEqualToString:@"et-al"];
}

-(BOOL)isEqualToName:(Name *)nm{
    if (![Name string:self.surname isAlphabeticallyIdenticalTo:nm.surname]) return FALSE;
    if (self.forenameArray.count!=nm.forenameArray.count) return FALSE;
    for (NSInteger i=0;i<self.forenameArray.count;i++){
        NSString* n1 = [Name alphabeticString:[self.forenameArray objectAtIndex:i]];
        NSString *n2 = [Name alphabeticString:[nm.forenameArray objectAtIndex:i]];
        if (n1.length==1){
            unichar c=[n1 characterAtIndex:0];
            if ([n2 characterAtIndex:0]!=c) return FALSE;
        }else if (n2.length==1){
            unichar c = [n2 characterAtIndex:0];
            if ([n1 characterAtIndex:0]!=c) return FALSE;
        }else{
            if (![n1 isEqualToString:n2]) return FALSE;
        }
    }
    return TRUE;
}

-(NSComparisonResult)compare:(Name *)nm{
    NSComparisonResult out;
    out= [surname compare:nm.surname];
    if (out!=NSOrderedSame) return out;
    NSInteger cap = forenameArray.count<=nm.forenameArray.count? forenameArray.count:nm.forenameArray.count;
    for (NSInteger i=0; i<cap; i++) {
        NSString* thisinit = [[forenameArray objectAtIndex:i]substringToIndex:1];
        NSString* thatinit = [[nm.forenameArray objectAtIndex:i]substringToIndex:1];
        out = [thisinit compare:thatinit];
        if (out!=NSOrderedSame) return out;
    }
    
    if (forenameArray.count>nm.forenameArray.count) return NSOrderedDescending;
    else if (nm.forenameArray.count>forenameArray.count) return NSOrderedAscending;
    else return NSOrderedSame;
}

+(NSString *)alphabeticString:(NSString *)str{
    NSMutableString* out = [str mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)out, NULL, kCFStringTransformStripCombiningMarks, NO);
    return out;
}

+(BOOL)string:(NSString *)s1 isAlphabeticallyIdenticalTo:(NSString *)s2{
    NSMutableString* muts1 = [s1 mutableCopy];
    NSMutableString* muts2 = [s2 mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)muts1, NULL, kCFStringTransformStripCombiningMarks, NO);
    CFStringTransform((__bridge CFMutableStringRef)muts2, NULL, kCFStringTransformStripCombiningMarks, NO);
    return [muts1 isEqualToString:muts2];
}

@end
