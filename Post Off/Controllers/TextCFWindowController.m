//
//  TextCFWindowController.m
//  Post Off
//
//  Created by René on 16/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TextCFWindowController.h"
#import "CustomFieldTableDelegate.h"
#import "NewArticleViewController.h"

@implementation TextCFWindowController

@synthesize cf,tableDelegate,customFields,blog,value,addButton,viewController;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id) initWithController:(NewArticleViewController *)vc andCustomFieldTemplate:(CustomFieldTemplate *)c forBlog:(Blog *)b{
	self = [super initWithWindowNibName:@"AddTextCF"];
	
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
	
	[self->keyLabel setStringValue:cf.name];
	[[self window] setTitle:cf.name];
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
    
	if(!blog)
		DDLogInfo(@"El blog es nil");
	CustomField* c= [[[CustomField alloc] initWithEntity:[NSEntityDescription entityForName:@"CustomField"
															  inManagedObjectContext:[self.blog managedObjectContext]]
				   insertIntoManagedObjectContext:[self.blog managedObjectContext]] autorelease];
	DDLogInfo(@"Se añaden los atributos...");
	c.key=cf.key;
	c.value=[self->value stringValue];

	
	
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
    
	if([viewController.cfSelector numberOfItems] > 1)
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
