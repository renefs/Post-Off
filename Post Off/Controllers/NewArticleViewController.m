//
//  NewArticleViewController.m
//  Post Off
//
//  Created by René on 22/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NewArticleViewController.h"

@implementation NewArticleViewController

@synthesize blog, post,cfTable,cfDelegate,cfSelector,contentField,mainWindowController;

- (id) initWithBlog:(Blog*) b  andWindowController:(MainWindowController*) mc;{
	
	if(![super initWithNibName:@"NewArticleView" bundle:nil]){
		return nil;
	}
	[self setTitle:@"New Article"];
	DDLogInfo(@"%s (%@)", (char*)_cmd, [self class]);
	
	self.blog=b;
    self.mainWindowController=mc;
	[self fetchCategories];
	[self fetchCustomFieldsTemplates];
	//postCustomFields = [[NSMutableArray alloc] init];
	
	return self;
	
}

- (id) initWithBlog:(Blog*) b andPost:(Post*) p  andWindowController:(MainWindowController*) mc;{
	
	if(![super initWithNibName:@"NewArticleView" bundle:nil]){
		return nil;
	}
	DDLogInfo(@"%s (%@)", (char*)_cmd, [self class]);
	
	self.post=p;
	self.blog=b;
    self.mainWindowController=mc;
    
	[self fetchCategories];
	[self fetchCustomFieldsTemplates];
	DDLogInfo(@"Cargando customFields del post...");
	if(p.cFields){
		self->postCustomFields = [p.cFields mutableCopy];
		[cfDelegate setPost:self.post];
		[cfDelegate fetchPostCustomFields];
        DDLogInfo(@"Se establece el controlador...");
	}
	if(p.categories){
		
		//Se marcan todas las categorías a las que pertenece el post.
		for(Category *c in p.categories){
			
			for (int i=0; i< [categories count]; i++) {
				if ([[c categoryName] isEqualToString:[[categories objectAtIndex:i] categoryName] ]) {
					BOOL inverse=![[categoryState objectAtIndex:i] boolValue];
					[categoryState replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:inverse]];
				}
			}
			
		}
				
	}

	DDLogInfo(@"customFields cargados...");
	return self;
	
}

/*- (void) loadCurrentBlog{
	
	NSError *error;
	
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Blog" 
											  inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
	[fetchRequest setEntity:entity];
	NSArray *fetchedObjects = [[[NSApp delegate] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	if (fetchedObjects == nil){
		DDLogInfo(@"Error");
	}
	
	NSLog(@"Fetched Objects: %d",(int)[fetchedObjects count]);
	self.blog= [fetchedObjects objectAtIndex:0];
	
	NSLog(@"BLOG: %@", blog.description);
	
	if(blog==nil)
		DDLogInfo(@"EROR: No categories found.");            
	
}*/

- (IBAction)pullsDownAction:(id)sender{
	
	DDLogInfo(@"Change level: %@", [sender titleOfSelectedItem]);
}

-(void)save{
	
	DDLogInfo(@"Se crea el diccionario...");
	/*
	 @dynamic password,cFields,categories,blog;
	 @dynamic slug,tags,title,author, authorId,postId,status,content,excerpt,moreTag,permalink,dateCreated;
	 */
	if(self.blog!=nil){
		DDLogInfo(@"Clase value=: %@", [blog class]);
		DDLogInfo(@"%@", [blog description]);
		NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
		[dict setValue:[tagsField stringValue] forKey:@"tags"];
		[dict setValue:[contentField string] forKey:@"content"];
		[dict setValue:blog.userName forKey:@"author"];
		[dict setValue:[titleField stringValue] forKey:@"title"];
		
		if([[statusSelector titleOfSelectedItem] isEqualToString:NSLocalizedString(@"DRAFT", @"Draft")]){
			[dict setValue:@"draft" forKey:@"status"];
		}else if([[statusSelector titleOfSelectedItem] isEqualToString:NSLocalizedString(@"PUBLISH", @"Publish")]){
			[dict setValue:@"publish" forKey:@"status"];
		}
		
		[dict setValue:@"standard" forKey:@"postFormat"];
        [dict setValue:post.objectID forKey:@"objectID"];
		NSDate *now = [[NSDate alloc] init];
		[dict setValue:now forKey:@"dateCreated"];
		[dict setValue:self.blog forKey:@"blog"];
		/*				 @"status",@"draft",
		 @"content",@"contenido de prueba",
		 @"author",@"rene",
		 @"title",@"titulo del poist",
		 @"blog",self.blog,
		 nil];*/
		
		DDLogInfo(@"Obteniendo categorías activadas...");
		NSMutableArray *tempCats= [[NSMutableArray alloc] init];
		
		for (int i=0; i<[categoryState count]; i++) {
			if([[categoryState objectAtIndex:i] boolValue] == 1){
				[tempCats addObject:[categories objectAtIndex:i]];
			}
		}
		
		DDLogInfo(@"Se crea el post con %d categorías ...", [tempCats count]);
		Post* p = [blog  newDraftForBlog:dict andCustomFields:cfDelegate.customFields andCategories:tempCats];
		
		if (!p) {
			NSAlert *alert = [NSAlert alertWithMessageText:@"Alert couldn't be saved" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
			
			if ([alert runModal] == NSAlertFirstButtonReturn) {
				// OK clicked, delete the record
			}
			
		}else{
			self.post=p;		
		}
		
		[now release];
		[dict release];
	}
	
}


- (IBAction)saveCurrentPost:(id)sender{
	
	[self save];
}
	

- (void) fetchCategories{
			
	if(self.blog==nil){
		DDLogInfo(@"EROR: No blog found");            

	}else{

		DDLogInfo(@"b.categories=: %@", [self.blog.categories class]);
		categories= [[self.blog.categories allObjects] mutableCopy];
			
		if(categories!=nil){
			DDLogInfo(@"categories=: %@", [self.blog.categories class]);
			unsigned cuantos = (unsigned)[categories count];
			DDLogInfo(@"Number of cats: %d",cuantos);
			
			for (Category *c in categories) {
				DDLogInfo(@"%@",[c description]);
			}
			
			unsigned i;
			categoryState=[[NSMutableArray alloc] initWithCapacity:cuantos];
			for(i=0;i<cuantos;i++)
				[categoryState addObject:[NSNumber numberWithBool:NO]];
				
		}else{
			DDLogInfo(@"EROR: No categories found.");            
		}
	}
	
}

- (void) fetchCustomFieldsTemplates{
	
	if(self.blog==nil){
		DDLogInfo(@"EROR: No blog found");            
		
	}else{
		
		DDLogInfo(@"b.custom=: %@", [self.blog.cFields class]);
		customFieldsTemplates= [[self.blog.cFields allObjects] mutableCopy];
		
		if(customFieldsTemplates!=nil){
			DDLogInfo(@"cFields=: %@", [self.blog.cFields class]);
			unsigned cuantos = (unsigned)[customFieldsTemplates count];
			DDLogInfo(@"Number of customFields: %d",cuantos);
			
			for (CustomFieldTemplate *c in customFieldsTemplates) {
				//DDLogInfo(@"%@",[c description]);
			}
			
			/*unsigned i;
			categoryState=[[NSMutableArray alloc] initWithCapacity:cuantos];
			for(i=0;i<cuantos;i++)
				[categoryState addObject:[NSNumber numberWithBool:NO]];*/
			
		}else{
			DDLogInfo(@"EROR: No customFields found.");            
		}
	}
	
}

- (void) awakeFromNib{
	
	DDLogInfo(@"%s (%@)", (char*)_cmd, [self class]);
	//Categories
	int defaultRow = 0;
	DDLogInfo(@"Cargando tabla de categorías... %s (%@)", (char*)_cmd, [self class]);
	[categoriesTable scrollRowToVisible:defaultRow];
	[cfTable setDelegate:cfDelegate];
	[cfTable setDataSource:cfDelegate];
	//Fields
	DDLogInfo(@"Rellenando los campos del post... %s (%@)", (char*)_cmd, [self class]);
	if (self.post!=nil) {
		if(post.title!=nil)
			[titleField setStringValue:post.title];
		if(post.tags!=nil)
			[tagsField setStringValue:post.tags];
		if(post.content!=nil)
			[contentField insertText:post.content];
		cfDelegate.post=self.post;
		[cfDelegate fetchPostCustomFields];
	}
	DDLogInfo(@"Añadiendo los campos personalizados al post... %s (%@)", (char*)_cmd, [self class]);
	unsigned i=0;
	for(CustomFieldTemplate* c in customFieldsTemplates){
		DDLogInfo(@"%d",i);
		i=i+1;
		[cfSelector addItemWithTitle:c.key];
	}
    
    for(CustomField* c in postCustomFields){
        DDLogInfo(@"CustomField: %@", c.key);
        for (NSString* item in [cfSelector itemTitles]) {
            DDLogInfo(@"cfSelector: %@ VS CustomField: %@", item, c.key);
            if([c.key isEqualToString:item]){
                DDLogInfo(@"Removing: %@", item);
                [cfSelector removeItemWithTitle:item];
            }
        }
	}
    
    [cfDelegate setViewController:self];
	[cfDelegate setBlog:self.blog];
    [cfTable reloadData];
	[[mainWindowController window] makeFirstResponder:self.contentField];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *) tv{
 
 return [categories count];
 
 }

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
	
	
	return @"42";
}
 
 - (void)tableView:(NSTableView *)tv willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
 
	 //DDLogInfo(@"%@",rowIndex);
 Category *c = [categories objectAtIndex:rowIndex];
 //La clase NSDictionary funciona como un Set de Java, asociando unos valores
 //a unas claves {(key1, value1), (key2,value2)}
 //Aquí está utilizando de clave el nombre de la voz (NSVoiceName)
 //a los valores de la lista de voces de la clase
 //NSDictionary *dict = [NSSpeechSynthesizer attributesForVoice:v];
 //return [dict objectForKey: NSVoiceName];
 //NSLog(@"Identifier: %@", [[tableColumn headerCell] value ]);
 
	 //NSButtonCell *currentButton = [[NSButtonCell alloc] init];
	 //[currentButton setButtonType:NSSwitchButton];
	 [aCell setTitle:c.categoryName];
	 [aCell setButtonType:NSSwitchButton];
	 [aCell setEnabled:YES];
	 [aCell setTransparent:NO];
	 [aCell setState:[[categoryState objectAtIndex:rowIndex] boolValue]];

 }

- (void) keyDown:(NSEvent *) theEvent
{
    
}

- (IBAction)checkboxChanged:(NSTableView*)sender {
    int row= (int)[sender selectedRow];
	if(!(row <0 || row > [categories count]-1)){
		BOOL inverse=![[categoryState objectAtIndex:row] boolValue];
	
		[categoryState replaceObjectAtIndex:row withObject:[NSNumber numberWithBool:inverse]];
	 
		[sender reloadData]; // update listing
	}
}
 
 - (void) tableViewSelectionDidChange:(NSNotification *) notification{
 
 NSInteger row= [categoriesTable selectedRow];
 if(row == -1){
 
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

- (IBAction)addCustomField:(id)sender{
	
	NSString *cfTitle = [cfSelector titleOfSelectedItem];
	
	CustomFieldTemplate *cf= [self findCustomFieldTemplateWithKey:cfTitle];
	DDLogInfo(@"El cf es %@", cf.name);
	
	if ([cf.type isEqualToString:NSLocalizedString(@"DROPDOWN", @"Dropdown")]) {
		DropdownCFWindowController *addCustomFieldController = [[DropdownCFWindowController alloc] initWithController:self andCustomFieldTemplate:cf forBlog:blog];
        
        NSWindow *textWindow=[addCustomFieldController window];
        
        [NSApp beginSheet:textWindow modalForWindow:[cfTable window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
        
        NSMenu* rootMenu = [NSApp mainMenu];
        
        for(NSMenuItem *i in [rootMenu itemArray]){
            [i setEnabled:NO];
        }
		
		DDLogInfo(@"Showing %@", addCustomFieldController);
		[addCustomFieldController showWindow:self];
        
	}else{
        
        TextCFWindowController *addCustomFieldController  = [[TextCFWindowController alloc] initWithController:self andCustomFieldTemplate:cf forBlog:blog];
        
        NSWindow *textWindow=[addCustomFieldController window];
        
        [NSApp beginSheet:textWindow modalForWindow:[cfTable window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
        
        NSMenu* rootMenu = [NSApp mainMenu];
        
        for(NSMenuItem *i in [rootMenu itemArray]){
            [i setEnabled:NO];
        }
		
		DDLogInfo(@"Showing %@", addCustomFieldController);
		[addCustomFieldController showWindow:self];
        
    }
	
}

-(CustomFieldTemplate*) findCustomFieldTemplateWithKey:(NSString*) n{
	DDLogInfo(@"Entra.");
	for (CustomFieldTemplate* c in customFieldsTemplates) {
        DDLogInfo(@"Finding: %@ vs %@", n, c.key);
		if ([c.key isEqualToString:n]) {
			return c;
		}
	}
    DDLogInfo(@"No encontrado.");
	return nil;
	
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
	if ([NSStringFromSelector(commandSelector)
		   isEqualToString:@"insertNewline:"]) {
		//[self goToURL:self];
		DDLogInfo(@"New Line");
		NSArray *temp = [[self->categoryField stringValue] componentsSeparatedByString:@","];
		
		for (NSString* c in temp) {
			DDLogInfo(@"cat: %@", c);
			
			if([c isEqualToString:@""]){
				return NO;
			}
			
			for(Category *c1 in categories){
				
				if([c1.categoryName caseInsensitiveCompare:c] == NSOrderedSame){
					DDLogInfo(@"Ya existe");
					return NO;
				}
				
			}
			
			Category* cat= [[[Category alloc] initWithEntity:[NSEntityDescription entityForName:@"Category"
																		 inManagedObjectContext:[self.blog managedObjectContext]]
							  insertIntoManagedObjectContext:[self.blog managedObjectContext]] autorelease];
			DDLogInfo(@"Se añaden los atributos... %@", c);		
			cat.categoryName=c;
			cat.categoryId=0;
			cat.blog=self.blog;
			DDLogInfo(@"Se añade el objeto");
			[categories addObject:cat];
			[blog saveData];
			[categoryState addObject:[NSNumber numberWithBool:YES]];
			DDLogInfo(@"Se recarga la tabla");
			[categoriesTable reloadData];
			[cat release];
			[self->categoryField setStringValue:@""];
		}
		return YES;
		}
	return NO;
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent{
	
	NSString * tString;
    unsigned int stringLength;
    /*unsigned int i;
	 unichar tChar;
	 id obj = [self delegate];*/
    
    tString= [theEvent characters];
    
    stringLength=(int)[tString length];
    
    DDLogInfo(@"Keydown!!");
	
	return YES;
	
}


-(IBAction)publishPost:(id)sender{
	
    [NSApp beginSheet:loadingSheet modalForWindow:[[self cfTable] window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
    
    NSMenu* rootMenu = [NSApp mainMenu];
    
    for(NSMenuItem *i in [rootMenu itemArray]){
        [i setEnabled:NO];
    }
    
    [publishProgress startAnimation:sender];
    
	[self save];
	
	//El password se guarda en el llavero. Si el código no está firmado, saldrá un "pop up" preguntando al usuario si desea modificar el llavero".
	NSString *pass = [[EMGenericKeychainItem genericKeychainItemForService:@"com.kyr.post-off" withUsername:blog.userName ] password];
	
	DDLogInfo(@"user: %@ pass: %@", blog.userName, pass);
	WordpressApi *api = [[WordpressApi alloc] initWithUser:blog.userName andPassword:pass andUrl:blog.xmlrpc andBlogId:[blog.blogId stringValue]];
	
	//Se comprueba que el post no exista ya. Si existe se actualiza, si no existe se crea.
	
	//Si el post ya existe se debe actualizar...
	DDLogInfo(@"postId es %@", [post.postId class]);
	if(post.postId==nil)
		DDLogInfo(@"postId es nil");
	
	if([post.postId intValue]==0)
		DDLogInfo(@"postId es 0");
	
	if(post.postId!=nil && [post.postId intValue]!=0){
		DDLogInfo(@"El post tiene id %@ así que se edita el existente...", [post.postId stringValue]);
		id response = [api getPostWithId:[post.postId stringValue]];
		
		if (response !=nil && ![response isKindOfClass:[NSError class]]) {
			
			DDLogInfo(@"Response es %@", [response class]);
			
			for(Category* c in post.categories){
				
				if(c.categoryId==nil){				
					id catId = [api addNewCategory:c];				
					if([catId isKindOfClass:[NSNumber class]]){					
						c.categoryId=catId;
						[blog saveData];					
					}
				}
				
			}
			
			
			//Updating custom field id to replace it in server.
			if ([response objectForKey:@"custom_fields"]) {
				DDLogInfo(@"Response tiene custom fields");
				NSArray *customFields = [response objectForKey:@"custom_fields"];

				DDLogInfo(@"Se comprueban los id de los custom fields del servidor y la key");
				for (NSDictionary *customField in customFields) {
					NSString *cId = [customField objectForKey:@"id"];
					NSString *key = [customField objectForKey:@"key"];
					
					DDLogInfo(@"CF: %@, %@", cId, key);
					
					for (CustomField *c in post.cFields) {
						if([c.key isEqualToString:key]){
							c.cfId=[NSNumber numberWithInt:[cId intValue]];
						}
					}
				}
			}
			
			
			//Hay que actualizar la versión del servidor: metaWeblog.editPost.
			id edited = [api editPostWithId:[post.postId stringValue] andPost:post];
			
			DDLogInfo(@"Edited es %@", [edited class]);
            
            
            [publishProgress stopAnimation:sender];
            [loadingSheet orderOut:sender];
            [NSApp endSheet:loadingSheet];
            
            [publishMessage setStringValue:NSLocalizedString(@"DONE_EDITED",@"Done! Your post was edited correctly.")];
            [NSApp beginSheet:doneSheet modalForWindow:[[self cfTable] window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
            
            NSMenu* rootMenu = [NSApp mainMenu];
            
            for(NSMenuItem *i in [rootMenu itemArray]){
                [i setEnabled:NO];
            }
			
		}else{
			
			DDLogInfo(@"Error encontrado...");
			
			if(response!=nil){
				
				
				[NSApp presentError:response];
				
				[publishProgress stopAnimation:sender];
				[loadingSheet orderOut:sender];
				[NSApp endSheet:loadingSheet];
				
                NSMenu* rootMenu = [NSApp mainMenu];
                
                for(NSMenuItem *i in [rootMenu itemArray]){
                    [i setEnabled:YES];
                }
                
			}else{
				
				NSString* value= @"404";
				NSString* errorMessage=NSLocalizedString(@"UNABLE_CONNECT_HOST", @"Unable to connect to host.");
				
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				[errorDetail setValue:errorMessage forKey:NSLocalizedDescriptionKey];
				NSError *error = [NSError errorWithDomain:@"com.kyr.post-off" code:(int)value userInfo:errorDetail];
				
				[NSApp presentError:error];
                
                [publishProgress stopAnimation:sender];
                [loadingSheet orderOut:sender];
                [NSApp endSheet:loadingSheet];
                
                NSMenu* rootMenu = [NSApp mainMenu];
                
                for(NSMenuItem *i in [rootMenu itemArray]){
                    [i setEnabled:YES];
                }
			}
			
			
		}
		
		
		
	}else{
		//Si el post no existe (no tiene id) se debe crear uno nuevo.
		
		for(Category* c in post.categories){
			
			if(c.categoryId==nil){				
				id catId = [api addNewCategory:c];				
				if([catId isKindOfClass:[NSNumber class]]){					
					c.categoryId=catId;
					[blog saveData];					
				}
			}
			
		}
		
		id response = [api addNewPost:self.post];
		
		if (response !=nil && ![response isKindOfClass:[NSError class]]) {
			
			DDLogInfo(@"Response es %@", [response class]);
			if([response isKindOfClass:[NSString class]]){
				//Una vez creado, hay que obtener los datos del post publicado para actualizar la versión local.
				//La próxima vez que se pulse en publicar, buscará el id del post en el servidor y lo actualizará, no creará uno nuevo.
				NSString *postId= response;
				id postInfo = [api getPostWithId:postId];
				
				[post updateFromDictionary:postInfo];
				[post save];
				
                [publishProgress stopAnimation:sender];
                [loadingSheet orderOut:sender];
                [NSApp endSheet:loadingSheet];
                
                [NSApp beginSheet:doneSheet modalForWindow:[[self cfTable] window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
                
                NSMenu* rootMenu = [NSApp mainMenu];
                
                for(NSMenuItem *i in [rootMenu itemArray]){
                    [i setEnabled:NO];
                }
			}
				
		}else{
			
			DDLogInfo(@"Error encontrado...");
			
			if(response!=nil){
				
				
				[NSApp presentError:response];
				
				[publishProgress stopAnimation:sender];
				[loadingSheet orderOut:sender];
				[NSApp endSheet:loadingSheet];
				
				NSMenu* rootMenu = [NSApp mainMenu];
                
                for(NSMenuItem *i in [rootMenu itemArray]){
                    [i setEnabled:YES];
                }
				
			}else{
				
				NSString* value= @"404";
				NSString* errorMessage=NSLocalizedString(@"UNABLE_CONNECT_HOST", @"Unable to connect to host.");
				
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				[errorDetail setValue:errorMessage forKey:NSLocalizedDescriptionKey];
				NSError *error = [NSError errorWithDomain:@"com.kyr.post-off" code:(int)value userInfo:errorDetail];
				
				[NSApp presentError:error];
                
                [publishProgress stopAnimation:sender];
                [loadingSheet orderOut:sender];
                [NSApp endSheet:loadingSheet];
                
                NSMenu* rootMenu = [NSApp mainMenu];
                
                for(NSMenuItem *i in [rootMenu itemArray]){
                    [i setEnabled:YES];
                }
			}
			
			
		}
		
	}
	
}

-(IBAction)backToEditor:(id)sender{
	
    [doneSheet orderOut:sender];
	[NSApp endSheet:doneSheet];	
	NSMenu* rootMenu = [NSApp mainMenu];
    
    for(NSMenuItem *i in [rootMenu itemArray]){
        [i setEnabled:YES];
    }
}

- (IBAction)insertBoldTag:(id)sender{

    int length = (int)[contentField selectedRange].length;
    
    if(length>0){

        NSString *s = [[contentField string] substringWithRange:[contentField selectedRange]];
        
        [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:[NSString stringWithFormat: @"<strong>%@</strong>",s]];
        
    }else{
    
        switch (boldStatus) {
            case YES:
                [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:@"</strong>"];

                boldStatus=NO;
                [boldButton setTitle:@"B"];
            
                break;
            
            default:
                [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                       withString:@"<strong>"];

                boldStatus=YES;
                [boldButton setTitle:@"/B"];
                break;
        }
    }
}

- (IBAction)insertItalicTag:(id)sender{

    int length = (int)[contentField selectedRange].length;
    
    if(length>0){

        NSString *s = [[contentField string] substringWithRange:[contentField selectedRange]];
        
        [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:[NSString stringWithFormat: @"<em>%@</em>",s]];
        
    }else{
        
        switch (italicStatus) {
            case YES:
                [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:@"</em>"];

                italicStatus=NO;
                [italicButton setTitle:@"I"];
                
                break;
                
            default:
                [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                       withString:@"<em>"];

                italicStatus=YES;
                [italicButton setTitle:@"/I"];
                break;
        }
    }
}

- (IBAction)insertQuoteTag:(id)sender{
    
    int length = (int)[contentField selectedRange].length;
    
    if(length>0){
        
        NSString *s = [[contentField string] substringWithRange:[contentField selectedRange]];
        
        [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:[NSString stringWithFormat: @"<blockquote>%@</blockquote>",s]];
        
    }else{
        
        switch (quoteStatus) {
            case YES:
                [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:@"</blockquote>"];
                
                quoteStatus=NO;
                [quoteButton setTitle:NSLocalizedString(@"QUOTE", @"quote")];
                
                break;
                
            default:
                [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                       withString:@"<blockquote>"];
                
                quoteStatus=YES;
                [quoteButton setTitle:NSLocalizedString(@"CLOSE_QUOTE", @"/quote")];
                break;
        }
    }
}

- (IBAction)insertDelTag:(id)sender{
    
    int length = (int)[contentField selectedRange].length;
    
    if(length>0){
        
        NSString *s = [[contentField string] substringWithRange:[contentField selectedRange]];
        
        [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:[NSString stringWithFormat: @"<del>%@</del>",s]];
        
    }else{
        
        switch (delStatus) {
            case YES:
                [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:@"</del>"];
                
                delStatus=NO;
                [delButton setTitle:@"del"];
                
                break;
                
            default:
                [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                       withString:@"<del>"];
                
                delStatus=YES;
                [delButton setTitle:@"/del"];
                break;
        }
    }
}

- (IBAction)insertCodeTag:(id)sender{
    
    int length = (int)[contentField selectedRange].length;
    
    if(length>0){
        
        NSString *s = [[contentField string] substringWithRange:[contentField selectedRange]];
        
        [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:[NSString stringWithFormat: @"<code>%@</code>",s]];
        
    }else{
        
        switch (codeStatus) {
            case YES:
                [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:@"</code>"];
                
                codeStatus=NO;
                [codeButton setTitle:NSLocalizedString(@"CLOSE_CODE", @"code")];
                
                break;
                
            default:
                [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                       withString:@"<code>"];
                
                codeStatus=YES;
                [codeButton setTitle:NSLocalizedString(@"CLOSE_CODE", @"/código")];
                break;
        }
    }
}

- (IBAction)insertUlTag:(id)sender{
    
    int length = (int)[contentField selectedRange].length;
    
    if(length>0){
        
        NSString *s = [[contentField string] substringWithRange:[contentField selectedRange]];
        
        [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:[NSString stringWithFormat: @"<ul>%@</ul>",s]];
        
    }else{
        
        switch (ulStatus) {
            case YES:
                [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:@"</ul>"];
                
                ulStatus=NO;
                [ulButton setTitle:@"ul"];
                
                break;
                
            default:
                [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                       withString:@"<ul>"];
                
                ulStatus=YES;
                [ulButton setTitle:@"/ul"];
                break;
        }
    }
}

- (IBAction)insertOlTag:(id)sender{
    
    int length = (int)[contentField selectedRange].length;
    
    if(length>0){
        
        NSString *s = [[contentField string] substringWithRange:[contentField selectedRange]];
        
        [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:[NSString stringWithFormat: @"<ol>%@</ol>",s]];
        
    }else{
        
        switch (olStatus) {
            case YES:
                [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:@"</ol>"];
                
                olStatus=NO;
                [olButton setTitle:@"ol"];
                
                break;
                
            default:
                [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                       withString:@"<ol>"];
                
                olStatus=YES;
                [olButton setTitle:@"/ol"];
                break;
        }
    }
}

- (IBAction)insertLiTag:(id)sender{
    
    int length = (int)[contentField selectedRange].length;
    
    if(length>0){
        
        NSString *s = [[contentField string] substringWithRange:[contentField selectedRange]];
        
        [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:[NSString stringWithFormat: @"<li>%@</li>",s]];
        
    }else{
        
        switch (liStatus) {
            case YES:
                [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:@"</li>"];
                
                liStatus=NO;
                [liButton setTitle:@"li"];
                
                break;
                
            default:
                [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                       withString:@"<li>"];
                
                liStatus=YES;
                [liButton setTitle:@"/li"];
                break;
        }
    }
}

- (IBAction)insertMoreTag:(id)sender{
    
    int length = (int)[contentField selectedRange].length;
    
    if(length>0){
        
        NSString *s = [[contentField string] substringWithRange:[contentField selectedRange]];
        
        [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:[NSString stringWithFormat: @"%@<!--more-->",s]];
        
    }else{
        
        [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:@"<!--more-->"];
    }
}

- (IBAction)closeWindow:(id)sender{
	[[sender window] orderOut:self];
	[NSApp endSheet:[sender window]];
    NSMenu* rootMenu = [NSApp mainMenu];
    
    for(NSMenuItem *i in [rootMenu itemArray]){
        [i setEnabled:YES];
    }
}

- (IBAction)showLinkWindow:(id)sender{
	
	int length = (int)[contentField selectedRange].length;
    
    if(length>0){
        
        NSString *s = [[contentField string] substringWithRange:[contentField selectedRange]];
        
		[linkTitle setStringValue:s];
        
    }else{
        
		[linkTitle setStringValue:@""];
    }    
    
    [linkUrl setStringValue:@""];
	
    [NSApp beginSheet:addLinkSheet modalForWindow:[cfTable window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
    
    NSMenu* rootMenu = [NSApp mainMenu];
    
    for(NSMenuItem *i in [rootMenu itemArray]){
        [i setEnabled:NO];
    }
}

- (IBAction)insertLinkTag:(id)sender{
    
    int length = (int)[contentField selectedRange].length;
    
    if(length>0){
        DDLogInfo(@"Rango >0");
        //NSString *s = [[contentField string] substringWithRange:[contentField selectedRange]];
        
        [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:[NSString stringWithFormat: @"<a href=\"%@\" title=\"%@\">%@</a>",[linkUrl stringValue],[linkTitle stringValue],[linkTitle stringValue]]];
        
    }else{
        DDLogInfo(@"Rango <0");
        [[contentField textStorage] replaceCharactersInRange:[contentField selectedRange]                                      withString:[NSString stringWithFormat: @"<a href=\"%@\" title=\"%@\">%@</a>", [linkUrl stringValue],[linkTitle stringValue],[linkTitle stringValue]]];
    }
    
    /*[linkUrl setStringValue:@""];
    [linkTitle setStringValue:@""];*/
    [addLinkSheet orderOut:self];
	[NSApp endSheet:addLinkSheet];
    
    NSMenu* rootMenu = [NSApp mainMenu];
    
    for(NSMenuItem *i in [rootMenu itemArray]){
        [i setEnabled:YES];
    }
}
@end
