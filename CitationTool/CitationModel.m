//
//  CitationModel.m
//  CitationTool3
//
//  Created by Thomas Gray on 21/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "CitationModel.h"
#import "Location.h"
#import "CountCellView.h"
#import "CitationEditorPanel.h"


@interface CitationModel(Private)

-(void)setListCellsState:(NSInteger)state;
-(void) amendLocation:(NSMutableArray *)locations newCitations:(NSMutableArray *)newCits withOldCitations:(NSMutableArray *)oldCits atIndex:(NSInteger)index;

-(NSMutableArray*)getAllLocationsForCitations:(NSArray*)cits;

@end

@implementation CitationModel

@synthesize tableData;
@synthesize citations;
@synthesize bibliographies;
@synthesize references;

- (instancetype)init{
    self = [super init];
    if (self) {
    ///NO NEED TO INIT THE CITATIONS ARRAY&
    }
    return self;
}

-(void)setCitations:(NSMutableArray *)clist{
    citations = clist;
    tableData = [[NSMutableArray alloc]initWithArray:citations];    
    citeCountListOns = [[NSMutableArray alloc]init];
}

#pragma mark Table View Methods

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return tableData.count;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSTableView* tview = notification.object;
    NSInteger selRow = [tview selectedRow];
    [tview scrollRowToVisible:selRow];
}

-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString * identifier= [tableColumn identifier];
    id value = [tableData objectAtIndex:row];
    if ([value isMemberOfClass:[Citation class]]) {
        Citation * cit = (Citation*)value;
        if ([identifier isEqualToString:@"count"]) {
            NSString* str = [NSString stringWithFormat:@"%ld", [cit.locations count]];
            CountCellView * view = [tableView makeViewWithIdentifier:@"count" owner:self];
            [view.textField setStringValue:str];
            [view setButtonToggleStatus:[citeCountListOns containsObject:cit]? 1:0];
            return view;
        }else if ([identifier isEqualToString:@"authors"]){
            NSTableCellView * cell = [tableView makeViewWithIdentifier:@"authors" owner:self];
            [cell.textField setStringValue:[cit authorsString]];
            return cell;
        }else if ([identifier isEqualToString:@"year"]){
            NSTableCellView * cell =  [tableView makeViewWithIdentifier:@"year" owner:self];
            [cell.textField setStringValue:[cit yearString]];
            return cell;
        }else if ([identifier isEqualToString:@"references"]){
            NSTableCellView * cell = [tableView makeViewWithIdentifier:@"references" owner:self];
            cell.textField.stringValue = [NSString stringWithFormat:@"%ld", cit.possibleReferences.count];
            return cell;
        }
    }else if ([value isMemberOfClass:[Location class]]){
        //Location *loc = (Location*)value;
        if ([identifier isEqualToString:@"authors"]) {
            return [tableView makeViewWithIdentifier:@"blankAuthors" owner:self];
        }else if ([identifier isEqualToString:@"year"]){
            return [tableView makeViewWithIdentifier:@"blankYear" owner:self];
        }else if ([identifier isEqualToString:@"count"]){
            NSTableCellView * out = [tableView makeViewWithIdentifier:@"location" owner:self];
            return out;
        }
    }
    return nil;
}


#pragma mark Actions:

- (IBAction)listClick:(id)sender {
    NSInteger buttonRow = [citeTable rowForView:sender];
    Citation *cit = [tableData objectAtIndex:buttonRow];
    NSButton * but = (NSButton*)sender;
    NSInteger state = [but state];
    if (!state) { ///means it's just been turned off: clean up locations
        [citeCountListOns removeObject:cit];
        NSRange range = NSMakeRange([tableData indexOfObject:cit]+1, cit.locations.count);
        NSIndexSet* indexes = [NSIndexSet indexSetWithIndexesInRange:range];
        [tableData removeObjectsAtIndexes:indexes];
        [citeTable removeRowsAtIndexes:indexes withAnimation:NSTableViewAnimationSlideUp];
    }else{ ///its been turned on, so add the locations:
        if (![citeCountListOns containsObject:cit]) [citeCountListOns addObject:cit];
        NSRange range = NSMakeRange([tableData indexOfObject:cit]+1, cit.locations.count);
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];
        [tableData insertObjects:cit.locations atIndexes:indexes];
        [citeTable insertRowsAtIndexes:indexes withAnimation:NSTableViewAnimationSlideDown];
    }
}


- (IBAction)advancedButtonClick:(id)sender {
    NSInteger buttonRow = [citeTable rowForView:sender];
    Citation * cit = [tableData objectAtIndex:buttonRow];
    buttonRow = [citations indexOfObject:cit];
    //Citation *cit = [tableData objectAtIndex:buttonRow];
    NSTableCellView * cell = (NSTableCellView*) [sender superview];
    if (!editorController) {
        editorController = [[EditorController alloc]initWithCitations:citations startingAt:buttonRow]; //Fixed button row: find the citaiton in the citation list (rather than the table data
        [editorController setSourceView:sourceView];
        [editorController setModel:self];
        editorController.references = references;
        editorController.bibliographies = bibliographies;
    }else{
        [editorController setCiteList:citations];
        [editorController setIndex:buttonRow];
        
    }
    [editorController showWindow:cell];
}

-(IBAction)viewClick:(id)sender{
    NSInteger i = [citeTable rowForView:sender];
    Location* loc = [tableData objectAtIndex:i];
    [sourceView highlightSelectionInRange:loc.range extendingSelection:NO];
    [sourceView scrollRangeToVisible:loc.range];
}

-(void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn{
    NSString* identifier = tableColumn.identifier;
    
    if ([identifier isEqualToString:@"count"]) {
        CountCellView* cell = (CountCellView*)[citeTable viewAtColumn:2  row:0 makeIfNecessary:NO];
        NSButton* butt = [cell button];
        NSInteger state = !butt.state;
        
        [citeCountListOns removeAllObjects];
        if (state) [citeCountListOns addObjectsFromArray:citations];
        
        for (NSInteger i=0; i<tableData.count; i++) {
            NSView* view = [citeTable viewAtColumn:2 row:i makeIfNecessary:NO];
            if ([view.identifier isEqualToString:@"count"]){
                cell = (CountCellView*)view;
                [cell.button setState:state];
            }
        }
        [self setListCellsState:state];
    }
}

-(void)setListCellsState:(NSInteger)state{
    if (state) { //turned on so add them all
        for (NSInteger i=0; i<citations.count; i++) {
            Citation* cit = [citations objectAtIndex:i];
            if (![tableData containsObject:[cit.locations firstObject]]){
                NSInteger i = [tableData indexOfObject:cit];
                NSIndexSet* indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(i+1, cit.locations.count)];
                [tableData insertObjects:cit.locations atIndexes:indexes];
                //[citeTable insertRowsAtIndexes:indexes withAnimation:NSTableViewAnimationSlideDown];
            }
        }
        [citeTable reloadData];
    }else{ // turned off so remove them all
        for (NSInteger i=0; i<citations.count; i++) {
            Citation * cit = [citations objectAtIndex:i];
            if ([tableData containsObject:[cit.locations firstObject]]) {
                NSInteger i = [tableData indexOfObject:cit];
                NSIndexSet* indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(i+1, cit.locations.count)];
                [tableData removeObjectsAtIndexes:indexes];
                //[citeTable removeRowsAtIndexes:indexes withAnimation:NSTableViewAnimationSlideUp];
            }
        }
        [citeTable reloadData];
    }
}

-(void)mouseEntered:(NSButton *)sender{
//    NSInteger row = [citeTable rowForView:sender];
//    Location* loc = [tableData objectAtIndex:row];
//    NSString* surround = loc.surround;
//    NSTableCellView *cell = (NSTableCellView*)sender.superview;
//    
//    surroundField.stringValue = surround;
//    NSRect frame = popUpView.frame;
//    NSRect relframe = [cell convertRect:cell.bounds toView:nil];
//    frame.origin.x = relframe.origin.x - frame.size.width;
//    frame.origin.y = relframe.origin.y - frame.size.height + cell.frame.size.height/2;
//    frame.size.width = 300;
//    frame.size.height = 100;
//    
//    NSRect surroundFrame = NSMakeRect(10, 20, frame.size.width-25, frame.size.height-40);
//    
//    [popUpView setFrame:frame];
//    [surroundField setFrame:surroundFrame];
//    
//    NSView* view = citeTable.window.contentView;
//    
//    [popUpView removeFromSuperview];
//    [view addSubview:popUpView positioned:NSWindowAbove relativeTo:nil];
//    [popUpView setHidden:FALSE];
}

-(void)mouseExited:(NSButton *)sender{
//    popUpView.hidden = TRUE;
}

-(void)updateCitations:(NSMutableArray *)cits{
//    NSMutableArray* locations = [self getAllLocationsForCitations:cits];
//    NSMutableArray* oldCitations = [[NSMutableArray alloc]initWithCapacity:locations.count];
//    NSMutableArray* newCitations = [[NSMutableArray alloc]initWithCapacity:locations.count];
//    for (NSInteger i=0; i<locations.count; i++) {
//        Location* loc = [locations objectAtIndex:i];
//        for (Citation* cit in cits){
//            for (Location* l in cit.locations){
//                if ([l isEqualTo:loc]){
//                    [newCitations addObject:cit];
//                    goto here1;
//                }
//            }
//        }
//    here1:
//        for (Citation* cit in citations){
//            for (Location* l in cit.locations){
//                if ([l isEqualTo:loc]){
//                    [oldCitations addObject:cit];
//                    goto here2;
//                }
//            }
//        }
//    }
//here2:
//
//    for (NSInteger i=0; i<locations.count; i++) {
//        [self amendLocation:locations newCitations:newCitations withOldCitations:oldCitations atIndex:i];
//    }
    citations = cits;
    [tableData removeAllObjects];
    [tableData addObjectsFromArray:citations];
    [citeTable reloadData];
}


-(void)amendLocation:(NSMutableArray *)locations newCitations:(NSMutableArray *)newCits withOldCitations:(NSMutableArray *)oldCits atIndex:(NSInteger)index{
    Citation* newCit = [newCits objectAtIndex:index];
    Citation* oldCit = [oldCits objectAtIndex:index];
    NSInteger diff = 0;
    diff += ([newCit yearString].length - [oldCit yearString].length);
    
    
    for (index++; index<locations.count; index++) {
        Location * loc = [locations objectAtIndex:index];
        loc.range = NSMakeRange(loc.range.location+diff, loc.range.length);
    }
}

-(NSMutableArray *)getAllLocationsForCitations:(NSArray *)cits{
    NSMutableArray* out = [[NSMutableArray alloc]init];
    for (Citation* cit in cits){
        [out addObjectsFromArray:cit.locations];
    }
    [out sortUsingSelector:@selector(compare:)];
    return out;
}


#pragma mark Text View Methods:


-(void)textViewDidChangeSelection:(NSNotification *)notification{
    [sourceView clearHighlights];
}

@end
