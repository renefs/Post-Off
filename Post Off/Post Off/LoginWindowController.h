//
//  LoginWindowController.h
//  Post Off
//
//  Created by René on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindowController.h"
#import "WordpressApi.h"
#import "Blog.h"

@class KYRAppDelegate;

@interface LoginWindowController : NSWindowController{
	
	WordpressApi *api;

	
	IBOutlet NSTextField *userField;
	IBOutlet NSTextField *passwordField;
	IBOutlet NSTextField *urlField;
	IBOutlet NSButton	*registerButton;
	
	IBOutlet NSProgressIndicator *loadingIndicator;
	
	IBOutlet NSWindow *loadingSheet;
	IBOutlet NSWindow *doneSheet;
	
	IBOutlet NSWindow *errorSheet;
	IBOutlet NSTextField *errorLabel;
    IBOutlet NSTextField *loadingLabel;
	
	MainWindowController *mainController;
	
	
	IBOutlet NSTextField *numberOfPostsToSync;
	NSString *lastValidNumberOfPostsToSync;
	
	BOOL errorFound;
	
	//NSManagedObjectContext *context;
	//NSPersistentStoreCoordinator *storeCoordinator;
	//NSManagedObjectModel *model;
}
@property (nonatomic, retain) Blog *blog;
//-(id) initWithManagedObjectContext:(NSManagedObjectContext*) m andManagedObjectModel:(NSManagedObjectModel*) mo andPersistentCoordinator:(NSPersistentStoreCoordinator*) p;

@end
