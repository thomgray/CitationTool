//
//  Location.h
//  CitationParser
//
//  Created by Thomas Gray on 14/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Location : NSObject

@property (nonatomic) NSString* surround;
@property NSMutableAttributedString* attributedSurround;
@property NSRange range;
@property NSMutableArray<NSValue*>* authorRangesInSurround;
@property NSRange yearRangeInSurround;

-(instancetype)initWithRange:(NSRange)rng;

-(void)setSurround:(NSString *)surround;

-(NSComparisonResult)compare:(id)in;
-(void)offsetRange:(NSInteger)offset;

-(void)editYear:(NSString*)newYear;
-(void)editAuthor:(NSString*)newAuthor at:(NSInteger)index inserting:(BOOL)insert;
-(void)removeAuthorAtIndex:(NSInteger)index;

@end
