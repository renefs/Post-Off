//
//  ManageCustomFieldsViewController.m
//  Post Off
//
//  Created by René on 15/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ManageCustomFieldsViewController.h"

@implementation ManageCustomFieldsViewController

@synthesize customFields,blog,cfTable;

- (id) initWithBlog:(Blog*) b{
	
	if(![super initWithNibName:@"ManageCustomFieldsView" bundle:nil]){
		return nil;
	}
	DDLogInfo(@"%s (%@)", (char*)_cmd, [self class]);

    self.blog=b;
	[self fetchCustomFields];
	
	return self;
	
}

-(void) fetchCustomFields{
    
    customFields = [[NSMutableArray alloc] init];
    
	/*NSError *error;
	
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Blog" 
											  inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
	[fetchRequest setEntity:entity];
	NSArray *fetchedObjects = [[[NSApp delegate] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil){
        NSLog(@"Error");
    }
    
    NSLog(@"Fetched Objects: %d",(int)[fetchedObjects count]);
	for (Blog *b in fetchedObjects) {
		NSLog(@"%@",[b description]);
        
		if(b.cFields!=nil){
			NSLog(@"b.cFields=: %@", [b.cFields class]);*/
			for (CustomFieldTemplate *p in blog.cFields) {
                DDLogInfo(@"%@", p);
                
                CustomFieldTemplateContainer *tc = [[CustomFieldTemplateContainer alloc] initWithCFTemplate:p andStatus:NO];
                    [customFields addObject:tc];
            }
		/*}
		
		self.blog=b;
		
	}*/
}

- (void) awakeFromNib{
	
	//NSString *defaultVoice = [NSSpeechSynthesizer defaultVoice];
	//int defaultRow = 0;
	DDLogInfo(@"%s (%@)", (char*)_cmd, [self class]);
    [nameColumn setIdentifier:@"nameColumn"];
    [keyColumn setIdentifier:@"keyColumn"];
	[checkColumn setIdentifier:@"checkColumn"];
	[typeColumn setIdentifier:@"typeColumn"];
	[optionsColumn setIdentifier:@"optionsColumn"];
	//[categoryTable selectRow:defaultRow byExtendingSelection:NO];
	
	//NSTableColumn *tableColumn = [theTableView tableColumnWithIdentifier:@"lastName"];
	
	[nameColumn setSortDescriptorPrototype:[NSSortDescriptor sortDescriptorWithKey:@"name"
																	   ascending:YES
																		selector:@selector(caseInsensitiveCompare:)]];	
	[keyColumn setSortDescriptorPrototype:[NSSortDescriptor sortDescriptorWithKey:@"key"
																		   ascending:YES
																			selector:@selector(caseInsensitiveCompare:)]];
	
	
	[optionsColumn setSortDescriptorPrototype:[NSSortDescriptor sortDescriptorWithKey:@"options"
																		 ascending:YES
																		  selector:@selector(caseInsensitiveCompare:)]];
	[typeColumn setSortDescriptorPrototype:[NSSortDescriptor sortDescriptorWithKey:@"type"
																			ascending:YES
																			 selector:@selector(caseInsensitiveCompare:)]];
	[cfTable scrollRowToVisible:0];
	[cfTable setDoubleAction:NSSelectorFromString(@"editCustomFieldTemplate")];
	
	if([customFields count]<1 || [self numberOfSelectedItems]<1){
        [deleteButton setEnabled:NO];
    }else{
        [deleteButton setEnabled:YES];
    }
	
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *) tv{
	
	return [customFields count];
	
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
	//DDLogInfo(@"%s (%@)", (char*)_cmd, [self class]);
	CustomFieldTemplate *c = [[customFields objectAtIndex:row] cf];
    //La clase NSDictionary funciona como un Set de Java, asociando unos valores
	//a unas claves {(key1, value1), (key2,value2)}
	//Aquí está utilizando de clave el nombre de la voz (NSVoiceName)
	//a los valores de la lista de voces de la clase
	//NSDictionary *dict = [NSSpeechSynthesizer attributesForVoice:v];
	//return [dict objectForKey: NSVoiceName];
    //NSLog(@"Identifier: %@", [[tableColumn headerCell] value ]);
    
    if ([[tableColumn identifier] isEqualToString:@"keyColumn"]) {
        return c.key;
    }
    
    if ([[tableColumn identifier] isEqualToString:@"nameColumn"]) {
        return c.name;
    }
    
    if ([[tableColumn identifier] isEqualToString:@"optionsColumn"]) {
        return c.options;
    }
	
	if ([[tableColumn identifier] isEqualToString:@"typeColumn"]) {
        return c.type;
    }
    
	return @"42";
}

- (void)tableView:(NSTableView *)tv willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{

	if ([[aTableColumn identifier] isEqualToString:@"checkColumn"]) {
		[aCell setTitle:@""];
		[aCell setButtonType:NSSwitchButton];
		[aCell setEnabled:YES];
		[aCell setTransparent:NO];
		CustomFieldTemplateContainer *p = [customFields objectAtIndex:rowIndex];
        
		[aCell setState:p.checkStatus];
	}
	
	
	
}

- (IBAction)checkboxChanged:(CustomTable*)sender {
	
    int row = [[sender selectedCellRowIndex] intValue];
    int column = [[sender selectedCellColumnIndex] intValue];
	//DDLogInfo(@"Slected column=%d and row=%d", column,row);
	if(row!=-1 && column!=-1){
        
        NSTableColumn* theColumn = [[sender tableColumns] objectAtIndex:column];
        id dataCell = [theColumn dataCellForRow:row];
        
        if ([dataCell isKindOfClass:[NSButtonCell class]]){
            DDLogInfo(@"La celda column=%d and row=%d es un checkbox", column,row);
            
            if(column==0){
                
                CustomFieldTemplateContainer *p = [customFields objectAtIndex:row];
                
                [p setCheckStatus:!p.checkStatus];
                
                if([customFields count]<1 || [self numberOfSelectedItems]<1){
                    [deleteButton setEnabled:NO];
                }else{
                    [deleteButton setEnabled:YES];
                }
                
                [sender reloadData]; // update listing
            }
        }
        
    }
}

- (void) tableViewSelectionDidChange:(NSNotification *) notification{
 
 NSInteger row= [cfTable selectedRow];
 if(row <0 || row > [customFields count]-1){
     
     [cfTable setSelectedCellRowIndex:[[NSNumber alloc] initWithInt:-1]];
     [cfTable setSelectedCellColumnIndex:[[NSNumber alloc] initWithInt:-1]];
     DDLogInfo(@"No hay seleccioada fila");
 
     return;
 }

 
 }

#pragma mark Delegate Methods

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)tv
{
	
	return YES;
	
}

-(int) numberOfSelectedItems{
	
	int n=0;
	int i;
	for(i=0;i<[customFields count];i++){
		
		BOOL e=[[customFields objectAtIndex:i] checkStatus];
		if(e==YES)
			n=n+1;
	}
	return n;
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
	// Either reverse the sort or change the sorting column
	[customFields sortUsingDescriptors: [tableView sortDescriptors]];
    [tableView reloadData];
}

- (IBAction)addCustomField:(id)sender{
    
    if(addFieldSheet!=nil){
        
        [self->name setStringValue:@""];
        [self->key setStringValue:@""];
        [self->type setTitle:NSLocalizedString(@"SELECT", @"Select")];
        [self->options setStringValue:@""];
        
        [options setEditable:NO];
        [options setEnabled:NO];
        [saveButton setEnabled:NO];
    }
    
	[NSApp beginSheet:addFieldSheet modalForWindow:[cfTable window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
    
    NSMenu* rootMenu = [NSApp mainMenu];
    
    for(NSMenuItem *i in [rootMenu itemArray]){
        [i setEnabled:NO];
    }
    
}

- (IBAction)typeSelector:(id)sender{
    NSString* t = [self->type titleOfSelectedItem];
    
    if([t isEqualToString:NSLocalizedString(@"SELECT", @"Select")]){
        [options setEditable:NO];
        [options setEnabled:NO];
        [saveButton setEnabled:NO];
    }
    
    if([t isEqualToString:NSLocalizedString(@"TEXT", @"Text")]){
        [options setEditable:NO];
        [options setEnabled:NO];
    }
    
    if([t isEqualToString:NSLocalizedString(@"DROPDOWN", @"Dropdown")]){
        [options setEditable:YES];
        [options setEnabled:YES];
    }
    
    if(![t isEqualToString:NSLocalizedString(@"SELECT", @"Select")]){
        [saveButton setEnabled:YES];
    }
    
}

- (IBAction)saveCurrentCFTemplate:(id)sender{
	
	DDLogInfo(@"Se crea el diccionario...");
	/*
	 @dynamic password,cFields,categories,blog;
	 @dynamic slug,tags,title,author, authorId,postId,status,content,excerpt,moreTag,permalink,dateCreated;
	 */
	DDLogInfo(@"%s (%@)", (char*)_cmd, [self class]);
	if(self.blog!=nil){
		DDLogInfo(@"Clase value=: %@", [blog class]);
		DDLogInfo(@"%@", [blog description]);
		NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
		[dict setValue:[self->name stringValue] forKey:@"name"];
		[dict setValue:[self->key stringValue] forKey:@"key"];
		[dict setValue:[self->options stringValue] forKey:@"options"];
		[dict setValue:[self->type titleOfSelectedItem] forKey:@"type"];
		[dict setValue:self.blog forKey:@"blog"];
		
		
		DDLogInfo(@"Se crea el CF...");
		BOOL done = [blog  newCustomFieldForBlog:dict];
		
		if (!done) {
			NSAlert *alert = [NSAlert alertWithMessageText:@"Custom Field couldn't be saved" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
			
			if ([alert runModal] == NSAlertFirstButtonReturn) {
				// OK clicked, delete the record
			}
			
		}
		
		if(cfTable){
			DDLogInfo(@"Se recarga la tabla...");
			[self fetchCustomFields];
			[cfTable reloadData];
		}else{
			
			DDLogInfo(@"No existe la tabla");
		}
		
		//NSString *cfTitle = [actionSelector titleOfSelectedItem];
		
		/*if(![cfTitle isEqualToString:@"Select"] || [customFields count]>0){
			[applyButton setEnabled:YES];
		}*/
			
		
		[dict release];
		[[sender window] orderOut:self];
		[NSApp endSheet:addFieldSheet];
        
        NSMenu* rootMenu = [NSApp mainMenu];
        
        for(NSMenuItem *i in [rootMenu itemArray]){
            [i setEnabled:YES];
        }
	}
	
}

- (IBAction)closeWindow:(id)sender{
	[[sender window] orderOut:self];
	[NSApp endSheet:addFieldSheet];
    NSMenu* rootMenu = [NSApp mainMenu];
    
    for(NSMenuItem *i in [rootMenu itemArray]){
        [i setEnabled:YES];
    }
}


- (IBAction)applyAction:(id)sender {

	[self deleteSelectedItems];
	
}

- (BOOL) deleteSelectedItems{
	DDLogInfo(@"deleteSelectedItems...");
	
	NSAlert *testAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"SURE_DELETE", @"Are you sure you want delete these items?")
                                         defaultButton:NSLocalizedString(@"CANCEL", @"Cancel")
                                       alternateButton:NSLocalizedString(@"DELETE", @"Delete")
                                           otherButton:nil
                             informativeTextWithFormat:NSLocalizedString(@"PERMANENTLY_DELETE", @"These items will be permanently deleted.")];
	
	
	[testAlert setAlertStyle:NSCriticalAlertStyle];
	
	[testAlert beginSheetModalForWindow:[cfTable window]
						  modalDelegate:self
						 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
							contextInfo:nil];
	
	return YES;
}

-(void)handleResult:(NSAlert *)alert withResult:(NSInteger)result
{
	//DDLogInfo(@"Handling result %@",result);
	// report which button was clicked
	switch(result)
	{
		case NSAlertDefaultReturn:
			DDLogInfo(@"result: NSAlertDefaultReturn");
			break;
			
		case NSAlertAlternateReturn:
			DDLogInfo(@"result: NSAlertAlternateReturn");
			
			DDLogInfo(@"Obteniendo categorías activadas...");
			NSMutableArray *tempCats= [[NSMutableArray alloc] init];
			
			for (int i=0; i<[customFields count]; i++) {
				if([[customFields objectAtIndex:i] checkStatus] == YES){
					[tempCats addObject:[[customFields objectAtIndex:i] cf]];
				}
			}
			
			//Borrar los campos personalizados del array.
			[blog deleteCustomFields:tempCats];
			
			[self fetchCustomFields];
			[cfTable reloadData];

			if([customFields count]<1 || [self numberOfSelectedItems]<1){
                [deleteButton setEnabled:NO];
            }else{
                [deleteButton setEnabled:YES];
            }
			
			
			break;
            
        default:
            break;
	}
	
	
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	DDLogInfo(@"Alert did end.");
#pragma unused (contextInfo)
	[[alert window] orderOut:self];
	//DDLogInfo(@"Result code: %@", returnCode);
	[self handleResult:alert withResult:returnCode];
}

- (void) editCustomFieldTemplate{
	
    NSLog(@"Editing...");
	NSInteger row= [cfTable selectedRow];
	if(row <0 || row > [customFields count]-1){
		
		DDLogInfo(@"Doble clic sin fila");
        
	}else{
        
		CustomFieldTemplate *selectedField= [[customFields objectAtIndex:row] cf];
		DDLogInfo(@"Doble clic = %@", selectedField.name);
        [self editSelectedCFTemplate:selectedField];
		//[windowController setContentViewNewArticleViewWithPost:[posts objectAtIndex:row]];
		
	}
}

- (void)editSelectedCFTemplate:(CustomFieldTemplate* ) field{
	
    DDLogInfo(@"FIELD: %@", field);
	NSString *cfTitle = field.name;
    DDLogInfo(@"Name: %@", cfTitle);
    
	if(addFieldSheet!=nil){
        
        [self->name setStringValue:field.name];
        [self->key setStringValue:field.key];
        [self->type setTitle:field.type];
        [self->options setStringValue:field.options];
        
    }
    
    [NSApp beginSheet:addFieldSheet modalForWindow:[cfTable window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
	
}

@end
