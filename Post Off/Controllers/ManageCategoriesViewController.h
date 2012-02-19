//
//  MyClass.h
//  Post Off
//
//  Created by Rene Fernandez on 04/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//#import "ManagingViewController.h"
#import "Blog.h"
#import "CustomTable.h"
#import "CategoryContainer.h"

@interface ManageCategoriesViewController : NSViewController<NSTableViewDelegate, NSTableViewDataSource, NSAlertDelegate>{
    
    IBOutlet CustomTable *categoryTable;
	
	IBOutlet NSButton *deleteButton;
	
	IBOutlet NSTableColumn *checkColumn;
	IBOutlet NSTableColumn *idColumn;
	IBOutlet NSTableColumn *nameColumn;
	IBOutlet NSTableColumn *parentColumn;
	
	IBOutlet NSWindow *loadingSheet;
	IBOutlet NSProgressIndicator *loadingIndicator;
    IBOutlet NSTextField *loadingLabel;
	
	IBOutlet NSWindow *addNewSheet;
	IBOutlet NSTextField *newCatName;
	
	
}

@property (nonatomic, retain) NSMutableArray *categories;
@property (nonatomic, retain) Blog *blog;
//@property (nonatomic, retain) NSMutableArray *categoryState;

- (id) initWithBlog:(Blog*) b;

- (void) fetchCategories;
- (BOOL) deleteSelectedItems;
-(void)handleResult:(NSAlert *)alert withResult:(NSInteger)result;
-(int) numberOfSelectedItems;

-(IBAction)addNewCategory:(id)sender;
-(IBAction)sync:(id)sender;
- (void) syncItems;

@end
