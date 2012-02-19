//
//  Preferences.h
//  Post Off
//
//  Created by René on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindowController.h"
#import "LoginWindowController.h"
#import "Blog.h"
#import "WordpressApi.h"

@interface PreferencesWindowController : NSWindowController{
	
	WordpressApi *api;
	
	//General tab
	IBOutlet NSTextField *user;
	IBOutlet NSTextField *password;
	IBOutlet NSTextField *url;
	IBOutlet NSTextField *blogId;
	
    IBOutlet NSTabView *tabs;
    IBOutlet NSButton *removeBlogCheckBox;
	IBOutlet NSButton *resetBlogCheckBox;
	IBOutlet NSButton *resetBlogButton;
    IBOutlet NSButton *removeBlogButton;
	
	IBOutlet NSButton *syncOnStartCheckBox;
	
	IBOutlet NSWindow *loadingSheet;
	IBOutlet NSProgressIndicator *loadingIndicator;
    IBOutlet NSTextField *loadingLabel;
	
	IBOutlet NSTextField *numberOfPostsToSyncTF;
	NSString *lastValidNumberOfPostsToSync;
	
	IBOutlet NSButton *syncCatsCheckBox;
	IBOutlet NSButton *syncPostsCheckBox;
	IBOutlet NSButton *syncBlogButton;
	
	
}

@property (nonatomic, retain) Blog *blog;
@property (nonatomic, retain) NSTabView *tabs;
@property (nonatomic, retain) MainWindowController *mainWindowController;

- (id) initWithBlog:(Blog*) b andMainWindowController:(MainWindowController*) mv;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (void)saveData;

- (IBAction)checkboxChanged:(NSButton*)sender;
- (IBAction)removeBlogAcAction:(id)sender;
- (IBAction)resetBlogAcAction:(id)sender;
-(void) removeBlog;

- (IBAction)syncBlogAcAction:(id)sender;

@end
