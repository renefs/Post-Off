//
//  Preferences.m
//  Post Off
//
//  Created by René on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PreferencesWindowController.h"

@implementation PreferencesWindowController

@synthesize blog,mainWindowController,tabs;

- (id) initWithBlog:(Blog*) b andMainWindowController:(MainWindowController*) mv{
	
	self = [super initWithWindowNibName:@"Preferences"];
	
	if(self){
		
        self.blog=b;
		self.mainWindowController=mv;
		 lastValidNumberOfPostsToSync = [[NSString alloc] initWithString:@"0"];
		api = [[WordpressApi alloc] initWithUser:blog.userName andPassword:blog.password andUrl:blog.xmlrpc];
		[api setBlogId:[blog.blogId stringValue]];
	}
	
	return self;
	
}

- (void) windowDidLoad{
	DDLogInfo(@"Preferences Nib loaded");
	
	/*NSError *error;
	
	// Test listing all FailedBankInfos from the store
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Blog" 
											  inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
	[fetchRequest setEntity:entity];
	NSArray *fetchedObjects = [[[NSApp delegate] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	for (Blog *c in fetchedObjects) {
        
        self.blog=c;*/
        
		DDLogInfo(@"User: %@", blog.userName);
		[user setStringValue:blog.userName];
		//NSLog(@"Pass: %@", blog.password);
        
        NSString *pass = [[EMGenericKeychainItem genericKeychainItemForService:@"com.kyr.post-off" withUsername:blog.userName ] password];
        
		[password setStringValue:pass];
		DDLogInfo(@"blogId: %@", blog.blogId);
		[blogId setStringValue:   [blog.blogId stringValue]];
		DDLogInfo(@"url: %@", blog.url);
		[url setStringValue:blog.url];
		DDLogInfo(@"isAdmin: %@",  [blog.isAdmin stringValue]);
		DDLogInfo(@"xmlrpc: %@", blog.xmlrpc);
	
	int syncCategoriesOnStart=[[UserDefaultsHelper getUserValueForKey:kyrSyncCategoriesOnStart withDefault:@"-1"] intValue];
	if(syncCategoriesOnStart == 1){
		[syncOnStartCheckBox setState:YES];
    }else{
		[syncOnStartCheckBox setState:NO];
	}
	
	int n=[[UserDefaultsHelper getUserValueForKey:kyrNumberOfPostsToSync withDefault:@"0"] intValue];	
	[numberOfPostsToSyncTF setStringValue: [[NSString alloc] initWithFormat:@"%d",n]];
	
	[resetBlogCheckBox setState:0];
	[resetBlogButton setEnabled:NO];
    [removeBlogCheckBox setState:0];
    [removeBlogButton setEnabled:NO];
	[syncCatsCheckBox setState:0];
	[syncPostsCheckBox setState:0];
	
	if(n<=0)
		[syncPostsCheckBox setEnabled:0];
	[syncBlogButton setEnabled:NO];
	/*}
    
	[fetchRequest release];
	*/
}

- (IBAction)checkboxChanged:(NSButton*)sender {
	
	if(sender == syncCatsCheckBox || sender == syncPostsCheckBox){
		

		if([syncCatsCheckBox state]== 1 || ([syncPostsCheckBox state]== 1 && [numberOfPostsToSyncTF intValue]>0)){
			[syncBlogButton setEnabled:YES];
		}else{
			[syncBlogButton setEnabled:NO];
		}
		
	}
	
	
	if(sender == removeBlogCheckBox){
		
		if([sender state]==0){
			[removeBlogButton setEnabled:NO];     
		}else{
			[removeBlogButton setEnabled:YES];
		}
		
	}
	
	if(sender == resetBlogCheckBox){
		
		if([sender state]==0){
			[resetBlogButton setEnabled:NO];     
		}else{
			[resetBlogButton setEnabled:YES];
		}
		
	}
    
}

- (IBAction)removeBlogAcAction:(id)sender{
    
    [self removeBlog];
}

- (IBAction)resetBlogAcAction:(id)sender{
	
	[NSApp beginSheet:loadingSheet modalForWindow:[self window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
    
    NSManagedObjectContext *context= [[NSApp delegate] managedObjectContext];
    
    DDLogInfo(@"Borrando posts...");
    [blog deletePosts:[blog.posts mutableCopy]];
    DDLogInfo(@"Borrando categorías...");
    [blog deleteCategories:[blog.categories mutableCopy]];
    DDLogInfo(@"Borrando campos...");
    [blog deleteCustomFields:[blog.cFields mutableCopy]];
    
	
    DDLogInfo(@"Guardando cambios...");
    NSError *error = nil;
    if (![context save:&error]) {
        DDLogInfo(@"Unresolved Core Data Save error %@, %@", error, [error userInfo]);
        exit(-1);
    }
	
	[mainWindowController setContentViewStartView];
        
        
	[loadingIndicator stopAnimation:sender];
	[loadingSheet orderOut:sender];
	[NSApp endSheet:loadingSheet];
    
	
}

-(void) removeBlog{
	DDLogInfo(@"Estableciendo a 1 kyrIsFirstLaunch");
    [UserDefaultsHelper setUserStringValue:@"1" forKey:kyrIsFirstLaunch];
    NSManagedObjectContext *context= [[NSApp delegate] managedObjectContext];
    
    DDLogInfo(@"Borrando posts...");
    [blog deletePosts:[blog.posts mutableCopy]];
    DDLogInfo(@"Borrando categorías...");
    [blog deleteCategories:[blog.categories mutableCopy]];
    DDLogInfo(@"Borrando campos...");
    [blog deleteCustomFields:[blog.cFields mutableCopy]];
    DDLogInfo(@"Borrando blog...");
    [context deleteObject:blog];
    

    DDLogInfo(@"Guardando cambios...");
    NSError *error = nil;
    if (![context save:&error]) {
        DDLogInfo(@"Unresolved Core Data Save error %@, %@", error, [error userInfo]);
        exit(-1);
    }
    
    [[mainWindowController window] orderOut:self];
    [[mainWindowController window]close];
    
    [mainWindowController release];
    
    [[self window] close];
    
    LoginWindowController *loginController = [[LoginWindowController alloc] init];
    
    [loginController showWindow:self];
    
    [self release];
}

-(void) saveData{
    
    if(![blog.url isEqualToString: [url stringValue]]){
        blog.url=[url stringValue];
        
        NSString* sUrl= [url stringValue];
        
        if(![sUrl hasPrefix:@"http"])
            sUrl = [NSString stringWithFormat:@"http://%@", sUrl];
        
        sUrl = [sUrl stringByReplacingOccurrencesOfRegex:@"/wp-admin/?$" withString:@""]; 
        sUrl = [sUrl stringByReplacingOccurrencesOfRegex:@"/?$" withString:@""]; 
        
        NSString *xmlrpc;
        if ([sUrl hasSuffix:@"xmlrpc.php"]){
            DDLogInfo(@"Tiene prefijo xmlrpc: url: %@",sUrl);
            xmlrpc = sUrl;
        }else{
            xmlrpc = [NSString stringWithFormat:@"%@/xmlrpc.php", sUrl];
            DDLogInfo(@"No tiene prefijo xmlrpc: url: %@",xmlrpc);
        }
        
        blog.xmlrpc=xmlrpc;
        
    }
    
    if(![blog.userName isEqualToString: [user stringValue]]){
        blog.userName=[user stringValue];
    }
    
    NSString *pass = [[EMGenericKeychainItem genericKeychainItemForService:@"com.kyr.post-off" withUsername:blog.userName ] password];
    
    if(![pass isEqualToString:[password stringValue]]){
        
        [EMGenericKeychainItem setKeychainPassword:[password stringValue] forUsername:blog.userName service:@"com.kyr.post-off"];
    }
	
	if([syncOnStartCheckBox state]==YES){
		[UserDefaultsHelper setUserStringValue:@"1" forKey:kyrSyncCategoriesOnStart];
	}else{
		[UserDefaultsHelper setUserStringValue:@"0" forKey:kyrSyncCategoriesOnStart];
	}
    
    [blog saveData];
    
}

- (IBAction)save:(id)sender{
    
    [self saveData];
    
}

- (IBAction)cancel:(id)sender{
    
    [[self window] orderOut:self];
    [[self window] close];
    
}

- (void)controlTextDidChange:(NSNotification *)obj
{
    if (obj.object == numberOfPostsToSyncTF){
        NSString *countValue = [numberOfPostsToSyncTF stringValue];
		
		if([countValue intValue]>0){
			[syncBlogButton setEnabled:YES];
			[syncPostsCheckBox setEnabled:YES];
		}else{
			[syncBlogButton setEnabled:NO];
			[syncPostsCheckBox setEnabled:NO];
		}
		
		DDLogInfo(@"CountValue: %@", countValue);
		if (! [countValue isMatchedByRegex:@"^[\\d\\,]{0,6}$"])
		{
			numberOfPostsToSyncTF.stringValue = lastValidNumberOfPostsToSync;
			NSBeep();
		}
		else{
			lastValidNumberOfPostsToSync = numberOfPostsToSyncTF.stringValue;
			DDLogInfo(@"lastValidNumberOfPostsToSync: %@", lastValidNumberOfPostsToSync);
		}
    }
}

- (IBAction)syncBlogAcAction:(id)sender{
	
	[NSApp beginSheet:loadingSheet modalForWindow:[self window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
	
	[UserDefaultsHelper setUserStringValue:[numberOfPostsToSyncTF stringValue] forKey:kyrNumberOfPostsToSync];
	
    [loadingIndicator startAnimation:sender];
	//[tabs selectTabViewItemAtIndex:1];
	

	api = [[WordpressApi alloc] initWithUser:blog.userName andPassword:blog.password andUrl:blog.xmlrpc];
	[api setBlogId:[blog.blogId stringValue]];
	
        
		if([syncCatsCheckBox state] == 1){
			[loadingLabel setStringValue:NSLocalizedString(@"SYNCING_CATEGORIES",@"Syncing categories...")];
			DDLogInfo(@"Syncing categories of the blog.");

			id categoriesResponse=[api getCategories];
			
			if (categoriesResponse !=nil && ![categoriesResponse isKindOfClass:[NSError class]]) {
			
				[blog syncCategoriesFromArray:categoriesResponse];
		
				[categoriesResponse release];
			}else{
				
				if(categoriesResponse!=nil){
					
					
					[NSApp presentError:categoriesResponse];
					
					[mainWindowController setContentViewStartView];
					
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
					
					[mainWindowController setContentViewStartView];
					
					[loadingIndicator stopAnimation:sender];
					[loadingSheet orderOut:sender];
					[NSApp endSheet:loadingSheet];
					
				}
				
				
			}
			
			
			[mainWindowController setContentViewStartView];
			
			[loadingIndicator stopAnimation:sender];
			[loadingSheet orderOut:sender];
			[NSApp endSheet:loadingSheet];
			
		}
		
		if([syncPostsCheckBox state] == 1){
			
			[loadingLabel setStringValue:NSLocalizedString(@"SYNCING_POSTS",@"Syncing posts...")];
			
			if([numberOfPostsToSyncTF intValue]>0){
				DDLogInfo(@"Syncing posts of the blog.");		
				id postsResponse = [api getRecentPosts:[numberOfPostsToSyncTF intValue]];
				
				if (postsResponse !=nil && ![postsResponse isKindOfClass:[NSError class]]) {
				
					[blog syncPostsFromArray:postsResponse];
					DDLogInfo(@"Posts sincronizados...");
					
					[mainWindowController setContentViewStartView];
					
					[loadingIndicator stopAnimation:sender];
					[loadingSheet orderOut:sender];
					[NSApp endSheet:loadingSheet];
					
				}else{
				
					if(postsResponse!=nil){
					
					
						[NSApp presentError:postsResponse];
						
						[mainWindowController setContentViewStartView];
						
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
						
						[mainWindowController setContentViewStartView];
						
						[loadingIndicator stopAnimation:sender];
						[loadingSheet orderOut:sender];
						[NSApp endSheet:loadingSheet];
					
					}
				
				
				}

			}
			
		}

}

- (void) dealloc{
	[api dealloc];
	[super dealloc];
}

@end
