//
//  ReLoginWindowController.h
//  Post Off
//
//  Created by René on 14/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainWindowController.h"
#import "Blog.h"
#import "WordpressApi.h"

@interface ReLoginWindowController : NSWindowController{
	
	IBOutlet NSTextField *userNameField;
	IBOutlet NSTextField *passwordField;
	IBOutlet NSTextField *urlField;

	
	IBOutlet NSWindow *loadingSheet;
	IBOutlet NSProgressIndicator *loadingIndicator;
    IBOutlet NSTextField *loadingLabel;
	
	MainWindowController *mainController;
	
	WordpressApi *api;
}

@property (nonatomic, retain) Blog *blog;

-(id) initWithBlog:(Blog*) b;

- (IBAction)cancelLogin:(id)sender;
- (IBAction)login:(id)sender;

@end
