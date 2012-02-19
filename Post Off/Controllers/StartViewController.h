//
//  StartViewController.h
//  Post Off
//
//  Created by René on 22/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "ManagingViewController.h"
#import "Blog.h"
#import "Post.h"
#import "Category.h"
#import "CustomTable.h"
#import "WordpressApi.h"

@class MainWindowController;

@interface StartViewController : NSViewController<NSTableViewDelegate, NSTableViewDataSource,NSAlertDelegate>{
	
	IBOutlet NSTextField *user;
	IBOutlet NSTextField *url;
    
    IBOutlet NSTextField *numCats;
    IBOutlet NSTextField *numPosts;
    IBOutlet NSTextField *numTrash;
    IBOutlet NSTextField *numCFields;
    IBOutlet NSTextField *blogTitle;
    
    IBOutlet CustomTable *postsTable;
    
    IBOutlet NSTableColumn *titleColumn;
    IBOutlet NSTableColumn *dateColumn;
	
	IBOutlet NSWindow *loadingSheet;
	IBOutlet NSProgressIndicator *loadingIndicator;
    IBOutlet NSTextField *loadingLabel;
	
}

@property (nonatomic, retain) Blog *blog;
@property (nonatomic, retain) Post *post;
@property (nonatomic, retain) MainWindowController *windowController;
@property (nonatomic, retain) NSMutableArray *posts;

- (id) initWithBlog:(Blog*) b andWindowController:(MainWindowController*) m;
- (void) editPost;

- (void) syncLocalCurrentPost;
- (void) syncServerCurrentPost;
- (BOOL) syncSelectedItem;
-(void)handleSyncResult:(NSAlert *)alert withResult:(NSInteger)result;
- (void)syncAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

@end
