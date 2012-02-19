//
//  KYRAppDelegate.h
//  Post Off
//
//  Created by René on 21/11/11.
//  Copyright (c) 2011 KYR Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindowController.h"
#import "Blog.h"
#import "WordpressApi.h"

@class LoginWindowController, ReLoginWindowController;

@interface KYRAppDelegate : NSObject <NSApplicationDelegate>{
	
	
	MainWindowController *mainController;
	//LoginWindowController *loginController;
    
    NSWindow *window;
    
    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSManagedObjectModel *__managedObjectModel;
    NSManagedObjectContext *__managedObjectContext;
	
	IBOutlet NSProgressIndicator *loadingIndicator;

	
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Blog *blog;

- (IBAction)saveAction:(id)sender;


- (NSString*)testString;
- (BOOL) blogsExistsInDatabase;
// Function Declaration (*.h file)
-(NSDateComponents *)getCurrentDateTime:(NSDate *)date;

@end
