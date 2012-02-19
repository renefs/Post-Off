//
//  NewArticleViewController.h
//  Post Off
//
//  Created by René on 22/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ManagingViewController.h"
#import "TextCFWindowController.h"
#import "DropdownCFWindowController.h"
#import "Blog.h"
#import "Category.h"
#import "Post.h"
#import "CustomFieldTemplate.h"
#import "CustomFieldTableDelegate.h"
#import "CustomTable.h"
#import "WordpressApi.h"
#import "MainWindowController.h"
#import "AddCatTextField.h"

@interface NewArticleViewController : ManagingViewController<NSTableViewDelegate, NSTableViewDataSource>{
	
	IBOutlet NSTextView *contentField;
	IBOutlet NSTextField *titleField;
	IBOutlet NSTextField *tagsField;
	IBOutlet NSWindow *doneSheet;
    IBOutlet NSWindow *loadingSheet;
    IBOutlet NSProgressIndicator *publishProgress;
    IBOutlet NSTextField *publishMessage;
    
	NSMutableArray *categories;	
	//Tabla con las categorías del blog y con los BOOL que indica cuales están seleccionadas.
	IBOutlet NSTableView *categoriesTable;
	NSMutableArray *categoryState;
	IBOutlet NSTextField *categoryField;
	
	IBOutlet CustomTable *cfTable;
	IBOutlet CustomFieldTableDelegate *cfDelegate;
    IBOutlet NSPopUpButton *cfSelector;
    IBOutlet NSPopUpButton *statusSelector;
    IBOutlet NSButton *addCfButton;
    
    NSMutableArray *customFieldsTemplates;
	NSMutableArray *postCustomFields;
    
    IBOutlet NSWindow *addLinkSheet;
    
    BOOL boldStatus;
    IBOutlet NSButton *boldButton;
    
    BOOL italicStatus;
    IBOutlet NSButton *italicButton;
    
    BOOL quoteStatus;
    IBOutlet NSButton *quoteButton;
    
    BOOL delStatus;
    IBOutlet NSButton *delButton;
    
    IBOutlet NSButton *linkButton;
    IBOutlet NSButton *insertLinkButton;
    
    BOOL codeStatus;
    IBOutlet NSButton *codeButton;
    
    BOOL ulStatus;
    IBOutlet NSButton *ulButton;
    
    BOOL olStatus;
    IBOutlet NSButton *olButton;
    
    BOOL liStatus;
    IBOutlet NSButton *liButton;
    
    IBOutlet NSButton *moreButton;
    
    IBOutlet NSTextField *linkTitle;
    IBOutlet NSTextField *linkUrl;
	
}

@property (nonatomic, retain) Blog *blog;
@property (nonatomic, retain) Post *post;
@property (nonatomic, retain) CustomTable *cfTable;
@property (nonatomic, retain) CustomFieldTableDelegate *cfDelegate;
@property (nonatomic, retain) NSPopUpButton *cfSelector;
@property (nonatomic, retain) NSTextView *contentField;
@property (nonatomic, retain) MainWindowController *mainWindowController;

- (id) initWithBlog:(Blog*) b andPost:(Post*) p andWindowController:(MainWindowController*) mc;
- (id) initWithBlog:(Blog*) b andWindowController:(MainWindowController*) mc;

- (void) fetchCategories;
- (void) fetchCustomFieldsTemplates;
//- (void) loadCurrentBlog;

- (IBAction)pullsDownAction:(id)sender;

- (IBAction)checkboxChanged:(NSTableView*)sender;

-(void)save;
- (IBAction)saveCurrentPost:(id)sender;

- (IBAction)addCustomField:(id)sender;

-(CustomFieldTemplate*) findCustomFieldTemplateWithKey:(NSString*) n;
-(IBAction)publishPost:(id)sender;
-(IBAction)backToEditor:(id)sender;

- (IBAction)insertBoldTag:(id)sender;
- (IBAction)insertItalicTag:(id)sender;
- (IBAction)insertQuoteTag:(id)sender;
- (IBAction)insertDelTag:(id)sender;
- (IBAction)insertCodeTag:(id)sender;
- (IBAction)insertUlTag:(id)sender;
- (IBAction)insertOlTag:(id)sender;
- (IBAction)insertLiTag:(id)sender;
- (IBAction)showLinkWindow:(id)sender;
- (IBAction)insertMoreTag:(id)sender;
@end
