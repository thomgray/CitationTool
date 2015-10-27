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
#import "AppDelegate.h"
#import "CiteListRow.h"
#import "MainWindow.h"

@interface CitationModel(Private)

-(void)setListCellsState:(NSInteger)state;
-(void) amendLocation:(NSMutableArray *)locations newCitations:(NSMutableArray *)newCits withOldCitations:(NSMutableArray *)oldCits atIndex:(NSInteger)index;

-(NSMutableArray*)getAllLocationsForCitations:(NSArray*)cits;
-(void)loadDataAtPath:(NSString*)path withSource:(NSMutableAttributedString*)source andRefDictionary:(NSMutableDictionary*)dic;

@end

@implementation CitationModel

@synthesize tableData;
@synthesize citations;
@synthesize bibliographies;
@synthesize references;
@synthesize defaultBibIndex;

-(void)setCitations:(NSMutableArray *)clist{
    citations = clist;
    tableData = [[NSMutableArray alloc]initWithArray:citations];    
    citeCountListOns = [[NSMutableArray alloc]init];
}

-(NSString *)getCitedReferences{
    NSMutableString* out = [[NSMutableString alloc]init];
    for (NSInteger i=0; i<citations.count; i++){
        Citation* cit = [citations objectAtIndex:i];
        if (cit.reference) {
            [out appendFormat:@"\n\n%@", [cit.reference getTexString]];
        }else if (cit.possibleReferences.count==1){
            [out appendFormat:@"\n\n%@", [[cit.possibleReferences objectAtIndex:0] getTexString]];
        }
    }
    return [NSString stringWithString:out];
}

-(void)refreshBibliography{
    [bibliographyView setString:@""];
    for (NSInteger i=0; i<citations.count; i++) {
        Citation* cit = [citations objectAtIndex:i];
        if (cit.reference) {
            NSMutableAttributedString* append = [[NSMutableAttributedString alloc]initWithAttributedString:[cit.reference getReferenceCompleteString]];
            NSRange rng = [append.string rangeOfString:[cit.reference.fields valueForKey:YEAR]];
            if (rng.location!=NSNotFound) {
                [append replaceCharactersInRange:rng withString:cit.yearString];
            }
            
            [bibliographyView.textStorage appendAttributedString:append];
        }else if (cit.possibleReferences.count==1){
            Reference* ref = [cit.possibleReferences objectAtIndex:0];
            NSMutableAttributedString* append = [[NSMutableAttributedString alloc]initWithAttributedString:[ref getReferenceCompleteString]];
            NSRange rng = [append.string rangeOfString:[ref.fields valueForKey:YEAR]];
            if (rng.location!=NSNotFound) {
                [append replaceCharactersInRange:rng withString:cit.yearString];
            }
            
            [bibliographyView.textStorage appendAttributedString:append];
        }else{
            NSString* citstring = [cit toString];
            NSAttributedString* attStr = [[NSAttributedString alloc]initWithString:citstring attributes:@{NSForegroundColorAttributeName:[NSColor redColor]}];
            [bibliographyView.textStorage appendAttributedString:attStr];
        }
        
        if (i<citations.count-1) {
            [bibliographyView.textStorage appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n\n"]];
        }
    }
}

#pragma mark Table View Methods

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return tableData.count;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    [sourceView clearHighlights];
    NSTableView* tview = notification.object;
    NSInteger selRow = [tview selectedRow];
    if (selRow>=0) {
        [tview scrollRowToVisible:selRow];
    }
    for (NSInteger i=0;i<tableData.count;i++){
        id thing = [tableData objectAtIndex:i];
        if ([thing isMemberOfClass:[Location class]]) {
            NSTableCellView* view = (NSTableCellView*)[citeTable viewAtColumn:2 row:i makeIfNecessary:NO];
            [view.imageView setImage: [AppDelegate getImageNamed:@"viewIconGreyBorderless_17"]];
        }
    }
    if (selRow<0) return;
    else if (![[tableData objectAtIndex:selRow]isMemberOfClass:[Location class]]) return;
    NSTableCellView* view = (NSTableCellView*)[tview viewAtColumn:2 row:selRow makeIfNecessary:NO];
    [view.imageView setImage:[AppDelegate getImageNamed:@"viewIconGreyBorderedWhiteFill_17"]];
    Location* loc = [tableData objectAtIndex:selRow];
    NSArray<NSValue*>* ranges = [loc getAllRangesInSourceInExplicitOrder:NO];
    for (NSInteger l=0; l<ranges.count; l++) {
        NSValue* val = [ranges objectAtIndex:l];
        NSRange rng = val.rangeValue;
        [sourceView highlightSelectionInRange:rng extendingSelection:YES];
    }
    //[sourceView highlightSelectionInRange:loc.range extendingSelection:NO];
    [sourceView scrollRangeToVisible:loc.range];
}

-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString * identifier= [tableColumn identifier];
    id value = [tableData objectAtIndex:row];
    if ([value isMemberOfClass:[Citation class]]) {
        Citation * cit = (Citation*)value;
        if ([identifier isEqualToString:@"count"]) {
            NSString* str = [NSString stringWithFormat:@"%ld", [cit.locations count]];
            CountCellView * view = [tableView makeViewWithIdentifier:@"count" owner:self];
            NSButton* butt = [view.subviews firstObject];
            [butt setImage:[AppDelegate getImageNamed:@"listIconUp_17"]];
            [butt setAlternateImage:[AppDelegate getImageNamed:@"emptyIconUp_17"]];
            [view.textField setStringValue:str];
            [view setButtonToggleStatus:[citeCountListOns containsObject:cit]? 1:0];
            return view;
        }else if ([identifier isEqualToString:@"authors"]){
            NSTableCellView * cell = [tableView makeViewWithIdentifier:@"authors" owner:self];
            [cell.textField setStringValue:[cit authorsStringWithFinalDelimiter:@"&"]];
            NSButton* but = [cell.subviews firstObject];
            [but setImage:[AppDelegate getImageNamed:@"editIconUp_17"]];
            [but setAlternateImage:[AppDelegate getImageNamed:@"editIconDown_17"]];
            return cell;
        }else if ([identifier isEqualToString:@"year"]){
            NSTableCellView * cell =  [tableView makeViewWithIdentifier:@"year" owner:self];
            [cell.textField setStringValue:[cit yearString]];
            return cell;
        }else if ([identifier isEqualToString:@"references"]){
            NSTableCellView * cell = [tableView makeViewWithIdentifier:@"references" owner:self];
            cell.textField.stringValue = [NSString stringWithFormat:@"%ld", cit.possibleReferences.count];
            if (cit.reference) {
                [cell.imageView setImage:[AppDelegate getImageNamed:@"tickBlue_15"]];
            }else if (cit.possibleReferences.count==1){
                [cell.imageView setImage:[AppDelegate getImageNamed:@"questionBlue_15"]];
            }else if (cit.possibleReferences.count>1){
                [cell.imageView setImage:[AppDelegate getImageNamed:@"ellipsisRed_15"]];
            }else{
                [cell.imageView setImage:[AppDelegate getImageNamed:@"exclamationRed_15"]];
            }
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
            [out.imageView setImage:[AppDelegate getImageNamed:@"viewIconGreyBorderless_17"]];
            //NSButton* but = [out.subviews firstObject];
            //NSImage* butDown = [[NSImage alloc]initWithContentsOfFile:[iconPath stringByAppendingString:@"viewIconDown_15.png"]];
            //[but setImage:[AppDelegate getImageNamed:@"viewIconBorderless_15"]];
            //[but setAlternateImage:butDown];
            return out;
        }
    }
    return nil;
}

-(NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row{
    id rowItem = [tableData objectAtIndex:row];
    BOOL isLoc = [rowItem isMemberOfClass:[Location class]];
    CiteListRow* out = [[CiteListRow alloc]init];
    [out setLocation:isLoc];
    return out;
}

-(void)tableViewSelectionIsChanging:(NSNotification *)notification{
    
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
    [sourceView clearHighlights];
    NSInteger buttonRow = [citeTable rowForView:sender];
    Citation * cit = [tableData objectAtIndex:buttonRow];
    buttonRow = [citations indexOfObject:cit];
    //Citation *cit = [tableData objectAtIndex:buttonRow];
    NSTableCellView * cell = (NSTableCellView*) [sender superview];
    
    editorController = [[EditorController alloc]initWithCitations:citations startingAt:buttonRow]; //Fixed button row: find the citaiton in the citation list (rather than the table data
    [editorController setSourceView:sourceView];
    [editorController setModel:self];
    editorController.references = references;
    editorController.bibliographies = bibliographies;
    NSMutableAttributedString* sourceCopy = [[NSMutableAttributedString alloc]initWithAttributedString:[[sourceView attributedString]copy]];
    [editorController setSourceCopy:sourceCopy];
    [editorController setDefaultBibIndexForRefEntryPanel:defaultBibIndex];

    [editorController showWindow:cell];
    [editorController runModal];
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

-(void)refreshReferences{
    for (NSInteger i=0; i<citations.count; i++) {
        Citation* cit = [citations objectAtIndex:i];
        for (NSInteger j=0; j<references.count; j++) {
            Reference* ref = [references objectAtIndex:j];
            if (![cit.possibleReferences containsObject:ref] && [ref matchesCitation:cit]) {
                [cit.possibleReferences addObject:ref];
            }
        }
    }
    [citeTable reloadData];
}

-(void)updateCitations:(NSMutableArray *)cits{
    citations = cits;
    [tableData removeAllObjects];
    [tableData addObjectsFromArray:citations];
    [citeTable reloadData];
}

-(void)updateSource:(NSAttributedString *)str{
    [sourceView.textStorage setAttributedString:str];
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
    for (NSInteger i=0; i<cits.count; i++){
        Citation* cit = [cits objectAtIndex:i];
        [out addObjectsFromArray:cit.locations];
    }
    [out sortUsingSelector:@selector(compare:)];
    return out;
}


#pragma mark Text View Methods:


-(void)textViewDidChangeSelection:(NSNotification *)notification{
    NSInteger i = [citeTable selectedRow];
    
    [citeTable deselectRow:i];
    [sourceView clearHighlights];
}

#pragma mark Saving

-(void)saveProgressAtPath:(NSString *)path{
    NSMutableString* savedData =[[NSMutableString alloc]init];
    [savedData appendFormat:@"<sourceString>%@</sourceString>\n", sourceView.string];
    [savedData appendString:@"<citationReferences>"];
    for (NSInteger k=0; k<citations.count; k++){
        Citation* cit = [citations objectAtIndex:k];
//        if (cit.reference) {
        NSString* dicEntryString = [NSString stringWithFormat:@"{%@}{%@}", [cit toString], (cit.reference? [cit.reference getReferenceCompleteString].string:@"n")];
            [savedData appendFormat:@"%@", dicEntryString];
//        }
    }
    [savedData appendString:@"</citationReferences>"];
    [savedData writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


-(void)openSavedProject:(NSString *)path{
    NSMutableAttributedString* newsource = [[NSMutableAttributedString alloc]init];
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    @try {
        [self loadDataAtPath:path withSource:newsource andRefDictionary:dic];
    }
    @catch (NSException *exception) {
        return;
    }
    
    [sourceView.textStorage setAttributedString:newsource];
    [(MainWindow*)self.window getCitations:nil];
    
    NSMutableIndexSet* citsToRemove = [[NSMutableIndexSet alloc]init];
    for (NSInteger i=0; i<citations.count; i++) {
        Citation* cit = [citations objectAtIndex:i];
        NSString* citKey = [cit toString];
        NSString* val = [dic valueForKey:citKey];
        if (!val) {
            [citsToRemove addIndex:i];
        }
    }
    [citations removeObjectsAtIndexes:citsToRemove];
    for (NSInteger l=0; l<citations.count; l++) {
        Citation* cit = [citations objectAtIndex:l];
        NSString* key = [cit toString];
        NSString* val = [dic valueForKey:key];
        if ([val isEqualToString:@"n"]){
        }else{
            for (NSInteger k=0; k<references.count; k++) {
                Reference* ref = [references objectAtIndex:k];
                NSString* refKey = [ref getReferenceCompleteString].string;
                if ([refKey isEqualToString:val]) {
                    [cit setReference:ref];
                    break;
                }
            }
        }
    }
    [self updateCitations:citations];
    [self refreshBibliography];
}

-(void)loadDataAtPath:(NSString *)path withSource:(NSMutableAttributedString *)source andRefDictionary:(NSMutableDictionary *)dic{
    [source.mutableString setString:@""];
    [dic removeAllObjects];
    NSString* data = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSRange sourceMarkerBegin = [data rangeOfString:@"<sourceString>" options:NSLiteralSearch range:NSMakeRange(0, data.length)];
    NSRange sourceMarkerEnd = [data rangeOfString:@"</sourceString>" options:NSLiteralSearch range:NSMakeRange(sourceMarkerBegin.location, data.length-sourceMarkerBegin.location)];
    NSString* sourcefromdata = [data substringWithRange:NSMakeRange(sourceMarkerBegin.location+sourceMarkerBegin.length, sourceMarkerEnd.location-sourceMarkerBegin.location-sourceMarkerBegin.length)];
    [source appendAttributedString:[[NSAttributedString alloc]initWithString:sourcefromdata]];

    data = [data substringFromIndex:sourceMarkerEnd.location+sourceMarkerEnd.length];
    NSRange dicMarkerStart = [data rangeOfString:@"<citationReferences>" options:NSLiteralSearch];
    NSInteger start = dicMarkerStart.location+dicMarkerStart.length;
    NSRange dicMarkerEnd = [data rangeOfString:@"</citationReferences>" options:NSLiteralSearch range:NSMakeRange(dicMarkerStart.location, data.length-dicMarkerStart.location)];
    NSRange dicRange = NSMakeRange(start, dicMarkerEnd.location-start);
    
    NSString* dicString = [data substringWithRange:dicRange];
    for (NSInteger i=0; i<dicString.length; i++) {
        unichar c = [dicString characterAtIndex:i];
        if (c=='{') {
            NSString* key;
            i++;
            int lr=1;
            for (NSInteger j=i; j<dicString.length; j++) {
                unichar d = [dicString characterAtIndex:j];
                if (d=='{')lr++;
                else if (d=='}')lr--;
                if (lr==0) {
                    NSRange keyRange = NSMakeRange(i, j-i);
                    key = [dicString substringWithRange:keyRange];
                    i=j+2;
                    break;
                }
            }
            lr=1;
            for (NSInteger j=i; j<dicString.length; j++) {
                unichar d = [dicString characterAtIndex:j];
                if (d=='{') lr++;
                else if (d=='}') lr--;
                if (lr==0) {
                    NSRange valRange = NSMakeRange(i, j-i);
                    NSString* val = [dicString substringWithRange:valRange];
                    [dic setObject:val forKey:key];
                    i=j;
                    break;
                }
            }
            
        }
    }
    
    
}









@end
