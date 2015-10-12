//
//  SplitViewDelegate.m
//  CitationTool3
//
//  Created by Thomas Gray on 26/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "SplitViewDelegate.h"

@implementation SplitViewDelegate

-(CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex{
    return 100;
}

-(CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex{
    if (splitView.vertical){
        return splitView.window.frame.size.width-120;
    }else return splitView.window.frame.size.height-100;
}

//-(CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex{
//    return 100;
//}

-(BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview{
    return TRUE;
}

@end
