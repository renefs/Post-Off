//
//  MyClass.m
//  Post Off
//
//  Created by Rene Fernandez on 04/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ManageCategoriesViewController.h"

@implementation ManageCategoriesViewController

@synthesize blog,categories;

- (id) initWithBlog:(Blog*) b{
	
	if(![super initWithNibName:@"ManageCategoriesView" bundle:nil]){
		return nil;
	}
	DDLogInfo(@"%s (%@)", (char*)_cmd, [self class]);
    
    self.blog=b;
    
    [self fetchCategories];
    
	return self;
	
}

- (void) fetchCategories{
	
    categories = [[NSMutableArray alloc] init];
    
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
        
        NSLog(@"b.categories=: %@", [b.categories class]);
*/
        
        for (Category *c in blog.categories) {
            DDLogInfo(@"%@", c);
            
            CategoryContainer *sc = [[CategoryContainer alloc] initWithCategory:c andStatus:NO];
            [categories addObject:sc];
        }
        
        DDLogInfo(@"Categorías añadidas: %d",[categories count]);
        
        /*for (CategoryContainer *sc in categories) {
            //DDLogInfo(@"Categorías añadidas: %@",sc.status);
        }
        
        
        self.blog=b;
	}*/
	
}

- (void) awakeFromNib{
	
	//NSString *defaultVoice = [NSSpeechSynthesizer defaultVoice];
	//int defaultRow = 0;
    [idColumn setIdentifier:@"idColumn"];
    [nameColumn setIdentifier:@"nameColumn"];
    [parentColumn setIdentifier:@"parentColumn"];
	[checkColumn setIdentifier:@"checkColumn"];
	//[categoryTable selectRow:defaultRow byExtendingSelection:NO];
	
	//NSTableColumn *tableColumn = [theTableView tableColumnWithIdentifier:@"lastName"];

	[idColumn setSortDescriptorPrototype:[NSSortDescriptor sortDescriptorWithKey:@"categoryId"
																	   ascending:YES
																		selector:@selector(compare:)]];	
	[parentColumn setSortDescriptorPrototype:[NSSortDescriptor sortDescriptorWithKey:@"parentId"
																		   ascending:YES
																			selector:@selector(compare:)]];
	
	[nameColumn setSortDescriptorPrototype:[NSSortDescriptor sortDescriptorWithKey:@"categoryName"
																		 ascending:YES
																		  selector:@selector(caseInsensitiveCompare:)]];
	
	[categoryTable scrollRowToVisible:0];
    
    if([categories count]<1 || [self numberOfSelectedItems]<1){
		[deleteButton setEnabled:NO];
	}else{
		[deleteButton setEnabled:YES];
	}
	
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *) tv{
	
	return [categories count];
	
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
	
	Category *c = [[categories objectAtIndex:row] category];
    //La clase NSDictionary funciona como un Set de Java, asociando unos valores
     //a unas claves {(key1, value1), (key2,value2)}
     //Aquí está utilizando de clave el nombre de la voz (NSVoiceName)
     //a los valores de la lista de voces de la clase
	//NSDictionary *dict = [NSSpeechSynthesizer attributesForVoice:v];
	//return [dict objectForKey: NSVoiceName];
    //NSLog(@"Identifier: %@", [[tableColumn headerCell] value ]);
    
    if ([[tableColumn identifier] isEqualToString:@"idColumn"]) {
        return c.categoryId;
    }
    
    if ([[tableColumn identifier] isEqualToString:@"nameColumn"]) {
        return c.categoryName;
    }
    
    if ([[tableColumn identifier] isEqualToString:@"parentColumn"]) {
		
		if([c.parentId intValue] == 0)
			return NSLocalizedString(@"NONE", @"None");
		
		for (CategoryContainer *cat in categories) {
            Category *tempCat = cat.category;
			if([tempCat.categoryId intValue] == [c.parentId intValue])
				return tempCat.categoryName;
		}
		
        return @"Not found";
    }
    
	return @"42";
}

- (void)tableView:(NSTableView *)tv willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
	
	//NSLog(@"%@",rowIndex);
	//Post *p = [posts objectAtIndex:rowIndex];
	//La clase NSDictionary funciona como un Set de Java, asociando unos valores
	//a unas claves {(key1, value1), (key2,value2)}
	//Aquí está utilizando de clave el nombre de la voz (NSVoiceName)
	//a los valores de la lista de voces de la clase
	//NSDictionary *dict = [NSSpeechSynthesizer attributesForVoice:v];
	//return [dict objectForKey: NSVoiceName];
	//NSLog(@"Identifier: %@", [[tableColumn headerCell] value ]);
	
	//NSButtonCell *currentButton = [[NSButtonCell alloc] init];
	//[currentButton setButtonType:NSSwitchButton];
	if ([[aTableColumn identifier] isEqualToString:@"checkColumn"]) {
		[aCell setTitle:@""];
		[aCell setButtonType:NSSwitchButton];
		[aCell setEnabled:YES];
		[aCell setTransparent:NO];
        
        CategoryContainer *sc = [categories objectAtIndex:rowIndex];
        
		[aCell setState: sc.checkStatus];
        
	}
	
	
	
}

- (IBAction)checkboxChanged:(CustomTable*)sender {
    int row = [[sender selectedCellRowIndex] intValue];
    int column = [[sender selectedCellColumnIndex] intValue];
	DDLogInfo(@"Slected column=%d and row=%d", column,row);
    
    if(row!=-1 && column!=-1){
        
        NSTableColumn* theColumn = [[sender tableColumns] objectAtIndex:column];
        id dataCell = [theColumn dataCellForRow:row];
        
        if ([dataCell isKindOfClass:[NSButtonCell class]]){
            DDLogInfo(@"La celda column=%d and row=%d es un checkbox", column,row);
            
            if(!([categories count]==0 || row <0 || row > [categories count]-1) && column==0){
                
                CategoryContainer *sc = [categories objectAtIndex:row];
                
                [sc setCheckStatus:!sc.checkStatus];
                
                /*BOOL inverse=![[categoryState objectAtIndex:row] boolValue];
                
                [categoryState replaceObjectAtIndex:row withObject:[NSNumber numberWithBool:inverse]];*/
                
                if([categories count]<1 || [self numberOfSelectedItems]<1){
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
	
	NSInteger row= [categoryTable selectedRow];
	if(row <0 || row > [categories count]-1){
		[categoryTable setSelectedCellRowIndex:[[NSNumber alloc] initWithInt:-1]];
        [categoryTable setSelectedCellColumnIndex:[[NSNumber alloc] initWithInt:-1]];
		DDLogInfo(@"No hay seleccioada fila");
		
		return;
	}
	
	NSString *selectedVoice= [categories objectAtIndex:row];
	DDLogInfo(@"Nueva voz = %@", selectedVoice);
	
}

#pragma mark Delegate Methods

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)tv
{
	
	return YES;
	
}

-(int) numberOfSelectedItems{
	
	int n=0;
	int i;
	for(i=0;i<[categories count];i++){
		
        CategoryContainer *sc = [categories objectAtIndex:i];
        
		BOOL e=sc.checkStatus;
		if(e==YES)
			n=n+1;
	}
	return n;
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
    
    
	// Either reverse the sort or change the sorting column
	[categories sortUsingDescriptors: [tableView sortDescriptors]];
    
    
    
    [tableView reloadData];
}


- (IBAction)deleteAction:(id)sender {
	
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
	
	[testAlert beginSheetModalForWindow:[categoryTable window]
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
			
			for (int i=0; i<[categories count]; i++) {
                
                CategoryContainer *sc = [categories objectAtIndex:i];
                
				if(sc.checkStatus == YES){
					[tempCats addObject:sc.category];
				}
			}
			
			//Borrar los campos personalizados del array.
			[blog deleteCategories:tempCats];
			
			[self fetchCategories];
			[categoryTable reloadData];
			
			if([categories count]<1 || [self numberOfSelectedItems]<1){
				[deleteButton setEnabled:NO];
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

- (IBAction)sync:(id)sender{
	[self syncItems];
}

- (void) syncItems{
	
	WordpressApi *api = [[WordpressApi alloc] initWithUser:blog.userName andPassword:blog.password andUrl:blog.xmlrpc andBlogId:[blog.blogId stringValue]];
	
	[loadingIndicator startAnimation:loadingSheet];
	[NSApp beginSheet:loadingSheet modalForWindow:[categoryTable window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
	
	DDLogInfo(@"Sincronizando categorías...");
	 [loadingLabel setStringValue:NSLocalizedString(@"SYNCING_CATEGORIES",@"Syncing categories...")];
	 
	 for(Category *c in blog.categories){
	 
	 if(c.categoryId==nil){				
	 [api addNewCategory:c];
	 }
	 
	 }
	 
	 
	 NSMutableArray *cate=[api getCategories];
	 [blog syncCategoriesFromArray:cate];
	 [blog saveData];
	 DDLogInfo(@"Sincronizando categorías... OK");
	[self fetchCategories];
	[categoryTable reloadData];
	
	[loadingIndicator stopAnimation:loadingSheet];
	
	[loadingSheet orderOut:self];
	[NSApp endSheet:loadingSheet];
	
}

-(IBAction)showAddSheet:(id)sender{
	
	[NSApp beginSheet:addNewSheet modalForWindow:[categoryTable window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
	
}


-(IBAction)addNewCategory:(id)sender{
	
	//WordpressApi *api = [[WordpressApi alloc] initWithUser:blog.userName andPassword:blog.password andUrl:blog.xmlrpc andBlogId:[blog.blogId stringValue]];
	
	//[loadingIndicator startAnimation:loadingSheet];
	
	DDLogInfo(@"Añadiendo categoría...");
	
	if([newCatName stringValue]!=nil){
		//Si la categoría ya existe, se cancela...
		for(Category *c in blog.categories){
		
			if([c.categoryName isEqualToString:[newCatName stringValue]]){				
				//[api addNewCategory:c];
			
				[addNewSheet orderOut:self];
				[NSApp endSheet:addNewSheet];
			
				return;
			}
		
		}
	
		Category* cat= [[[Category alloc] initWithEntity:[NSEntityDescription entityForName:@"Category"
																	 inManagedObjectContext:[self.blog managedObjectContext]]
						  insertIntoManagedObjectContext:[self.blog managedObjectContext]] autorelease];
		DDLogInfo(@"Se añaden los atributos... %@", [newCatName stringValue]);		
		cat.categoryName=[newCatName stringValue];
		cat.categoryId=0;
		cat.blog=self.blog;
		DDLogInfo(@"Se añade el objeto");
		[categories addObject:cat];
		[blog saveData];
	
	
		DDLogInfo(@"Añadiendo categoría... OK");
		[self fetchCategories];
		[categoryTable reloadData];
		
	}
	
	[addNewSheet orderOut:self];
	[NSApp endSheet:addNewSheet];
	
}

- (IBAction)closeWindow:(id)sender{
	[[sender window] orderOut:self];
	[NSApp endSheet:[sender window]];
}

@end
