//
//  Name.h
//  CitationTool3
//
//  Created by Thomas Gray on 20/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Name : NSObject

@property NSString* surname;
@property NSString* forenames;
@property NSMutableArray* forenameArray;

-(instancetype) initFromString:(NSString*)str;
-(BOOL)isEqualToName:(Name*)nm;


+(Name*)getNameFromString:(NSString*)in;

@end
