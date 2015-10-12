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
        ///method here
    }
    return self;
}


+(Name*)getNameFromString:(NSString *)name{
    NSCharacterSet* empties = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSMutableCharacterSet* delimiters = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [delimiters addCharactersInString:@".,"];
    
    Name * out = [[Name alloc]init];
    if ([name containsString:@","]){ //get the surname, then parse for first names after comma
        for (int i=0; i<name.length; i++) {
            unichar c=[name characterAtIndex:i];
            if (c!=',') continue;
            
            out.surname = [name substringToIndex:i];
            out.surname = [out.surname capitalizedString];
            name = [name substringFromIndex:i+1];
            name = [name stringByTrimmingCharactersInSet:empties];
            break;
        }
        NSArray *arr1 = [name componentsSeparatedByCharactersInSet:delimiters];
        for (int i=(int)arr1.count-1; i>=0; i--) {
            NSString* n = [arr1 objectAtIndex:i];
            n = [n capitalizedString];
            //n= [n stringByTrimmingCharactersInSet:empties]; //not needed! as spliterating the name does this
            if (n.length>0){
                [out.forenameArray addObject:n];
            }
        }
        return out;
    }else{ ///no commas, treat final word as surname, other as first names in order
        NSArray* ar1 = [name componentsSeparatedByCharactersInSet:delimiters];
        NSMutableArray *arr2 = [[NSMutableArray alloc]init];
        for (int i=0; i<ar1.count; i++) {
            NSString * str = [ar1 objectAtIndex:i];
            str = [str capitalizedString];
            //str = [str stringByTrimmingCharactersInSet:empties]; //ditto
            if (str.length>0) [arr2 addObject:str];
        }
        if (arr2.count>0){
            out.surname = [arr2 objectAtIndex:arr2.count-1];
            [arr2 removeObjectAtIndex:arr2.count-1];
        }
        out.forenameArray = arr2;
        return out;
    }
}

-(BOOL)isEqualToName:(Name *)nm{
    if (![self.surname isEqualToString:nm.surname])return FALSE;
    if (self.forenameArray.count!=nm.forenameArray.count) return FALSE;
    for (NSInteger i=0;i<self.forenameArray.count;i++){
        NSString* n1 = [self.forenameArray objectAtIndex:i];
        NSString *n2 = [nm.forenameArray objectAtIndex:i];
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

@end
