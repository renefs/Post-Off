//
//  TrashViewController.h
//  Post Off
//
//  Created by René on 14/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

//#import "ManagingViewController.h"
#import "CustomTable.h"
#import "Blog.h"
#import "Post.h"
#import "PostContainer.h"

@interface TrashViewController : NSViewController<NSTableViewDelegate, NSTableViewDataSource>{
    
    IBOutlet CustomTable *postsTable;
	
	IBOutlet NSTableColumn *checkColumn;
	IBOutlet NSTableColumn *statusColumn;
	IBOutlet NSTableColumn *formatColumn;
	IBOutlet NSTableColumn *authorColumn;
	IBOutlet NSTableColumn *titleColumn;
	IBOutlet NSTableColumn *dateColumn;
	
	IBOutlet NSButton *recoverButton;
    IBOutlet NSButton *deleteButton;
    
}

@property (nonatomic, retain) NSMutableArray *posts;
@property (nonatomic, retain) Blog *blog;


- (id) initWithBlog:(Blog*) b;

- (IBAction)checkboxChanged:(NSTableView*)sender;

- (IBAction)recoverAction:(id)sender;
- (BOOL) recoverSelectedItems;
- (void) fetchPosts;
- (void)handleRecoverResult:(NSAlert *)alert withResult:(NSInteger)result;

- (int) numberOfSelectedItems;

- (BOOL) deleteSelectedItems;
- (IBAction)deleteAction:(id)sender;
- (void)handleDeleteResult:(NSAlert *)alert withResult:(NSInteger)result;
@end
