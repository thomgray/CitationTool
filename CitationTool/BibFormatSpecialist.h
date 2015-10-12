//
//  BibFormatSpecialist.h
//  CitationTool3
//
//  Created by Thomas Gray on 23/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reference.h"

@interface BibFormatSpecialist : NSObject

+(NSString*)getString:(Reference*)ref;




#pragma mark Standard Format Getters

+(NSString*)stringForArticle:(Reference*)ref;




+(NSString*)stringForMisc:(Reference*)ref;


+(NSString*)stringFromNameArray:(NSArray*)names;
+(NSString*)stringFromPages:(NSString*)pages;
+(NSString*)stringFromVolume:(NSString*)volume andNumber:(NSString*)number;

@end
