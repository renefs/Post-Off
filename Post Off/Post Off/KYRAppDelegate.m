//
//  KYRAppDelegate.m
//  Post Off
//
//  Created by René on 21/11/11.
//  Copyright (c) 2011 KYR Apps. All rights reserved.
//

#import "KYRAppDelegate.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "LoginWindowController.h"
#import "ReLoginWindowController.h"


@implementation KYRAppDelegate

@synthesize window = _window;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize blog;


- (NSString*)testString{
	
	return @"KYRAppDelegate Test String -> OK";
	
}


- (void)dealloc
{
	[__persistentStoreCoordinator release];
	[__managedObjectModel release];
	[__managedObjectContext release];

    [super dealloc];
}

- (BOOL) blogsExistsInDatabase{
	
	// Test listing all FailedBankInfos from the store
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Blog" 
											  inManagedObjectContext:[self managedObjectContext]];
	NSError *error;
	[fetchRequest setEntity:entity ];
	NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	if([fetchedObjects count] >0){
		return YES;		
	}	
	[fetchRequest release];
	return NO;
}

// Implementation
-(NSDateComponents *)getCurrentDateTime:(NSDate *)date
{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components: NSDayCalendarUnit + NSMonthCalendarUnit + NSYearCalendarUnit fromDate:now];
    return comps;
	
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	[DDLog addLogger:[DDASLLogger sharedInstance]];
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	DDLogInfo(@"applicationDidFinishLaunching...");
	
	/*NSDateComponents *today = [self getCurrentDateTime:[NSDate date]];
	int day = (int)[today day];
	int month = (int)[today month];
	int year = (int)[today year];
	
	DDLogInfo(@"%d,%d,%d", day,month,year);
	
	if (month > 1 || year >2012) {
		
		NSString* value= @"Error";
		NSString* errorMessage=@"Beta period expired. Thank you for testing";
		
		NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:errorMessage forKey:NSLocalizedDescriptionKey];
		NSError *error = [NSError errorWithDomain:@"com.kyr.post-off" code:(int)value userInfo:errorDetail];
		
		[NSApp presentError:error];
		
		[NSApp terminate:self];
		return;
	}*/
	
	
	//BOOL blogExistsInDatabase = [self blogsExistsInDatabase];
	int value=[[UserDefaultsHelper getUserValueForKey:kyrIsFirstLaunch withDefault:@"-1"] intValue];
	
	int syncCategoriesOnStart=[[UserDefaultsHelper getUserValueForKey:kyrSyncCategoriesOnStart withDefault:@"-1"] intValue];
	if(syncCategoriesOnStart == -1){
        [UserDefaultsHelper setUserStringValue:@"1" forKey:kyrSyncCategoriesOnStart];
    }
	DDLogInfo(@"Primero kyrFirstLaunch: %d", value);
    if(value == -1){
        [UserDefaultsHelper setUserStringValue:@"1" forKey:kyrIsFirstLaunch];
        value=1;
    }
	
	//value=[UserDefaultsHelper getUserValueForKey:kyrMustRegisterBlog withDefault:nil];
	//BOOL mustRegisterBlog=[value boolValue];	
	
	DDLogInfo(@"Antes kyrFirstLaunch ...%d",value);
	
	if(value==1){
		DDLogInfo(@"Is first launch...");
        //[UserDefaultsHelper setUserStringValue:@"0" forKey:kyrBlogAutoId];
        
		//value=[UserDefaultsHelper getUserValueForKey:kyrIsFirstLaunch withDefault:@"BAD"];
		//value=[value boolValue];
		
        /*NSMenu* rootMenu = [NSApp mainMenu];

        for(NSMenuItem *i in [rootMenu itemArray]){
            [i setEnabled:NO];
        }*/
        
		//if (!loginController) {
		LoginWindowController *loginController = [[LoginWindowController alloc] init];
		//}
		[_window close];
		DDLogInfo(@"Showing %@", loginController);
		[loginController showWindow:self];
		
		
	}else{
		DDLogInfo(@"Isn't first launch...");

		NSError *error;
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Blog" inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
		[fetchRequest setEntity:entity ];
		NSArray *fetchedObjects = [[[NSApp delegate] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
		blog = [fetchedObjects objectAtIndex:0];
        
        if(blog==nil){
            DDLogInfo(@"Blog not found");
			[UserDefaultsHelper setUserStringValue:@"1" forKey:kyrIsFirstLaunch];
			
			LoginWindowController *loginController = [[LoginWindowController alloc] init];
			
			[_window close];
			DDLogInfo(@"Showing %@", loginController);
			[loginController showWindow:self];
			
        }else{
			
			if(syncCategoriesOnStart == 1){
			
				DDLogInfo(@"Sincronizando categorías...");
				[loadingIndicator startAnimation:window];
				WordpressApi *api = [[WordpressApi alloc] initWithUser:blog.userName andPassword:blog.password andUrl:blog.xmlrpc andBlogId:[blog.blogId stringValue]];
			
				id response = [api getUsersBlogs];
				
				if (response !=nil && ![response isKindOfClass:[NSError class]]) {
				
					for(Category *c in blog.categories){
				
						if(c.categoryId==nil){				
							[api addNewCategory:c];
						}
				
					}

					NSMutableArray *categories=[api getCategories];
					[blog syncCategoriesFromArray:categories];
					[blog saveData];
					DDLogInfo(@"Sincronizando categorías... OK");
					[loadingIndicator stopAnimation:window];
					
					if (!mainController) {
						mainController = [[MainWindowController alloc] initWithBlog:blog];
					}
					[_window close];
					DDLogInfo(@"Showing %@", mainController);
					[mainController showWindow:self];
				
				}else{
					
					[loadingIndicator stopAnimation:window];
					[_window close];
					
					if(response!=nil){
						
						[NSApp presentError:response];
						
					}else{
						
						NSString* value= @"404";
						NSString* errorMessage=NSLocalizedString(@"UNABLE_CONNECT_HOST", @"Unable to connect to host.");
						
						NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
						[errorDetail setValue:errorMessage forKey:NSLocalizedDescriptionKey];
						NSError *error = [NSError errorWithDomain:@"com.kyr.post-off" code:(int)value userInfo:errorDetail];
						
						[NSApp presentError:error];
					}
					
					ReLoginWindowController *loginController = [[ReLoginWindowController alloc] initWithBlog:blog];
					
					[loginController showWindow:self];
					
				}
				
				
			//Si no se cargan las categorías al incio...
			}else{
				
				if (!mainController) {
					mainController = [[MainWindowController alloc] initWithBlog:blog];
				}
				[loadingIndicator stopAnimation:window];
				[_window close];
				DDLogInfo(@"Showing %@", mainController);
				[mainController showWindow:self];
				
			}
            
        }
		
		[fetchRequest release];
	}
	DDLogInfo(@"Después ...%d",value);
	
}

/**
    Returns the directory the application uses to store the Core Data store file. This code uses a directory named "Post_Off" in the user's Library directory.
 */
- (NSURL *)applicationFilesDirectory {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"Post_Off"];
}

/**
    Creates if necessary and returns the managed object model for the application.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel) {
        return __managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Post_Off" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
    Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
        
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    else {
        if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Post_Off.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom] autorelease];
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __persistentStoreCoordinator = [coordinator retain];

    return __persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}

/**
    Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

/**
    Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 */
- (IBAction)saveAction:(id)sender {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    // Save changes in the application's managed object context before the application terminates.

    if (!__managedObjectContext) {
        return NSTerminateNow;
    }

    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}


@end
