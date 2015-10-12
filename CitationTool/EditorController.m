//
//  EditorController.m
//  CitationTool3
//
//  Created by Thomas Gray on 22/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "EditorController.h"
#import "BibFormatSpecialist.h"
#import "ReferenceRow.h"
#import "CustomRow.h"

@interface EditorController (){
    NSIndexSet * recentlyAddedAuthorIndex;
    BOOL ignoreAction;
}

//- (void)setupWindowForEvents;
-(void)addCitationToCopyList:(Citation*)cit;
-(void)refreshSheet;
-(void) refreshAndReorderCopyList;
-(NSMutableArray*) removeLocationsFromLocationTable:(NSIndexSet *)selectedRows withAnimation:(NSTableViewAnimationOptions)animation;
-(BOOL)reference:(Reference*)ref isTakenByCitationOtherThan:(Citation*)cit;
-(void)cascadeRangesFrom:(Location*)loc by:(NSInteger)offset;
-(NSMutableArray*)getLocationsInOrder;
-(void)editedAuthor:(id)sender;
-(void)editedDate:(id)sender;


@end

@implementation EditorController

@synthesize citation;
@synthesize citeList;
@synthesize citeListCopy;
@synthesize sourceView;
@synthesize model;
@synthesize bibliographies;
@synthesize references;

- (instancetype)init{
    self = [self initWithWindowNibName:@"CitationEditorPanel"];
    return self;
}

-(instancetype)initWithCitations:(NSMutableArray*)citations startingAt:(NSInteger)idx{
    self = [self init];
    if (self) {
        [self setCiteList:citations];
        index = idx;
    }
    
    return self;
}

-(void)windowDidLoad{
    [self setCitationAtIndex];
}
-(void)windowWillLoad{
}

-(void)awakeFromNib{
    [citeScrollView.verticalScroller setControlSize:NSMiniControlSize];
}

-(void)setIndex:(NSInteger)i{
    index = i;
    [self setCitationAtIndex];
}

-(void) setCiteList:(NSMutableArray *)ctlst{
    citeList = ctlst;
    citeListCopy = [[NSMutableArray alloc]initWithCapacity:citeList.count];
    for (Citation * cit in citeList){
        [citeListCopy addObject:[cit copy]];
    }
}


-(void)setCitationAtIndex{
    citation = [citeListCopy objectAtIndex:index];
    [authorsTable reloadData];
    [referenceList reloadData];
    if (citation.locations.count<=1) {
        [citeTable setAllowsEmptySelection:TRUE];
        [citeTable reloadData];
        Location* l = [citation.locations objectAtIndex:0];
        [surroundField setAttributedStringValue:l.attributedSurround];
        //surroundField.stringValue = l.surround;
    }else{
        [citeTable selectRowIndexes:[[NSIndexSet alloc]initWithIndex:0] byExtendingSelection:NO];
        [citeTable setAllowsEmptySelection:FALSE];
        [citeTable reloadData];
    }
    yearField.stringValue = citation.yearString;
    [self.window setTitle:[NSString stringWithFormat:@"%ld/%ld", index, citeListCopy.count]];
}

#pragma mark TableViewDelegate Methods:


-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if (tableView==authorsTable) {
        return citation.authors.count;
    }else if (tableView==citeTable){
        NSInteger out = citation.locations.count;
        return out==1? 0:++out;
    }else if (tableView==referenceList){
        return citation.possibleReferences.count;
    }
    return 0;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{  ///exception throw here from amendAuthor (local)
                                                                    ///new plan: if confused, just return prematurely
    NSTableView* tview = (NSTableView*) notification.object;
    [tview scrollRowToVisible:[tview selectedRow]];
    
    if (notification.object == citeTable) {
        NSIndexSet *indexSet = [citeTable selectedRowIndexes];
        NSUInteger i = [indexSet firstIndex];
        if (i==NSUIntegerMax) return;
        NSMutableAttributedString *field;
        if (![indexSet containsIndex:0] && citation.locations.count>1 && indexSet.count==1) { //i.e. one of several selected
            Location* loc = [citation.locations objectAtIndex:i-1];
            field = loc.attributedSurround;
        }else if (citation.locations.count==1){
            field = [[citation.locations objectAtIndex:0] attributedSurround];
        }else if ([indexSet containsIndex:0] && citation.locations.count>1){ //the `all' is selected
            field = [[NSMutableAttributedString alloc]initWithString:@""];
        }else if (indexSet.count>1){ //several selected
            field = [[NSMutableAttributedString alloc]initWithString:@""];
        }else{
            field = [[NSMutableAttributedString alloc]initWithString:@""];
        }
        surroundField.attributedStringValue = field;
    }else if (notification.object==referenceList){
        NSInteger selectedIndex = [referenceList selectedRow];
        ReferenceRow* refRow = [referenceList rowViewAtRow:selectedIndex makeIfNecessary:NO];
        if (refRow.state==-1)return;
        
        Reference* ref = [citation.possibleReferences objectAtIndex:selectedIndex];
        if (citation.reference==ref) {
            citation.reference=nil;
        }else citation.reference = ref;
        [referenceList reloadData];
    }
}

-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString* ident = [tableColumn identifier];
    if ([ident isEqualToString:@"authors"]) {
        NSString* author = [citation.authors objectAtIndex:row];
        NSTableCellView* out = [tableView makeViewWithIdentifier:ident owner:self];
        out.textField.stringValue = author;
        return out;
    }else if ([ident isEqualToString:@"cites"]){
        NSTableCellView * out = [tableView makeViewWithIdentifier:ident owner:self];
        NSString* str = row==0? @"All":[NSString stringWithFormat:@"%ld", row];        
        [out.textField setStringValue:str];
        return out;
    }else if([ident isEqualToString:@"references"]){
        NSTableCellView* out = [tableView makeViewWithIdentifier:ident owner:self];
        Reference* ref = [citation.possibleReferences objectAtIndex:row];
        NSString* str = [ref toStringTypeTitle];
        out.textField.stringValue = str;
        ReferenceRow* thisRow = [tableView rowViewAtRow:row makeIfNecessary:YES];
        if (citation.reference==ref){
            [thisRow setState:1];
            NSString* path = [NSString stringWithFormat:@"%@/Images/", [[NSBundle mainBundle]resourcePath]] ;
            NSImage *tick = [[NSImage alloc]initWithContentsOfFile:[path stringByAppendingString:@"tick.png"]];
            [out.imageView setImage:tick];
            [out.textField setTextColor:[NSColor colorWithCalibratedWhite:0.1 alpha:1]];
        }else{
            
            [out.imageView setImage:nil];
            if ([self reference:ref isTakenByCitationOtherThan:citation]){
                [thisRow setState:-1];
                [out.textField setTextColor:[NSColor colorWithCalibratedWhite:0 alpha:.2]];
            }else{
                [thisRow setState:0];
                [out.textField setTextColor:[NSColor colorWithCalibratedWhite:0.1 alpha:1]];
            }
        }
        return out;
    }
    return nil;
}

-(NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row{
    if (tableView==referenceList){
        ReferenceRow* out = [[ReferenceRow alloc]init];
        return out;
    }else return [[CustomRow alloc]init];
}



#pragma mark Actions

-(void)editedDate:(id)sender{
    NSTextField * field = (NSTextField*)sender;
    NSString* newdate = field.stringValue;
    NSString* olddate = [citation yearString];
    
    if([olddate isEqualToString:newdate]) return;
    if (!sourceView) @throw [[NSException alloc]initWithName:@"MissingSourceView" reason:@"at Editor Controller (editedDate method)" userInfo:nil];
    
    Year* newDate = [Parser getYearFromString:newdate];
    if (!newDate){
        NSLog(@"That wasn't a valid date (at EditorController-editedDate action)");
        field.stringValue= olddate;
        return;
    }
    
    NSIndexSet* indexes = [citeTable selectedRowIndexes];
    [[NSAnimationContext currentContext] setDuration:2.5];
    
    if (citation.locations.count>1 && ![indexes containsIndex:0] && indexes.count<citation.locations.count) {
        NSComparisonResult comp = [citation.year compare:newDate];
        NSTableViewAnimationOptions animation;
        if (comp==NSOrderedAscending){
            animation = NSTableViewAnimationSlideRight;
        }else animation = NSTableViewAnimationSlideLeft;
        NSMutableArray* selectedLocations = [self removeLocationsFromLocationTable:indexes withAnimation:animation];
        
        Citation *newcite = [[Citation alloc]initWithYear:newDate];
        newcite.authors = [citation.authors copy];
        for (Location* loc in selectedLocations)
            [loc editYear:newdate];
        newcite.locations = selectedLocations;
        newcite.assured = citation.assured;
        [self addCitationToCopyList:newcite];
        
        yearField.stringValue = olddate;
        return;
    }else{
        for (Location * loc in citation.locations){
//            if (newdate.length!=olddate.length){
//                [self cascadeRangesFrom:loc by:newdate.length-olddate.length];
//            }
            [loc editYear:newdate];
        }
        citation.year = newDate;
        [self refreshAndReorderCopyList];
    }
}

- (IBAction)done:(id)sender {
    citeList = citeListCopy;
    [model updateCitations:citeList];
    [self close];
    
}

- (IBAction)cancel:(id)sender {
    [self close];
}

- (IBAction)addAuthor:(id)sender {
    NSString * newAuthor= @"New-Author";
    NSInteger i;
    if ([[citation.authors lastObject] isEqualToString:ET_AL]){
        i = citation.authors.count-1;
        [citation.authors insertObject:newAuthor atIndex:i];
        recentlyAddedAuthorIndex = [NSIndexSet indexSetWithIndex:i];
    }else{
        i = citation.authors.count;
        [citation.authors addObject:newAuthor];
        recentlyAddedAuthorIndex = [NSIndexSet indexSetWithIndex:i];
    }
    ignoreAction = YES;
    [authorsTable insertRowsAtIndexes:recentlyAddedAuthorIndex withAnimation:NSTableViewAnimationSlideDown];
    //[authorsTable selectRowIndexes:indx byExtendingSelection:NO];
    NSTableCellView * cell = (NSTableCellView*)[authorsTable viewAtColumn:0 row:i makeIfNecessary:NO];
    [cell.textField selectText:cell];
    
    ////to prevent deleting the new authors for a global edit:
//    if (citation.locations.count==1 || [[citeTable selectedRowIndexes]containsIndex:0]){ ///add (|| selected rows>=citation.locations)
//        recentlyAddedAuthorIndex = nil;
//    }
}

- (IBAction)removeAuthor:(id)sender {
    NSIndexSet* rows = [authorsTable selectedRowIndexes];
    NSIndexSet* selectedCitaitons = [citeTable selectedRowIndexes];
    if (rows.count==0) return;
    if (citation.locations.count<2 || [selectedCitaitons containsIndex:0] || selectedCitaitons.count>=citation.locations.count-1) {
        [citation.authors removeObjectsAtIndexes:rows];
        [authorsTable removeRowsAtIndexes:rows withAnimation:NSTableViewAnimationSlideLeft];
        [self refreshAndReorderCopyList];
    }else{
        Citation* newcite = [[Citation alloc]initWithYear:citation.year.year andModifier:citation.year.modifier];
        NSMutableArray* locations = [NSMutableArray arrayWithArray:[citation.locations objectsAtIndexes:selectedCitaitons]];
        newcite.locations = locations;
        newcite.authors = [NSMutableArray arrayWithArray:citation.authors];
        for (Location * loc in newcite.locations){
            [loc removeAuthorAtIndex:rows.firstIndex];
        }
        [newcite.authors removeObjectAtIndex:rows.firstIndex];
        NSTableViewAnimationOptions animation;
        NSComparisonResult comp = [citation compare:newcite];
        if (comp==NSOrderedAscending) {
            animation = NSTableViewAnimationSlideRight;
        }else animation = NSTableViewAnimationSlideLeft;
        [citation.locations removeObjectsAtIndexes:selectedCitaitons];
        [citeTable removeRowsAtIndexes:selectedCitaitons withAnimation:animation];
        
        [self addCitationToCopyList:newcite];
        if (citation.locations.count>1) [citeTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    }
}

- (IBAction)forgetAuthor:(id)sender {
    NSIndexSet* rows = [authorsTable selectedRowIndexes];
    if (rows.count==0) return;
    
    NSArray* unwanted = [citation.authors objectsAtIndexes:rows];
    
    //add the ignores into the ignores file:
    NSString* path = [NSString stringWithFormat:@"%@/nonNames.txt", [[NSBundle mainBundle]resourcePath]];
    NSArray* nonNames = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray* ignores = [NSMutableArray arrayWithArray:nonNames];
    for (NSString* author in unwanted){
        if (![ignores containsObject:author]) [ignores addObject:author];
    }
    NSString* output = @"";
    for (NSString* author in ignores){
        output = [output stringByAppendingFormat:@"%@\n",author];
    }
    [output writeToFile:path atomically:TRUE encoding:NSUTF8StringEncoding error:nil];
    
    ///Remove all occurences of the non-name:
    BOOL somethingHappened = FALSE;
    [citation.authors removeObjectsAtIndexes:rows];
    [authorsTable removeRowsAtIndexes:rows withAnimation:NSTableViewAnimationSlideRight];
    
    for (Citation * cit in citeListCopy) {
        for (int i =0; i<cit.authors.count; i++) {
            NSString* author = [cit.authors objectAtIndex:i];
            if ([unwanted containsObject:author]){
                [cit.authors removeObject:author];
                somethingHappened = TRUE;
            }
        }
    }
    [self refreshAndReorderCopyList];
}

-(void)editedAuthor:(id)sender{
    if (ignoreAction) {
        ignoreAction=FALSE;
        return;
    }
    NSTextField* field = (NSTextField*)sender;
    
    NSInteger i = [authorsTable rowForView:sender];
    NSString* oldAuthor = [citation.authors objectAtIndex:i];
    NSString* newAuthor = [field stringValue];
    
    if (!recentlyAddedAuthorIndex && [oldAuthor isEqualToString:newAuthor]) return;
    
    [citation.authors replaceObjectAtIndex:i withObject:newAuthor];
    NSIndexSet *selectedIndexes = [citeTable selectedRowIndexes];
    
    if ([selectedIndexes containsIndex:0] || citation.locations.count<2 || selectedIndexes.count>=citation.locations.count-1) { //if a global edit
        for (Location* loc in citation.locations){
            [loc editAuthor:newAuthor at:i inserting:recentlyAddedAuthorIndex!=nil];
        }
        [self refreshAndReorderCopyList];
        
    }else{
        NSComparisonResult comp = [oldAuthor compare:newAuthor]; ///wrong! compare citations not authors!
        NSTableViewAnimationOptions animation;
        if (comp==NSOrderedAscending) animation = NSTableViewAnimationSlideRight;
        else animation = NSTableViewAnimationSlideLeft;
        NSMutableArray* selectedLocations = [self removeLocationsFromLocationTable:selectedIndexes withAnimation:animation];
        //-----------------------
        //--make the new citation
        Citation * newCitation = [[Citation alloc]initWithYear:citation.year.year andModifier:citation.year.modifier];
        for (Location * loc in selectedLocations){
            [loc editAuthor:newAuthor at:i inserting:recentlyAddedAuthorIndex!=nil];
        }
        newCitation.locations = selectedLocations;
        newCitation.assured = citation.assured;
        newCitation.authors = [NSMutableArray arrayWithArray:citation.authors];
        //-----------------------
        if (recentlyAddedAuthorIndex){
            [citation.authors removeObjectsAtIndexes:recentlyAddedAuthorIndex];
            [authorsTable removeRowsAtIndexes:recentlyAddedAuthorIndex withAnimation:animation];
        }else{
            [citation.authors removeObjectAtIndex:i];
            [authorsTable removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:i] withAnimation:animation];
            [citation.authors insertObject:oldAuthor atIndex:i];
            [authorsTable insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:i] withAnimation:NSTableViewAnimationEffectGap];
            
        }
        [self addCitationToCopyList:newCitation];
    }
    recentlyAddedAuthorIndex = nil;
}

- (IBAction)nextRef:(id)sender {
    if (index+1<citeListCopy.count) {
        index++;
        [self setCitationAtIndex];
    }
}

- (IBAction)prevRef:(id)sender {
    if (index>0) {
        index--;
        [self setCitationAtIndex];
    }
}

- (IBAction)nextCite:(id)sender {
    NSEventModifierFlags flags = [[NSApp currentEvent]modifierFlags];
    NSInteger i = [citeTable selectedRow]+1;
    if(i<[citeTable numberOfRows]) {
        NSIndexSet *indexes = [[NSIndexSet alloc]initWithIndex:i];
        [citeTable selectRowIndexes:indexes byExtendingSelection:(flags & NSShiftKeyMask)];
    }
}

- (IBAction)prevCite:(id)sender {
    NSEventModifierFlags flags = [[NSApp currentEvent]modifierFlags];
    NSInteger i = [citeTable selectedRow]-1;
    if (i>=0) {
        NSIndexSet *indexes = [[NSIndexSet alloc]initWithIndex:i];
        [citeTable selectRowIndexes:indexes byExtendingSelection:(flags & NSShiftKeyMask)];
    }    
}

#pragma mark Private Methods: Reconfiguring for edits

-(void) addCitationToCopyList:(Citation *)cit{
    for (Citation * c in citeListCopy){
        if ([c isEquivalent:cit]){
            [c.locations addObjectsFromArray:cit.locations];
            [c.locations sortUsingSelector:@selector(compare:)];
            return;
        }
    }
    [citeListCopy addObject:cit];
    [citeListCopy sortUsingSelector:@selector(compare:)];
    index = [citeListCopy indexOfObject:citation];
}


///get it to adjuct the index appropriately as the array changes
-(void) refreshAndReorderCopyList{
    for (int i=0; i<citeListCopy.count; i++) {
        for (int j=i+1; j<citeListCopy.count; j++) {
            Citation *c1 = [citeListCopy objectAtIndex:i];
            Citation *c2 = [citeListCopy objectAtIndex:j];
            if ([c1 isEquivalent:c2]){
                if (citation == c1){
                    [c1.locations addObjectsFromArray:c2.locations];
                    if (c2.reference && !c1.reference) {
                        c1.reference = c2.reference;
                    }
                    [citeListCopy removeObjectIdenticalTo:c2];
                }else{
                    [c2.locations addObjectsFromArray:c1.locations];
                    if (c1.reference && !c2.reference) {
                        c2.reference = c1.reference;
                    }
                    [citeListCopy removeObjectIdenticalTo:c1];
                }
            }
        }
    }
    for (NSInteger i=0; i<citeListCopy.count; i++) {
        Citation* cit = [citeListCopy objectAtIndex:i];
        [cit findPossibleReferences:references];
    }
    [citeListCopy sortUsingSelector:@selector(compare:)];
    index = [citeListCopy indexOfObjectIdenticalTo:citation];
    [self setCitationAtIndex];
}

-(void) refreshSheet{
    [citation findPossibleReferences:references];
    [referenceList reloadData];
    [authorsTable reloadData];
    [citeTable reloadData];
    [yearField setStringValue:[citation yearString]];
}

-(void)cascadeRangesFrom:(Location*)l by:(NSInteger)offset{
    NSMutableArray* locations = [self getLocationsInOrder];
    BOOL begun=false;
    for (NSInteger i=0; i<locations.count; i++) {
        Location* loc = [locations objectAtIndex:i];
        if ([loc isEqualTo:l]){
            begun = true;
            continue;
        }else if (!begun) continue;
        
        [loc offsetRange:offset];
    }
}

-(NSMutableArray *)getLocationsInOrder{
    NSMutableArray* out = [[NSMutableArray alloc]init];
    for (Citation* cit in citeListCopy){
        [out addObjectsFromArray:cit.locations];
    }
    [out sortUsingSelector:@selector(compare:)];
    return out;
}

#pragma mark TextFieldDelegate Methods:

-(void)controlTextDidEndEditing:(NSNotification *)obj{
    NSControl* sender = (NSControl*) obj.object;
    if (sender == yearField) {
        [self editedDate:sender];
    }else if ([sender.identifier isEqualToString:@"authorCell"]){
        [self editedAuthor:sender];
    }
}

-(void)controlTextDidChange:(NSNotification *)obj{
}

-(BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector{
    if (control==(NSControl*)yearField) {
        if (commandSelector==@selector(insertNewline:) || commandSelector==@selector(insertTab:)){
            [textView setSelectedRange:NSMakeRange(textView.string.length, 0)];
            [textView.window makeFirstResponder:nil];
            return YES;
        }
    }else if ([control.identifier isEqualToString:@"authorCell"]){
       
    }
    
    return NO;
}

-(NSMutableArray*) removeLocationsFromLocationTable:(NSIndexSet *)selectedRows withAnimation:(NSTableViewAnimationOptions)animation{
    NSMutableArray * locations = [[NSMutableArray alloc]initWithCapacity:selectedRows.count];
    NSUInteger i = selectedRows.firstIndex;
    while (i!=NSNotFound) {
        Location * loc = [citation.locations objectAtIndex:i-1];
        [locations addObject:loc];
        i = [selectedRows indexGreaterThanIndex:i];
    }
    [[NSAnimationContext currentContext] setDuration:2.0];
    [citation.locations removeObjectsInArray:locations];
    [citeTable removeRowsAtIndexes:selectedRows withAnimation:animation];
    if (citation.locations.count==1){
        NSIndexSet* theRemainder = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,2)];
        [citeTable removeRowsAtIndexes:theRemainder withAnimation:NSTableViewAnimationSlideUp];
    }
    return locations;
}

#pragma mark Split View Delegate Methods:
//
//-(CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex{
//    if (dividerIndex==1){
//        NSView* authorView = [splitView.subviews objectAtIndex:0];
//        return authorView.frame.origin.x+authorView.frame.size.width + 100;
//    }else return proposedMaximumPosition;
//}
//
//-(CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex{
//    if (dividerIndex == 1){
//        NSView* refView = [splitView.subviews objectAtIndex:2];
//        return refView.frame.origin.x - 100;
//    }
//    return proposedMinimumPosition;
//}


-(BOOL)reference:(Reference *)ref isTakenByCitationOtherThan:(Citation *)cit{
    for (NSInteger i=0; i<citeListCopy.count; i++) {
        Citation* c = [citeListCopy objectAtIndex:i];
        if (c.reference==ref && c!=cit) return TRUE;
    }
    return FALSE;
}




@end
