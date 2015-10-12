//
//  BibFormatSpecialist.m
//  CitationTool3
//
//  Created by Thomas Gray on 23/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "BibFormatSpecialist.h"

@interface BibFormatSpecialist(Private)



@end

@implementation BibFormatSpecialist

#pragma mark Delegate Methods

+(NSString*)getString:(Reference *)ref{
    NSString* type = ref.type;
    if ([type isEqualToString:@"article"]) {
        return [BibFormatSpecialist stringForArticle:ref];
    }
    else return [BibFormatSpecialist stringForMisc:ref];
}



#pragma mark Standard Format Getters

+(NSString*)stringForArticle:(Reference*)ref{
    NSString* out = @"";
//    if (ref.authorArray.count>0) out = [out stringByAppendingFormat:@"%@; ", [BibFormatSpecialist stringFromNameArray:ref.authorArray]];
//    out = [out stringByAppendingFormat:@"%@. ", [ref.fields valueForKey:@"author"];
//    out = [out stringByAppendingFormat:@"\'%@\'. %@, ", ref.title, ref.journal];
//    NSString* volNum = [BibFormatSpecialist stringFromVolume:ref.volume andNumber:ref.number];
//    if (volNum) out = [out stringByAppendingFormat:@"%@, ", volNum];
//    if (ref.pages) out = [out stringByAppendingFormat:@"%@", [BibFormatSpecialist stringFromPages:ref.pages]];
//    
    return out;
}








+(NSString*)stringForMisc:(Reference*)ref{
    return nil;
}

+(NSString*)stringFromNameArray:(NSArray*)names{
    NSString * out = @"";
    for (int i=0; i<names.count;i++){
        Name * name = [names objectAtIndex:i];
        NSString* forenames = @"";
        for (int j=0; j<name.forenameArray.count; j++) {
            forenames = [forenames stringByAppendingFormat:@" %@", [name.forenameArray objectAtIndex:j]];
        }
        out = [out stringByAppendingFormat:@"%@", name.surname];
        if (forenames.length>0) out = [out stringByAppendingString:forenames];
        if (i==names.count-1) break;
        out = [out stringByAppendingString:@", "];
    }
    return out;
}

+(NSString*)stringFromVolume:(NSString*)volume andNumber:(NSString*)number{
    NSString* out;
    if (volume) out = volume;
    if (number && volume) return [out stringByAppendingFormat:@".%@", volume];
    else if (number) return out;
    else return nil;
}

+(NSString*)stringFromPages:(NSString*)pages{
    if (!pages) return nil;
    if ([pages containsString:@"-"]){
        return [NSString stringWithFormat:@"pp.%@", pages];
    }else return [NSString stringWithFormat:@"p.%@", pages];
}











@end
