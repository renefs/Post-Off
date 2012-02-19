//
//  DropdownCFWindowController.m
//  Post Off
//
//  Created by René on 26/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DropdownCFWindowController.h"
#import "CustomFieldTableDelegate.h"
#import "NewArticleViewController.h"

@implementation DropdownCFWindowController

@synthesize cf,tableDelegate,customFields,blog,valueSelector,addButton,viewController;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id) initWithController:(NewArticleViewController *)vc andCustomFieldTemplate:(CustomFieldTemplate *)c forBlog:(Blog *)b{
	self = [super initWithWindowNibName:@"AddDropdownCF"];
	
	if(self){
		
		self.tableDelegate=vc.cfDelegate;
        self.viewController=vc;
		self.cf=c;
		self.customFields=tableDelegate.customFields;
		self.blog=b;
		
	}
	
	return self;
}

-(void) awakeFromNib{
	
	[self->keyLabel setStringValue:cf.key];
	[[self window] setTitle:cf.name];
	
	//NSArray *temp = [[self->c.op stringValue] componentsSeparatedByString:@","];
	NSArray *temp = [cf.options componentsSeparatedByString:@","];
	
	[self.valueSelector removeAllItems];
	for(NSString* s in temp){
		DDLogInfo(@"Opción: %@", s);
		[self.valueSelector addItemWithTitle:s];
		
	}
	
	
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)addCustomField:(id)sender {
	[self add];
}

-(void) add{
	
	DDLogInfo(@"Se crea el campo...");
    
	CustomField* c= [[[CustomField alloc] initWithEntity:[NSEntityDescription entityForName:@"CustomField"
																	 inManagedObjectContext:[self.blog managedObjectContext]]
						  insertIntoManagedObjectContext:[self.blog managedObjectContext]] autorelease];
	DDLogInfo(@"Se añaden los atributos...");
	c.key=cf.key;
	c.value=[self->valueSelector titleOfSelectedItem];
	
	
	for (CustomField *custom in customFields) {
		if([custom.key isEqualToString:c.key]){
			DDLogInfo(@"El campo ya existe...");
			[customFields removeObject:custom];
			[[tableDelegate cfTable]reloadData];
		}
	}
	
	
	
	DDLogInfo(@"Se añade el objeto a la tabla...");
	//[customFields addObject:c];
	if(!customFields)
		DDLogInfo(@"customFields es nil");
	if(!tableDelegate)
		DDLogInfo(@"table es nil");
	
	[customFields addObject:c];
	DDLogInfo(@"Se recarga la tabla...");
	[[tableDelegate cfTable]reloadData];
    
	if([viewController.cfSelector numberOfItems] > 1 && [viewController.cfSelector itemWithTitle:c.key])
		[viewController.cfSelector removeItemWithTitle:c.key];
    
	unsigned i=0;
	for(CustomField *cu in tableDelegate.customFields){
		DDLogInfo(@"Campo %d: %@ %@",i, cu.value, cu.key);
		i++;
	}
	[[self window] orderOut:self];
	[NSApp endSheet:[self window]];
    
    NSMenu* rootMenu = [NSApp mainMenu];
    
    for(NSMenuItem *i in [rootMenu itemArray]){
        [i setEnabled:YES];
    }
}


- (IBAction)cancel:(id)sender {
    [[sender window] orderOut:self];
	[NSApp endSheet:[sender window]];
    
    NSMenu* rootMenu = [NSApp mainMenu];
    
    for(NSMenuItem *i in [rootMenu itemArray]){
        [i setEnabled:YES];
    }
}

@end
