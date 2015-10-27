//
//  SourceEditor.h
//  CitationTool
//
//  Created by Thomas Gray on 21/10/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Citation.h"

@interface SourceEditor : NSObject

@property NSMutableAttributedString* sourceString;
@property NSMutableArray<Citation*>* citations;

-(instancetype)initWithCitations:(NSMutableArray<Citation*>*)cits andSourceString:(NSMutableAttributedString*)str;

-(void)editYear:(Location*)loc newValue:(NSString*)newYear;
-(void)editYearForCitation:(Citation*)cit newValue:(NSString*)newYear dynamically:(BOOL)dyn;
-(void)editAuthor:(Location*)loc atIndex:(NSInteger)idx newAuthor:(NSString*)newAuthor inserting:(BOOL)insert;
-(void)editAuthorForCitation:(Citation*)cit atIndex:(NSInteger)idx newAuthor:(NSString*)newAuthor inserting:(BOOL)inserting dynamically:(BOOL)dyn;
-(void)removeAuthor:(Location*)loc atIndex:(NSInteger)index;
-(void)removeAuthorForCitation:(Citation*)cit atIndex:(NSInteger)index;


-(void)adjustLocationsForCitationsAtIndex:(NSInteger)i byOffset:(NSInteger)off inclusively:(BOOL)inc;


@end
