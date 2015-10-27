//
//  ReferenceEntry.m
//  CitationTool3
//
//  Created by Thomas Gray on 10/10/2015.
//  Copyright © 2015 Thomas Gray. All rights reserved.
//

#import "ReferenceEntry.h"
#import "EditorController.h"
#import "Reference.h"
#import "Bibliography.h"
#import "AppDelegate.h"

@interface ReferenceEntry ()

-(NSArray*)keys;
-(void)reloadFieldsTab;
-(void)setTypePopUpToType:(NSString*)typ;

@end

@implementation ReferenceEntry

@synthesize parent;
@synthesize bibliographies;
@synthesize references;
@synthesize reference;

-(void)windowDidLoad{
    NSArray* types = [Reference getEntryTypes];
    [typePopUp addItemsWithTitles:types];
    
    reference = [[Reference alloc]init];
    [reference setType:ARTICLE];
    
    [addFieldButton setImage:[AppDelegate getImageNamed:@"addIconUp_19"]];
    [addFieldButton setAlternateImage:[AppDelegate getImageNamed:@"addIconDown_19"]];
    [toggleViewAllFieldButton setImage:[AppDelegate getImageNamed:@"viewIconUp_19"]];
    [toggleViewAllFieldButton setAlternateImage:[AppDelegate getImageNamed:@"viewIconDown_19"]];
    
    [self reloadFieldsTab];
}

-(void)awakeFromNib{
    for (NSInteger j=0; j<bibliographies.count; j++) {
        Bibliography* bib = [bibliographies objectAtIndex:j];
        [addToBibPopup addItemWithTitle:[bib name]];
        [[addToBibPopup itemWithTitle:bib.name] setToolTip:bib.path];
    }
    if (defaultSelectedBib<0) {
        NSInteger selection = (defaultSelectedBib + 1) *-1;
        [addToBibPopup selectItemAtIndex:(selection<bibliographies.count? selection:bibliographies.count-1)];
        [addToBibCheck setState:0];
        [addToBibPopup setEnabled:FALSE];
    }else{
        if (defaultSelectedBib>=bibliographies.count) defaultSelectedBib = bibliographies.count-1;
        [addToBibCheck setState:1];
        [addToBibPopup setEnabled:TRUE];
        [addToBibPopup selectItemAtIndex:defaultSelectedBib];
    }
}

-(void)runModal{
    [NSApp runModalForWindow:self.window];
}

-(void)setParent:(id)par{
    parent = par;
    if ([parent isMemberOfClass:[EditorController class]]) {
        bibliographies = ((EditorController*)parent).bibliographies;
        references = ((EditorController*)parent).references;
        defaultSelectedBib = [(EditorController*)parent defaultBibIndexForRefEntryPanel];
    }
}

-(void)setTypePopUpToType:(NSString*)typ{
    NSInteger i = [[Reference getEntryTypes]indexOfObject:typ];
    [typePopUp selectItemAtIndex:i];
}

-(void)reloadFieldsTab{
    [fieldTable reloadData];
    [self setTypePopUpToType:reference.type];
    if (reference.key) [keyField setStringValue:reference.key];
}


#pragma mark Actions

-(IBAction)bibPopUpSelection:(id)sender{
    if (![addToBibPopup isEnabled]) {
        return;
    }
    defaultSelectedBib = [addToBibPopup indexOfSelectedItem];
}


-(IBAction)toggleAddToBib:(id)sender{
    if (addToBibCheck.state && defaultSelectedBib<0) {
        defaultSelectedBib++;
        defaultSelectedBib *=-1;
    }else if (!addToBibCheck.state && defaultSelectedBib>=0){
        defaultSelectedBib++;
        defaultSelectedBib *=-1;
    }
    if (!bibliographies) return;
    if (addToBibCheck.state) {
        [addToBibPopup setEnabled:TRUE];
        if (defaultSelectedBib>=bibliographies.count) defaultSelectedBib = bibliographies.count-1;
        [addToBibPopup selectItemAtIndex:defaultSelectedBib];
    }else{
        [addToBibPopup setEnabled:FALSE];
    }
}


-(IBAction)toggleViewAllFields:(id)sender{
    [fieldTable reloadData];
    [addFieldButton setEnabled:toggleViewAllFieldButton.state];
}

-(IBAction)selectedType:(id)sender{
    NSInteger i = [typePopUp indexOfSelectedItem];
    NSString* type = [[Reference getEntryTypes]objectAtIndex:i];
    [reference setType:type];
    [fieldTable reloadData];
}

-(IBAction)addField:(id)sender{
    NSString* newKey = [reference addFieldValueNullable:nil forKeyNullable:nil isTexFormat:NO];
    NSInteger i = [[self keys]indexOfObject:newKey];
    [fieldTable insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:i] withAnimation:NSTableViewAnimationSlideDown];
    NSTableCellView* cell = [fieldTable viewAtColumn:0 row:i makeIfNecessary:NO];
    [cell.textField selectText:nil];
}

-(IBAction)removeField:(id)sender{
    
}


-(IBAction)close:(id)sender{
    [NSApp stopModal];
    [self.window close];
    if ([parent isMemberOfClass:[EditorController class]]) {
        [(EditorController*)parent setDefaultBibIndexForRefEntryPanel:defaultSelectedBib];
        [(EditorController*)parent referenceModalEnded:NO];
    }
}

-(IBAction)done:(id)sender{
    [NSApp stopModal];
    [self.window close];
    if ([parent isMemberOfClass:[EditorController class]]) {
        [references addObject:reference];
        if (addToBibCheck.state) {
            NSInteger indx = [addToBibPopup indexOfSelectedItem];
            Bibliography* bib = [bibliographies objectAtIndex:indx];
            //add reference to bib;
            [bib.references addObject:reference];
            [bib saveToBibFile];
            [(AppDelegate*)([NSApplication sharedApplication].delegate) registerBibUpdate];
        }
        [(EditorController*)parent setDefaultBibIndexForRefEntryPanel:defaultSelectedBib];
        [(EditorController*)parent referenceModalEnded:TRUE];
    }
}


#pragma mark Table View Delegate Methods

-(NSArray*)keys{
    return toggleViewAllFieldButton.state? [reference keys]:[Reference getCorrespondingPrincipleFields:reference.type];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if (!reference) return 0;
    if (toggleViewAllFieldButton.state) {
        return reference.fields.count;
    }else{
        NSArray* fields = [Reference getCorrespondingPrincipleFields:reference.type];
        return fields.count;
    }
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if ([tableColumn.identifier isEqualToString:@"keys"]) {
        NSTableCellView* out = [tableView makeViewWithIdentifier:@"keys" owner:self];
        NSButton* but = [out.subviews firstObject];
        NSTextField* tfield = [out.subviews lastObject];
        [but setImage:[AppDelegate getImageNamed:@"removeIconUp_19"]];
        [but setAlternateImage:[AppDelegate getImageNamed:@"removeIconDown_19"]];
        
        NSArray* keys = [self keys];
        NSString* key = [keys objectAtIndex:row];
        [out.textField setStringValue:key];
        if ([[Reference getEstablishedFields]containsObject:key]) {
            [but setHidden:TRUE];
            [tfield setEditable:FALSE];
        }else{
            [but setHidden:FALSE];
            [tfield setEditable:TRUE];
        }

        return out;
    }else if ([tableColumn.identifier isEqualToString:@"values"]){
        NSTableCellView* out = [tableView makeViewWithIdentifier:@"values" owner:self];
        NSArray* keys = [self keys];
        NSString* val = [reference.fields valueForKey:[keys objectAtIndex:row]];
        [out.textField setStringValue:val];

        return out;
    }
    return nil;
}


#pragma mark Text Delegate Methods

-(void)textDidChange:(NSNotification *)notification{
    NSString* str = [texView.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    @try {
        [reference getDataFromBib:str];
        [texView.textStorage setAttributes:@{NSForegroundColorAttributeName:[NSColor blackColor]} range:NSMakeRange(0, str.length)];
        [self reloadFieldsTab];
    }
    @catch (NSException *exception) {
        [texView.textStorage setAttributes:@{NSForegroundColorAttributeName:[NSColor redColor]} range:NSMakeRange(0, str.length)];
    }
}


#pragma mark Text Field Delegate Methods

-(void)controlTextDidChange:(NSNotification *)obj{
    NSTextField* tfield = (NSTextField*)obj.object;
    if ([tfield.identifier isEqualToString:@"texkey"]) {
        [reference setKey:tfield.stringValue];
        [reference setKeyAutoGenerated:FALSE];
        return;
    }
    NSInteger index = [fieldTable rowForView:tfield];
    NSArray* keys = [self keys];
    if ([tfield.identifier isEqualToString:@"key"]) {
        NSString* oldkey = [keys objectAtIndex:index];
        NSString* newkey = tfield.stringValue;
        [reference.keys replaceObjectAtIndex:index withObject:newkey];
        
        NSString* val = [reference.fields valueForKey:oldkey];
        [reference.fields removeObjectForKey:oldkey];
        [reference.fields setObject:val forKey:newkey];
        
        val = [reference.texFields objectForKey:oldkey];
        [reference.texFields removeObjectForKey:oldkey];
        [reference.texFields setObject:val forKey:newkey];
    }else{//so it's the value that's changing
        NSString* key = [keys objectAtIndex:index];
        NSString* newval = tfield.stringValue;
        [reference modifyField:newval forKey:key isTexFormat:NO];
    }
}


#pragma mark Tab View Delegate

-(void)tabView:(NSTabView *)tview didSelectTabViewItem:(NSTabViewItem *)tabViewItem{
    if (tabViewItem == [tabView tabViewItemAtIndex:1]) {
        [texView setString:[reference getTexString]];
    }
}

@end

















