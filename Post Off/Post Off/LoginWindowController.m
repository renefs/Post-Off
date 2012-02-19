//
//  LoginWindowController.m
//  Post Off
//
//  Created by René on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginWindowController.h"

@implementation LoginWindowController

@synthesize blog;

-(id) init{
	
	self = [super initWithWindowNibName:@"LoginWindow"];
    if (self) {
        lastValidNumberOfPostsToSync = [[NSString alloc] initWithString:@"0"];
    }
    
    return self;
	
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    DDLogInfo(@"Loaded Login Window");
    
    /*NSMenu* rootMenu = [NSApp mainMenu];
    
    for(NSMenuItem *i in [rootMenu itemArray]){
        [i setEnabled:NO];
    }*/
}

- (IBAction)register:(id)sender{
	
	[NSApp beginSheet:loadingSheet modalForWindow:[self window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
	
    NSString* url = [urlField stringValue];
    DDLogInfo(@"url: %@",url);
    if(![url hasPrefix:@"http"])
        url = [NSString stringWithFormat:@"http://%@", url];
    
    url = [url stringByReplacingOccurrencesOfRegex:@"/wp-admin/?$" withString:@""]; 
    url = [url stringByReplacingOccurrencesOfRegex:@"/?$" withString:@""]; 
    
    NSString *xmlrpc;
    if ([url hasSuffix:@"xmlrpc.php"]){
        DDLogInfo(@"Tiene prefijo xmlrpc: url: %@",url);
        xmlrpc = url;
    }else{
        xmlrpc = [NSString stringWithFormat:@"%@/xmlrpc.php", url];
        DDLogInfo(@"No tiene prefijo xmlrpc: url: %@",xmlrpc);
    }
    
    DDLogInfo(@"url: %@",url);
    
	[loadingIndicator startAnimation:sender];
	//[tabs selectTabViewItemAtIndex:1];
	
	api = [[WordpressApi alloc] initWithUser:[userField stringValue] andPassword:[passwordField stringValue] andUrl:xmlrpc];
	
	id response = [api getUsersBlogs];
	
	//[tabs selectTabViewItemAtIndex:2];
	
	if (response !=nil && ![response isKindOfClass:[NSError class]]) {
		
		int blogIndex=-1;
		
		for(NSDictionary *d in response){
			blogIndex=blogIndex+1;
			NSString *u =[d objectForKey:@"url"];
			
			NSRange urlRange;
			urlRange = [u rangeOfString:url];
			if(urlRange.location != NSNotFound){
				break;
			}
		}
		
        NSMutableDictionary *newBlog = [NSMutableDictionary dictionaryWithDictionary:[response objectAtIndex:blogIndex]];
        [newBlog setObject:[userField stringValue] forKey:@"username"];
        [newBlog setObject:@"inKeychain" forKey:@"password"];
        DDLogInfo(@"creating blog: %@", newBlog);
        
        //NSManagedObjectContext = [[appDelegate KYRAppDelegate] managedObjectCotext];
        
        blog = [Blog createBlogFromDictionary:newBlog withContext:[[NSApp delegate] managedObjectContext] andPassWord:[passwordField stringValue]];        
        [blog saveData];
        
        [loadingLabel setStringValue:@"Syncing categories of the blog."];
         DDLogInfo(@"Syncing categories of the blog.");
        [api setBlogId:[blog.blogId stringValue]];
        NSMutableArray *categories=[api getCategories];
        [blog syncCategoriesFromArray:categories];
		
		[categories release];
		
		[loadingLabel setStringValue:@"Syncing posts of the blog."];
		
		if([numberOfPostsToSync intValue]>0){
			DDLogInfo(@"Syncing posts of the blog.");		
			id postsResponse = [api getRecentPosts:[numberOfPostsToSync intValue]];
		
			[blog syncPostsFromArray:postsResponse];
			DDLogInfo(@"Posts sincronizados...");
		}
        
        [loadingIndicator stopAnimation:sender];
        [loadingSheet orderOut:sender];
        [NSApp endSheet:loadingSheet];
                
        [NSApp beginSheet:doneSheet modalForWindow:[self window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
		
		DDLogInfo(@"Estableciendo a 0 kyrIsFirstLaunch");
		[UserDefaultsHelper setUserStringValue:@"0" forKey:kyrIsFirstLaunch];
		[UserDefaultsHelper setUserStringValue:@"10" forKey:kyrNumberOfPostsToSync];
	//Error found...
	}else{
	
		if(response!=nil){
			

			[NSApp presentError:response];
			
			[loadingIndicator stopAnimation:sender];
            [loadingSheet orderOut:sender];
            [NSApp endSheet:loadingSheet];
			
		}else{
			
			NSString* value= @"404";
			NSString* errorMessage=NSLocalizedString(@"UNABLE_CONNECT_HOST", @"Unable to connect to host.");
			
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:errorMessage forKey:NSLocalizedDescriptionKey];
			NSError *error = [NSError errorWithDomain:@"com.kyr.post-off" code:(int)value userInfo:errorDetail];
			
			[NSApp presentError:error];
            
            [loadingIndicator stopAnimation:sender];
            [loadingSheet orderOut:sender];
            [NSApp endSheet:loadingSheet];
		}
		
		
	}
	
}

-(IBAction)backToLogin:(id)sender{
	
    [errorSheet orderOut:sender];
	[NSApp endSheet:errorSheet];	
	
}

-(IBAction)returnToStart:(id)sender{

    [doneSheet orderOut:sender];
	[NSApp endSheet:doneSheet];
	
	if (!mainController) {
        
        NSError *error;
        
        /*int localId=[[UserDefaultsHelper getUserValueForKey:kyrBlogAutoId withDefault:@"-1"] intValue];
        DDLogInfo(@"Se carga el localId %d...", localId);
        NSFetchRequest * request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Blog" inManagedObjectContext:[[NSApp delegate] managedObjectContext]]];
        
        [request setPredicate:[NSPredicate predicateWithFormat:@"localId=%d", localId]];
        
        Blog *b=  [[[[NSApp delegate] managedObjectContext] executeFetchRequest:request error:&error] lastObject];*/
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Blog" inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
		[fetchRequest setEntity:entity ];
		NSArray *fetchedObjects = [[[NSApp delegate] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
		Blog *b = [fetchedObjects objectAtIndex:0];
		
        [fetchRequest release];
        
        [[NSApp delegate] setBlog:b];
        
		mainController = [[MainWindowController alloc] initWithBlog:b];
        //[[NSApp delegate] setMainController:mainController];
        
        NSMenu* rootMenu = [NSApp mainMenu];
        
        for(NSMenuItem *i in [rootMenu itemArray]){
            [i setEnabled:YES];
        }
	}
    
	[[self window] close];
	DDLogInfo(@"Showing %@", mainController);
	[mainController showWindow:[mainController window]];

	
}

/*-(void)textDidChange:(NSNotification *)aNotification
{
	if( [upperCaseBtn  state] == NSOnState )
	{
		[self  setStringValue:[[self  stringValue]  uppercaseString]];
	}
}*/

- (void)controlTextDidChange:(NSNotification *)obj
{
    if (obj.object == numberOfPostsToSync){
        NSString *countValue = [numberOfPostsToSync stringValue];

			DDLogInfo(@"CountValue: %@", countValue);
			if (! [countValue isMatchedByRegex:@"^[\\d\\,]{0,6}$"])
			{
				numberOfPostsToSync.stringValue = lastValidNumberOfPostsToSync;
				NSBeep();
			}
			else{
				lastValidNumberOfPostsToSync = numberOfPostsToSync.stringValue;
				DDLogInfo(@"lastValidNumberOfPostsToSync: %@", lastValidNumberOfPostsToSync);
			}
    }
}

- (void) dealloc{
    
    [api release];
    [super release];
}

@end
