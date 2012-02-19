//
//  ManagePostsViewController.h
//  Post Off
//
//  Created by René on 22/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>
//#import "ManagingViewController.h"
#import "Blog.h"
#import "Post.h"
#import "WordpressApi.h"
#import "CustomTable.h"
#import "PostContainer.h"

@class MainWindowController;

@interface ManagePostsViewController : NSViewController<NSTableViewDelegate, NSTableViewDataSource, NSAlertDelegate>{
    
    IBOutlet CustomTable *postsTable;
	
	IBOutlet NSTableColumn *checkColumn;
	IBOutlet NSTableColumn *statusColumn;
	IBOutlet NSTableColumn *formatColumn;
	IBOutlet NSTableColumn *authorColumn;
	IBOutlet NSTableColumn *titleColumn;
	IBOutlet NSTableColumn *dateColumn;
	
	IBOutlet NSButton *deleteButton;
	
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
- (void) fetchPosts;

-(int) numberOfSelectedItems;

- (IBAction)checkboxChanged:(NSTableView*)sender;
- (IBAction)applyAction:(id)sender;
- (BOOL) deleteSelectedItems;

- (void) syncLocalCurrentPost;
- (void) syncServerCurrentPost;
- (BOOL) syncSelectedItem;
-(void)handleSyncResult:(NSAlert *)alert withResult:(NSInteger)result;
- (void)syncAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
@end
