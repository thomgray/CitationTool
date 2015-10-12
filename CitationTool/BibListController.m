//
//  BibListController.m
//  CitationTool3
//
//  Created by Thomas Gray on 22/09/2015.
//  Copyright (c) 2015 Thomas Gray. All rights reserved.
//

#import "BibListController.h"

@interface BibListController (Private)

-(NSView*)bibTableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
-(NSView*)fieldTableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

@end

@implementation BibListController

@synthesize bibliographies;

-(void)setBibliographies:(NSMutableArray *)bibs{
    if (!bibs.count) return;
    bibliographies = bibs;
    [bibOutlines reloadData];
    [bibOutlines selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    selectedBib = [bibs objectAtIndex:0];
    [bibTable reloadData];
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
            return out;
        }else if ([tableColumn.identifier isEqualToString:@"count"]){
            NSTableCellView* out = [outlineView makeViewWithIdentifier:@"count" owner:self];
            Bibliography* bib = (Bibliography*)item;
            NSString* outString = [NSString stringWithFormat:@"%ld", bib.references.count];
            out.textField.stringValue =outString;
            NSSize size = [outString sizeWithAttributes:[NSDictionary dictionaryWithObject:out.textField.font forKey:NSFontAttributeName]];
//            [out setFrame:NSMakeRect(out.frame.origin.x, out.frame.origin.y, size.width+4, out.frame.size.height)];
            NSRect cellFrame = out.frame;
            NSRect textFrame = out.textField.frame;
            
            [out.textField setFrame:NSMakeRect(cellFrame.size.width-size.width-4, textFrame.origin.y, size.width+5, size.height)];
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
}




#pragma mark Table View Delegate

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if (tableView==bibTable) {
        return selectedBib.references.count;
    }else if(tableView==fieldTable){
        if (!fieldData)return 0;
        return fieldData.count;
    }else if (tableView==typeView){
        if (selectedReference) return 1;
        else return 0;
    }else return 0;
}

-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if (tableView==bibTable) {
        return [self bibTableView:tableView viewForTableColumn:tableColumn row:row];
    }else if (tableView==fieldTable){
        return [self fieldTableView:tableView viewForTableColumn:tableColumn row:row];
    }else if (tableView==typeView){
        if ([tableColumn.identifier isEqualToString:@"key"]) {
            NSTableCellView* out = [tableView makeViewWithIdentifier:@"key" owner:self];
            out.textField.stringValue = @"type";
            return out;
        }else{
            NSTableCellView* out = [tableView makeViewWithIdentifier:@"value" owner:self];
            NSPopUpButton* pop = [out.subviews objectAtIndex:0];
            [pop addItemsWithTitles:[Reference getEntryTypes]];
            NSString* val = selectedReference.type;
            [pop setTitle:val? val:@"misc"];
            return out;
        }
    
    }else return nil;
}


-(NSView*)bibTableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    Reference* ref = [selectedBib.references objectAtIndex:row];
    NSString* identifier = [tableColumn identifier];
    NSTableCellView* out= [tableView makeViewWithIdentifier:identifier owner:self];
    
    if ([identifier isEqualToString:@"author"]) {
        NSString* author = @"";
        for (int i=0; i<ref.authorArray.count;i++){
            Name * name = [ref.authorArray objectAtIndex:i];
            author=[author stringByAppendingString:name.surname];
            if (i==ref.authorArray.count-1) break;
            author = [author stringByAppendingString:@", "];
        }
        out.textField.stringValue = author;
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
    
    if ([identifier isEqualToString:@"key"]) {
        NSTableCellView* out = [tableView makeViewWithIdentifier:@"key" owner:self];
        
        NSString* key = [fieldData objectAtIndex:row];
        [out.textField setStringValue:key];
        NSArray* views = [out subviews];
        NSButton* button;
        for (NSView* view in views){
            if ([view isKindOfClass:[NSButton class]]){
                button = (NSButton*)view;
                NSString* path = [NSString stringWithFormat:@"%@/Images/minus.png", [[NSBundle mainBundle]resourcePath]];
                [button setImage:[[NSImage alloc]initWithContentsOfFile:path]];
            }
        }
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
        NSString* str = [selectedReference.fields valueForKey:[fieldData objectAtIndex:row]];
        [out.textField setStringValue:str? str:@""];
        return out;
    }
    return nil;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    if (notification.object==bibTable) {
        NSInteger i = [bibTable selectedRow];
        selectedReference = [selectedBib.references objectAtIndex:i];
        if (toggleViewFieldsButton.state) {
            fieldData = [[NSMutableArray alloc]initWithArray:[selectedReference.fields allKeys]];
        }else{
            fieldData = [[NSMutableArray alloc]initWithArray:[Reference getCorrespondingPrincipleFields:selectedReference.type]];
        }        
        ///order the data!
        [fieldTable reloadData];
        [typeView reloadData];
    }
}

- (IBAction)typeSeleced:(NSPopUpButton *)sender {
    NSString* newType = [sender titleOfSelectedItem];
    if ([newType isEqualToString:selectedReference.type]) return;
    selectedReference.type = newType;
    [fieldTable reloadData];
    [bibTable reloadData];
    NSInteger i = [selectedBib.references indexOfObject:selectedReference];
    NSIndexSet* asIS = [NSIndexSet indexSetWithIndex:i];
    [bibTable selectRowIndexes:asIS byExtendingSelection:NO];
}

- (IBAction)addField:(id)sender {
//    [selectedReference.fields setValue:@"" forKey:@"new_field"];
//    [fieldTable insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:selectedReference.fields.count-1] withAnimation:NSTableViewAnimationSlideLeft];
    //NSTableCellView* cell =[fieldTable viewAtColumn:0 row:selectedReference.fields.count-1 makeIfNecessary:NO];
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









@end
