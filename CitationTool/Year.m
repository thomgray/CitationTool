//
//  Year.m
//  CitationParser
//
//  Created by Thomas Gray on 14/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "Year.h"

@implementation Year
@synthesize year;
@synthesize modifier;

-(instancetype)init:(NSInteger)yr withMod:(unichar)mod{
    self = [super init];
    if (self){
        year = yr;
        modifier = mod;
    }
    return self;
}

-(instancetype)init:(NSInteger)yr{
    self = [super init];
    if (self){
        year = yr;
        modifier = FALSE;
    }
    return self;
}

-(NSString*)toString{
    NSString *out = [NSString stringWithFormat:@"%ld", (long) year];
    if (modifier){
        out = [out stringByAppendingFormat:@"%c", modifier];
    }
    return out;
}

-(BOOL)isEqualTo:(Year *)comp{
    if (self.year!=comp.year) return FALSE;
    if (self.modifier!=comp.modifier) return FALSE;
    return TRUE;
}

-(NSComparisonResult)compare:(id)in{
    if (![in isKindOfClass:[Year class]]) return NSOrderedSame;
    Year* other = (Year*)in;
    if (self.year>other.year) return NSOrderedDescending;
    else if (self.year<other.year) return NSOrderedAscending;
    else if (!self.modifier) return NSOrderedAscending;
    else if (!other.modifier) return NSOrderedDescending;
    else{
        if (self.modifier<other.modifier) return NSOrderedAscending;
        else if (self.modifier>other.modifier) return NSOrderedDescending;
    }
    return NSOrderedSame;
}

@end
