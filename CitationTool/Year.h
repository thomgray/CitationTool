//
//  Year.h
//  CitationParser
//
//  Created by Thomas Gray on 14/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Year : NSObject

@property (readwrite) NSInteger year;
@property (readwrite) unichar modifier;

-(instancetype)init:(NSInteger) yr withMod:(unichar)mod;
-(instancetype)init:(NSInteger) yr;

-(NSString*)toString;
-(BOOL)isEqualTo:(Year*) comp;

-(NSComparisonResult)compare:(id)in;

@end
