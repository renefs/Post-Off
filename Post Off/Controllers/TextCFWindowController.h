//
//  TextCFWindowController.h
//  Post Off
//
//  Created by René on 16/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CustomFieldTemplate.h"
#import "Blog.h"
#import "CustomField.h"

@class CustomFieldTableDelegate, NewArticleViewController;

@interface TextCFWindowController : NSWindowController{
	
	IBOutlet NSTextField *value;
	IBOutlet NSButton *cancelButton;
	IBOutlet NSButton *addButton;
	IBOutlet NSTextField *keyLabel;
	
	
	
}

@property (nonatomic, retain) IBOutlet NSTextField *value;
@property (nonatomic, retain) IBOutlet NSButton *addButton;

@property (nonatomic, retain) CustomFieldTemplate *cf;
@property (nonatomic, retain) NewArticleViewController *viewController;
@property (nonatomic, retain) CustomFieldTableDelegate *tableDelegate;
@property (nonatomic, retain) NSMutableArray *customFields;
@property (nonatomic, retain) Blog *blog;

- (id) initWithController:(NewArticleViewController*) vc andCustomFieldTemplate:(CustomFieldTemplate*) c forBlog:(Blog*) b;

- (IBAction)addCustomField:(id)sender;
- (IBAction)cancel:(id)sender;

-(void) add;

@end
