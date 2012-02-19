//
//  ManageCustomFieldsViewController.h
//  Post Off
//
//  Created by René on 15/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

//#import "ManagingViewController.h"
#import "CustomTable.h"
#import "CustomFieldTemplate.h"
#import "Blog.h"
#import "CustomFieldTemplateContainer.h"

@interface ManageCustomFieldsViewController : NSViewController<NSTableViewDelegate, NSTableViewDataSource, NSAlertDelegate>{
	
	IBOutlet CustomTable *cfTable;
	
	IBOutlet NSTableColumn *checkColumn;
	IBOutlet NSTableColumn *keyColumn;
	IBOutlet NSTableColumn *nameColumn;
	IBOutlet NSTableColumn *optionsColumn;
	IBOutlet NSTableColumn *typeColumn;
	
	
	IBOutlet NSTextField *name;
	IBOutlet NSTextField *key;
	IBOutlet NSTextField *options;
	IBOutlet NSPopUpButton *type;
	
	IBOutlet NSButton *deleteButton;
	IBOutlet NSButton *saveButton;
	IBOutlet NSWindow *addFieldSheet;
	
}

@property (nonatomic, retain) Blog *blog;
@property (nonatomic, retain) NSMutableArray *customFields;
@property (nonatomic, retain) CustomTable *cfTable;

- (id) initWithBlog:(Blog*) b;

- (IBAction)saveCurrentCFTemplate:(id)sender;
-(void) fetchCustomFields;

- (IBAction)applyAction:(id)sender;
- (BOOL) deleteSelectedItems;
-(void)handleResult:(NSAlert *)alert withResult:(NSInteger)result;
-(int) numberOfSelectedItems;
- (void) editCustomFieldTemplate;
- (void)editSelectedCFTemplate:(CustomFieldTemplate* ) field;
@end
