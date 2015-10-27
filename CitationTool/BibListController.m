//
//  BibListController.m
//  CitationTool3
//
//  Created by Thomas Gray on 22/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "BibListController.h"
#import "AppDelegate.h"


@interface BibListController (Private)

-(NSView*)bibTableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
-(NSView*)fieldTableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
-(NSArray*)getFieldKeysForSelectedReference;

-(void)recursiveBibSearch;
-(void)rememberBibPath:(NSString*)path;
-(NSArray*)savedBibPaths;

@end

@implementation BibListController

@synthesize bibliographies;
@synthesize references;

-(void)setBibliographies:(NSMutableArray<Bibliography*> *)bibs{
    if (!bibs) return;
    bibliographies = bibs;
    [bibOutlines reloadData];
    [bibTable reloadData];
}

-(void)initialLoad{
    bibliographies = [[NSMutableArray alloc]init];
    references = [[NSMutableArray alloc]init];
    
    //[self recursiveBibSearch];
    NSArray* savedBibs = [self savedBibPaths];
    if (savedBibs && savedBibs.count) {
        for (NSInteger i=0; i<savedBibs.count; i++) {
            NSLog(@"saved .bib: %@", [savedBibs objectAtIndex:i]);
            Bibliography* bib = [[Bibliography alloc]initWithFile:[savedBibs objectAtIndex:i]];
            if (bib.references.count) {
                [bibliographies addObject:[[Bibliography alloc]initWithFile:[savedBibs objectAtIndex:i]]];
            }else{
                //delete the bib file from whatevs?
            }
        }
    }
    for (NSInteger k=0; k<bibliographies.count; k++) {
        Bibliography* bib = [bibliographies objectAtIndex:k];
        [Bibliography addReferencesFrom:bib toReferenceArray:references];
    }
    [bibOutlines reloadData];
    
    if ([bibOutlines selectedRowIndexes].count) {
        NSInteger bibIndex = [[bibOutlines selectedRowIndexes]firstIndex];
        selectedBib = [bibliographies objectAtIndex:bibIndex];
    }
    if ([bibTable selectedRowIndexes].count) {
        NSInteger refIndex = [[bibTable selectedRowIndexes]firstIndex];
        selectedReference = [selectedBib.references objectAtIndex:refIndex];
    }
    if (selectedBib) {
        [pathControl setURL:[NSURL fileURLWithPath:selectedBib.path]];
    }
    
    [typePopUp addItemsWithTitles:[Reference getEntryTypes]];
    if (selectedReference) {
        [typePopUp selectItemAtIndex:[[Reference getEntryTypes]indexOfObject:[selectedReference type]]];
    }
}

-(void)recursiveBibSearch{
    NSFileManager* filemanager = [NSFileManager defaultManager];
    NSURL* home = [[NSURL alloc]initFileURLWithPath:NSHomeDirectory()];
    NSDirectoryEnumerator* enumerator = [filemanager enumeratorAtURL:home includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^BOOL(NSURL * _Nonnull url, NSError * _Nonnull error) {
        if (error){
            return NO;
        }else return YES;
    }];
    
    NSMutableArray* bibPaths = [[NSMutableArray alloc]init];
    for (NSURL* file in enumerator){
        NSString* name;
        [file getResourceValue:&name forKey:NSURLNameKey error:nil];
        
        if ([name hasSuffix:@"bib"]){
            [bibPaths addObject:[file path]];
        }
    }
    for (NSInteger k=0; k<bibPaths.count;k++){
        NSString* path = [bibPaths objectAtIndex:k];
        [bibliographies addObject:[[Bibliography alloc]initWithFile:path]];
    }
    for (NSInteger i=0; i<bibliographies.count; i++) {
        Bibliography* bib = [bibliographies objectAtIndex:i];
        [Bibliography addReferencesFrom:bib toReferenceArray:references];
    }
}

-(void)awakeFromNib{
    
}



#pragma mark Outline View Delegate

-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    if(item==nil){
        return bibliographies.count;
    }
    return 0;
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    if ([item isKindOfClass:[Bibliography class]]) {
        return NO;
    }
    return NO;
}

-(id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
    NSString* identifier= [tableColumn identifier];
    if ([item isKindOfClass:[Bibliography class]]){
        Bibliography* bib = (Bibliography*)item;
        if ([identifier isEqualToString:@"name"]) {
            return bib.name;
        }else if ([identifier isEqualToString:@"count"]){
            return [[NSNumber alloc]initWithLong:bib.references.count];
        }else return nil;
    }
    return nil;
}

-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    if (!item){
        return [bibliographies objectAtIndex:index];
    }else return nil;
}


-(NSView*)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    if ([item isKindOfClass:[Bibliography class]]) {
        if ([tableColumn.identifier isEqualToString:@"name"]) {
            NSTableCellView* out = [outlineView makeViewWithIdentifier:@"bibliography" owner:self];
            out.textField.stringValue = [item name];
            [out setToolTip:[item path]];
            return out;
        }else if ([tableColumn.identifier isEqualToString:@"count"]){
            NSTableCellView* out = [outlineView makeViewWithIdentifier:@"count" owner:self];
            Bibliography* bib = (Bibliography*)item;
            NSString* outString = [NSString stringWithFormat:@"%ld", bib.references.count];
            NSSize size = [outString sizeWithAttributes:@{NSFontAttributeName:out.textField.font}];

            NSRect cellFrame = out.frame;
            NSRect textFrame = out.textField.frame;
            
            [out.textField setFrame:NSMakeRect(cellFrame.size.width-size.width-9, textFrame.origin.y, size.width+9, size.height)];
            [out.textField setStringValue:outString];
            
            return out;
        }else return nil;
    }
    return nil;
}

-(void)outlineViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row = [bibOutlines selectedRow];
    selectedBib = [bibliographies objectAtIndex:row];
    [bibTable reloadData];
    [fieldTable reloadData];
    [pathControl setURL:[NSURL fileURLWithPath:selectedBib.path]];
    
    [self tableViewSelectionDidChange:[NSNotification notificationWithName:@"select Change" object:bibTable]];
}


-(void)refreshFields{
    if (selectedReference) {
        NSArray* types = [Reference getEntryTypes];
        NSInteger i = [types indexOfObject:selectedReference.type];
        [typePopUp selectItemAtIndex:i];
        [keyField setStringValue:selectedReference.key];
    }
    [fieldTable reloadData];
}

-(void)refreshBibTable{
    NSIndexSet* indexes = [bibTable selectedRowIndexes];
    [bibTable reloadData];
    [bibTable selectRowIndexes:indexes byExtendingSelection:NO];
    [bibTable scrollRowToVisible:indexes.firstIndex];
}

#pragma mark Table View Delegate

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if (tableView==bibTable) {
        if (!selectedBib) return 0;
        return selectedBib.references.count;
    }else if(tableView==fieldTable){
        if (!selectedReference)return 0;
        else if (toggleViewFieldsButton.state) return selectedReference.fields.count;
        else return [Reference getCorrespondingPrincipleFields:selectedReference.type].count;
    }else return 0;
}

-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if (tableView==bibTable) {
        return [self bibTableView:tableView viewForTableColumn:tableColumn row:row];
    }else if (tableView==fieldTable){
        return [self fieldTableView:tableView viewForTableColumn:tableColumn row:row];
    }else return nil;
}


-(NSView*)bibTableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    Reference* ref = [selectedBib.references objectAtIndex:row];
    NSString* identifier = [tableColumn identifier];
    NSTableCellView* out= [tableView makeViewWithIdentifier:identifier owner:self];
    
    if ([identifier isEqualToString:@"author"]) {
        out.textField.stringValue = [ref getAuthorStringWithFinalDelimiter:@"&"];
        return out;
    }else if ([identifier isEqualToString:@"year"]){
        NSString* year = [ref.fields valueForKey:@"year"];
        out.textField.stringValue = year? year:@"????";
        return out;
    }else if ([identifier isEqualToString:@"title"]){
        NSString* title = [ref.fields valueForKey:@"title"];
        out.textField.stringValue = title? title:@"";
        return out;
    }else if ([identifier isEqualToString:@"type"]){
        out.textField.stringValue = ref.type? ref.type:@"";
        return out;
    }else if ([identifier isEqualToString:@"journal"]){
        NSString* journal = [ref.fields valueForKey:@"journal"];
        out.textField.stringValue = journal? journal:@"";
        return out;
    }else return nil;
}

-(NSView*)fieldTableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString* identifier = tableColumn.identifier;
    NSArray* keys = toggleViewFieldsButton.state? [selectedReference keys]:[Reference getCorrespondingPrincipleFields:selectedReference.type];
    
    if ([identifier isEqualToString:@"key"]) {
        NSTableCellView* out = [tableView makeViewWithIdentifier:@"key" owner:self];
        
        NSString* key = [keys objectAtIndex:row];
        [out.textField setStringValue:key];
        
        NSButton* button = [out.subviews firstObject];
        [button setImage:[AppDelegate getImageNamed:@"removeIconUp_19"]];
        [button setAlternateImage:[AppDelegate getImageNamed:@"removeIconDown_19"]];

        NSArray* standardKeys = [Reference getEstablishedFields];
        if ([standardKeys containsObject:key]){
            [button setHidden:TRUE];
            [out.textField setEditable:FALSE];
        }else{
            [button setHidden:FALSE];
            [out.textField setEditable:TRUE];
        }
        return out;
    }else if ([identifier isEqualToString:@"value"]){
        NSTableCellView* out = [tableView makeViewWithIdentifier:@"value" owner:self];
        NSString* str = [selectedReference.fields valueForKey:[keys objectAtIndex:row]];
        [out.textField setStringValue:str? str:@""];
        return out;
    }
    return nil;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    if (notification.object==bibTable) {
        NSIndexSet* selection = [bibTable selectedRowIndexes];
        if (selection.count==0) {
            selectedReference = nil;
            [fieldData removeAllObjects];
            [texView setString:@""];
        }else{
            NSInteger i = [selection firstIndex];
            selectedReference = [selectedBib.references objectAtIndex:i];
            [texView setString:[selectedReference getTexString]];
        }
        ///order the data!
        [self refreshFields];
    }
}

-(void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn{
    if (!selectedBib) return;
    if (tableView==bibTable) {
        Reference* ref = selectedReference;
        NSArray* keys = [Reference getEstablishedFields];
        if ([keys containsObject:tableColumn.identifier]) {
            [selectedBib sortReferencesByKeys:@[tableColumn.identifier]];
            [bibTable reloadData];
        }
        
        if (ref) {
            selectedReference = ref;
            NSInteger i  = [selectedBib.references indexOfObject:selectedReference];
            [bibTable selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
            [bibTable scrollRowToVisible:i];
        }
    }
}


#pragma  mark Path View Delegate Methods


#pragma  mark SplitView Delegate Methods

-(CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex{
    if ([splitView isVertical]) {
        return 150.0f;
    }else{
        return 200.0f;
    }
}

-(CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex{
    if ([splitView isVertical]) {
        CGFloat width = splitView.frame.size.width;
        return width-350.0f;
    }else{
        CGFloat height = splitView.frame.size.height;
        return height-200.0f;
    }
}

-(BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview{
    if ([splitView isVertical]) {
        if ([splitView.subviews firstObject]==subview) {
            return YES;
        }
    }else{
        
    }
    return false;
}

#pragma mark Text Delegate

-(void)textDidChange:(NSNotification *)notification{
    NSString* str = [texView.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    @try {
        [selectedReference getDataFromBib:str];
        [texView.textStorage setAttributes:@{NSForegroundColorAttributeName:[NSColor blackColor]} range:NSMakeRange(0, str.length)];
        [self refreshFields];
        [selectedBib saveToBibFile];
    }
    @catch (NSException *exception) {
        [texView.textStorage setAttributes:@{NSForegroundColorAttributeName:[NSColor redColor]} range:NSMakeRange(0, str.length)];
    }
}


//-(void)textDidChange:(NSNotification *)notification{
//    if (!selectedReference) return;
//    NSString* str = texView.string;
//    @try {
//        [selectedReference getDataFromBib:str];
//        [texView.textStorage setAttributes:@{NSForegroundColorAttributeName:[NSColor blackColor]} range:NSMakeRange(0, str.length)];
//    }
//    @catch (NSException *exception) {
//        [texView.textStorage setAttributes:@{NSForegroundColorAttributeName:[NSColor redColor]} range:NSMakeRange(0, str.length)];
//    }
//
//}

#pragma mark Text Field Delegate Methods


-(void)controlTextDidEndEditing:(NSNotification *)obj{ //called by text field
    if (!selectedReference) return;
    NSTextField* tfield = (NSTextField*)obj.object;
    NSArray* keys = [self getFieldKeysForSelectedReference];
    NSString* newVal = [tfield stringValue];
    
    if ([tfield.identifier isEqualToString:@"texkey"]) {
        NSString* oldval = selectedReference.key;
        if ([oldval isEqualToString:newVal]) return;
        
        [selectedReference setKey:tfield.stringValue];
        [selectedReference setKeyAutoGenerated:FALSE];
    }else if ([tfield.identifier isEqualToString:@"key"]) {
        NSInteger index = [fieldTable rowForView:tfield];
        NSString* oldkey = [keys objectAtIndex:index];
        if ([oldkey isEqualToString:newVal]) return;
        
        [selectedReference.keys replaceObjectAtIndex:index withObject:newVal];
        
        NSString* val = [selectedReference.fields valueForKey:oldkey];
        [selectedReference.fields removeObjectForKey:oldkey];
        [selectedReference.fields setObject:val forKey:newVal];
        
        val = [selectedReference.texFields objectForKey:oldkey];
        [selectedReference.texFields removeObjectForKey:oldkey];
        [selectedReference.texFields setObject:val forKey:newVal];
    }else{//so it's the value that's changing
        NSInteger index = [fieldTable rowForView:tfield];
        NSString* key = [keys objectAtIndex:index];
        NSString* oldval = [selectedReference.fields valueForKey:key];
        if ([oldval isEqualToString:newVal]) return;
        [selectedReference modifyField:newVal forKey:key isTexFormat:NO];
    }
    [self refreshBibTable];
    [selectedBib saveToBibFile];
}

#pragma mark Tab View Delegate

-(void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem{
    if (tabViewItem==[tabView tabViewItemAtIndex:1]) {
        [texView setString:[selectedReference getTexString]];
    }else if (tabViewItem==[tabView tabViewItemAtIndex:0]){
        [self refreshFields];
    }
}

#pragma mark Field-Related Methods

-(NSArray*)getFieldKeysForSelectedReference{
    return toggleViewFieldsButton.state? [selectedReference keys]:[Reference getCorrespondingPrincipleFields:selectedReference.type];
}

#pragma mark Actions

- (IBAction)typeSeleced:(NSPopUpButton *)sender {
    if (!selectedReference) return;
    NSString* newType = [sender titleOfSelectedItem];
    if ([newType isEqualToString:selectedReference.type]) return;
    [selectedReference setType:newType];
    NSIndexSet* asIS = [bibTable selectedRowIndexes];
    [fieldTable reloadData];
    [bibTable reloadData];
    [bibTable selectRowIndexes:asIS byExtendingSelection:NO];
}

- (IBAction)addField:(id)sender {
//    [selectedReference.fields setValue:@"" forKey:@"new_field"];
//    [fieldTable insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:selectedReference.fields.count-1] withAnimation:NSTableViewAnimationSlideLeft];
    //NSTableCellView* cell =[fieldTable viewAtColumn:0 row:selectedReference.fields.count-1 makeIfNecessary:NO];
}

-(IBAction)addReference:(id)sender{
    if (!selectedBib) return;
    
    Reference* ref = [[Reference alloc]init];
    [selectedBib.references insertObject:ref atIndex:0];
    [bibTable insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationSlideRight];
    [bibTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    [bibTable scrollRowToVisible:0];
    [selectedBib saveToBibFile];
}

- (IBAction)removeField:(id)sender {
    NSInteger row = [fieldTable rowForView:sender];
    NSInteger state = [toggleViewFieldsButton state];
    NSString* key;
    if (state) {
        NSArray* keys = [selectedReference.fields allKeys];
        key = [keys objectAtIndex:row];
    }else{
        NSString* type = [selectedReference type];
        NSArray* keys = [Reference getCorrespondingPrincipleFields:type];
        key = [keys objectAtIndex:row];
    }
    [fieldTable removeRowsAtIndexes:[[NSIndexSet alloc]initWithIndex:row] withAnimation:NSTableViewAnimationSlideRight];
    [selectedReference.fields removeObjectForKey:key];
    [selectedBib saveToBibFile];
}

- (IBAction)toggleViewAllFields:(NSButton *)sender {
    NSInteger i = [sender state];
    if (i) {
        [addFieldButton setEnabled:TRUE];
        fieldData = [[NSMutableArray alloc]initWithArray:[selectedReference.fields allKeys]];
        ///order
        [fieldTable reloadData];
    }else{
        [addFieldButton setEnabled:FALSE];
        fieldData = [[NSMutableArray alloc]initWithArray:[Reference getCorrespondingPrincipleFields:[selectedReference type]]];
        [fieldTable reloadData];
    }
}

-(IBAction)loadBibFile:(id)sender{
    NSOpenPanel* opener = [NSOpenPanel openPanel];
    [opener setCanChooseDirectories:NO];
    [opener setCanChooseFiles:YES];
    [opener setAllowsMultipleSelection:NO];
    [opener setAllowedFileTypes:@[@"bib"]];
    
    NSInteger i = [opener runModal];
    
    if (i==NSOKButton) {
        NSString* path = [[opener URL] path];
        [self rememberBibPath:path];
        Bibliography* bib = [[Bibliography alloc]initWithFile:path];
        [bibliographies addObject:bib];
        [bibOutlines reloadData];
        [Bibliography addReferencesFrom:bib toReferenceArray:references];
    }
}

-(void)rememberBibPath:(NSString *)path{
    NSString* savedDataPath = [[[NSBundle mainBundle]resourcePath]stringByAppendingString:@"/savedInfo.txt"];
    NSString* savedData = [NSString stringWithContentsOfFile:savedDataPath encoding:NSUTF8StringEncoding error:nil];
    NSArray* lines = [savedData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSInteger i=0; i<lines.count; i++) {
        NSString * line = [lines objectAtIndex:i];
        if ([line isEqualToString:@"<bibPaths>"]) {
            for (i++; i<lines.count; i++) {
                NSString* thisline = [lines objectAtIndex:i];
                if ([thisline isEqualToString:@"</bibPaths>"]){
                    NSMutableArray* newData = [[NSMutableArray alloc]initWithArray:lines];
                    [newData insertObject:path atIndex:i];
                    NSString* newStringData = [newData componentsJoinedByString:@"\n"];
                    [newStringData writeToFile:savedDataPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    return;
                }
                else if ([path isEqualToString:thisline]) return;
                
            }
        }
    }
}


-(NSArray *)savedBibPaths{
    NSString* path = [[[NSBundle mainBundle]resourcePath]stringByAppendingString:@"/savedInfo.txt"];
    NSString* data = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray* lines = [data componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSInteger i = [lines indexOfObject:@"<bibPaths>"];
    NSInteger j = [lines indexOfObject:@"</bibPaths>"];
    if (i<j && i<lines.count && j<lines.count) {
        i++;
        NSMutableArray * out = [[NSMutableArray alloc]initWithArray:lines];
        NSArray * outout = [out subarrayWithRange:NSMakeRange(i, j-i)];
        return outout;
    }else return nil;
}







@end
