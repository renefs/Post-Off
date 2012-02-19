//
//  MainWindowController.h
//  Post Off
//
//  Created by René on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>

//#import "ManagingViewController.h"
#import "StartViewController.h"
#import "NewArticleViewController.h"
#import "ManagePostsViewController.h"
#import "ManageCategoriesViewController.h"
#import "TrashViewController.h"
#import "ManageCustomFieldsViewController.h"
#import "Post.h"

@class StartViewController, PreferencesWindowController;

@interface MainWindowController : NSWindowController<NSOutlineViewDelegate, NSOutlineViewDataSource, NSMenuDelegate>{
	
    CATransition *transition;
    
    IBOutlet NSView *_mainContentView;
    NSArray *_topLevelItems;
    NSViewController *_currentContentViewController;
    NSMutableDictionary *_childrenDictionary;
    IBOutlet NSOutlineView *_sidebarOutlineView;	
	
    PreferencesWindowController *preferencesController;
	IBOutlet NSWindow *aboutWindow;
}

@property (nonatomic, retain) Blog *blog;
@property (nonatomic, retain) NSView *_mainContentView;

- (id) initWithBlog:(Blog*) b;

- (IBAction)sidebarMenuDidChange:(id)sender;
- (void)setContentViewNewArticleViewWithPost:(Post*) p;

- (void)setContentViewStartView;
- (void)setContentViewNewArticleView;
- (void)setContentViewTrashView;
- (void)setContentViewManageCategoriesView;
- (void)setContentViewManagePostsView;
- (void)setContentViewManageCustomFieldsView;
@end
