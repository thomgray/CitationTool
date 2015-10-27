//
//  Bibliography.h
//  CitationTool3
//
//  Created by Thomas Gray on 20/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reference.h"
#import "Citation.h"

@interface Bibliography : NSObject

@property NSMutableArray *references;
@property NSString* name;
@property NSString* path;

-(instancetype)initWithFile:(NSString*)path;

+(instancetype)mergeBibliographies:(NSArray*)bibs;

+(NSMutableArray<Reference*>*)allReferences:(NSArray<Bibliography*>*)bibs;
+(void)addReferencesFrom:(Bibliography*)bib toReferenceArray:(NSMutableArray<Reference*>*)refs;

-(void)sortReferencesByKeys:(NSArray<NSString*>*)keys;
-(void)saveToBibFile;


@end
