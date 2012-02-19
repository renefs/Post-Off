//
//  CustomFieldTableDelegate.m
//  Post Off
//
//  Created by René on 16/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomFieldTableDelegate.h"
#import "NewArticleViewController.h"

@implementation CustomFieldTableDelegate

@synthesize post,customFields,cfTable,viewController,blog;

-(id) initWithPost:(Post*) p{
	DDLogInfo(@"%s (%@)", (char*)_cmd, [self class]);
	self = [super init];
	if(!self){
		return nil;		
	}
	
	self.post=p;
	[self fetchPostCustomFields];
	
	return self;
}

/*-(void) setViewController:(NewArticleViewController *)v{
    self.viewController=v;
    DDLogInfo(@"Cargando");
    if(self.viewController!=nil)
        DDLogInfo(@"Controlador cargado");
}*/

-(id) init{
	
	self = [super init];
	if(!self){
		return nil;		
	}
	DDLogInfo(@"%s (%@)", (char*)_cmd, [self class]);
	customFields = [[NSMutableArray alloc] init];
	
	
	return self;
}

-(void) awakeFromNib{
	
	DDLogInfo(@"%s (%@) JUR", (char*)_cmd, [self class]);
    [cfTable setTarget:self];
    [cfTable setDoubleAction:NSSelectorFromString(@"editCustomField")];
}

- (void) fetchPostCustomFields{
	
	if(post==nil){
		DDLogInfo(@"No post found. Is this post new?");            
		
	}else{
		DDLogInfo(@"Post found..."); 
		if(post.cFields!=nil){
			DDLogInfo(@"cFields not nil...");
			DDLogInfo(@"b.custom=: %@", [self.post.cFields class]);
			customFields= [[self.post.cFields allObjects] mutableCopy];
			
			if(customFields!=nil){
				NSLog(@"cFields=: %@", [self.post.cFields class]);
				unsigned cuantos = (unsigned)[customFields count];
				NSLog(@"Number of customFields: %d",cuantos);
				
				for (CustomField *c in customFields) {
					//NSLog(@"%@",[c description]);
				}
				
				
			}else{
				DDLogInfo(@"EROR: No customFields found.");            
			}
			
		}
		
		
	}
	
}

- (void) addCustomField:(CustomField*) c toPost:(Post*) p{
	
	
	DDLogInfo(@"Clase value=: %@", [post class]);
	DDLogInfo(@"%@", [post description]);
	NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
	[dict setValue:@"valor" forKey:@"value"];
	[dict setValue:c.key forKey:@"key"];
	[dict setValue:self.post forKey:@"post"];
	/*				 @"status",@"draft",
	 @"content",@"contenido de prueba",
	 @"author",@"rene",
	 @"title",@"titulo del poist",
	 @"blog",self.blog,
	 nil];*/
	
	DDLogInfo(@"Se crea el post...");
	BOOL done = [post addCustomFieldFromDictionary:dict];
	
	if (!done) {
		NSAlert *alert = [NSAlert alertWithMessageText:@"Alert couldn't be saved" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
		
		if ([alert runModal] == NSAlertFirstButtonReturn) {
			// OK clicked, delete the record
		}
		
	}
}
	

- (NSInteger)numberOfRowsInTableView:(NSTableView *) tv{
	return [customFields count];
	
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
	CustomField *cf = [customFields objectAtIndex:rowIndex];
	//DDLogInfo(@"%s (%@)", (char*)_cmd, [self class]);
	return cf.key;
}

- (void) tableViewSelectionDidChange:(NSNotification *) notification{
	
	NSInteger row= [cfTable selectedRow];
	if(row == -1){
		
		NSLog(@"No hay seleccioada fila");
		
		return;
	}
	
	NSString *selectedVoice= [customFields objectAtIndex:row];
	NSLog(@"Nueva voz = %@", selectedVoice);
	
}

#pragma mark Delegate Methods

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)tv
{
	
	return YES;
	
}

- ( void ) deleteKeyPressed: ( NSTableView * ) view onRow: ( int ) rowIndex{
    
    CustomField *c= [customFields objectAtIndex:rowIndex];
    [viewController.cfSelector addItemWithTitle:c.key];
    [customFields removeObjectAtIndex:rowIndex];
    
    [cfTable reloadData];
    
}

- (void) editCustomField{
	
    NSLog(@"Editing...");
	NSInteger row= [cfTable selectedRow];
	if(row <0 || row > [customFields count]-1){
		
		DDLogInfo(@"Doble clic sin fila");
        
	}else{
        
		CustomField *selectedField= [customFields objectAtIndex:row];
		DDLogInfo(@"Doble clic = %@", selectedField.key);
        [self editSelectedCustomField:selectedField];
		//[windowController setContentViewNewArticleViewWithPost:[posts objectAtIndex:row]];
		
	}
}

- (void)editSelectedCustomField:(CustomField* ) field{
	
    DDLogInfo(@"FIELD: %@", field);
	NSString *cfTitle = field.key;
    DDLogInfo(@"Key: %@", cfTitle);
    
    if(viewController!=nil){
        
        CustomFieldTemplate *cf= [viewController findCustomFieldTemplateWithKey:cfTitle];
        DDLogInfo(@"El cf es %@", cf.key);
        
		//Se ha borrado la plantilla del campo personalizado o no existe por alguna razón.
		if(cf==nil){
			
			NSArray *cfs = [[NSArray alloc] initWithObjects:field, nil];
			
			for (CustomField *customField in cfs) {
					
					//NSString *value = [customField objectForKey:@"value"];
					DDLogInfo(@"Añadiendo campo %@...", customField.key);
					NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
					DDLogInfo(@"Se establece el nombre");
					[dict setValue:customField.key forKey:@"name"];
					DDLogInfo(@"Se establece key");
					[dict setValue:customField.key forKey:@"key"];
					[dict setValue:@"" forKey:@"options"];
					[dict setValue:NSLocalizedString(@"TEXT", @"Text") forKey:@"type"];
					[dict setValue:self.blog forKey:@"blog"];
					
					if(self.blog!=nil){
						[self.blog newCustomFieldForBlog:dict];
					}else{
						DDLogInfo(@"Error: blog es nil");			
					}
	
			}
			
			[viewController fetchCustomFieldsTemplates];
			cf= [viewController findCustomFieldTemplateWithKey:cfTitle];
			DDLogInfo(@"El cf es %@", cf.key);
			
		}
			
		if ([cf.type isEqualToString:NSLocalizedString(@"DROPDOWN", @"Dropdown")]) {
			DropdownCFWindowController *addCustomFieldController = [[DropdownCFWindowController alloc] initWithController:self->viewController andCustomFieldTemplate:cf forBlog:self.blog];
				
			NSWindow *textWindow=[addCustomFieldController window];
			[addCustomFieldController.valueSelector selectItemWithTitle:field.value];
			[addCustomFieldController.addButton setTitle:NSLocalizedString(@"UPDATE", @"Update")];
			[NSApp beginSheet:textWindow modalForWindow:[cfTable window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
				
			DDLogInfo(@"Showing %@", addCustomFieldController);
			[addCustomFieldController showWindow:self];
				
				
		//Default
		}else{
			DDLogInfo(@"Se carga el controlador del campo de texto.");
			TextCFWindowController *addCustomFieldController = [[TextCFWindowController alloc] initWithController:self->viewController andCustomFieldTemplate:cf forBlog:self.blog];
				
			NSWindow *textWindow=[addCustomFieldController window];
			DDLogInfo(@"Se pone el valor del campo.");
			[addCustomFieldController.value setStringValue:field.value];
			DDLogInfo(@"Se cambia el valor del botón de añadir de la ventana.");
			[addCustomFieldController.addButton setTitle:NSLocalizedString(@"UPDATE", @"Update")];
			[NSApp beginSheet:textWindow modalForWindow:[cfTable window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
				
			DDLogInfo(@"Showing %@", addCustomFieldController);
			[addCustomFieldController showWindow:self];           
		}
        
    }else{
    
        DDLogInfo(@"viewController es nil");
    }
	
}


@end
