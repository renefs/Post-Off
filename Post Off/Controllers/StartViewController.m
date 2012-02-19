//
//  StartViewController.m
//  Post Off
//
//  Created by René on 22/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StartViewController.h"
#import "MainWindowController.h"
@implementation StartViewController

@synthesize blog,posts,windowController,post;

- (id) initWithBlog:(Blog*) b andWindowController:(MainWindowController*) m{
	
	if(![super initWithNibName:@"StartView" bundle:nil]){
		return nil;
	}
	DDLogInfo(@"%s (%@)", (char*)_cmd, [self class]);
    self.blog=b;
    
    posts = [[NSMutableArray alloc] init];

    for (Post *p in blog.posts){
        [self.posts addObject:p];
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"dateCreated"
                                                  ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [posts sortedArrayUsingDescriptors:sortDescriptors];
    
    NSMutableArray *tempPosts = [[NSMutableArray alloc] init];
    int i=0;
    for (Post *p in sortedArray) {
        if(i>4)
          break;
        [tempPosts addObject:p];
        i=i+1;
    }
    
    posts = [tempPosts mutableCopy];
    
    [tempPosts release];
    
    DDLogInfo(@"Posts count: %d", [posts count]);
    
	self.windowController=m;
	return self;
	
}

- (void) awakeFromNib{
    
    [postsTable setTarget:self];
    [postsTable setDoubleAction:NSSelectorFromString(@"editPost")];
    [titleColumn setIdentifier:@"titleColumn"];
    [dateColumn setIdentifier:@"dateColumn"];
    
    
	DDLogInfo(@"%s (%@)", (char*)_cmd, [self class]);
	[user setStringValue:blog.userName];
	[url setStringValue:blog.url];
	[blogTitle setStringValue:blog.blogName];
	[numCats setStringValue: [[NSString alloc] initWithFormat:@"%d", [blog.categories count]]];
    
    int countDrafts=0;
    int countDeleted=0;
    for (Post *p in blog.posts) {
        if(![p.status isEqualToString:@"deleted"]){
            countDrafts=countDrafts+1;
        }else{
            countDeleted=countDeleted+1;
        }
    }
    
    [numPosts setStringValue: [[NSString alloc] initWithFormat:@"%d", countDrafts]];
    [numTrash setStringValue: [[NSString alloc] initWithFormat:@"%d", countDeleted]];
    
    [numCFields setStringValue: [[NSString alloc] initWithFormat:@"%d", [blog.cFields count]]];

}

- (void) editPost{
	
    
    NSLog(@"Editing...");
	NSInteger row= [postsTable selectedRow];
	if(row <0 || row > [posts count]-1){
		
		DDLogInfo(@"Doble clic sin fila");
        
	}else{
        
		Post *selectedPost= [posts objectAtIndex:row];
		DDLogInfo(@"Doble clic = %@", selectedPost);
		
		self.post=selectedPost;
		
		if(post.postId!=nil && [post.postId intValue]!=0){
		
			[self syncSelectedItem];
		}else{
			
			[windowController setContentViewNewArticleViewWithPost:self.post];
			
		}
		
	}
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *) tv{
	return [posts count];
	
}

- (void) tableViewSelectionDidChange:(NSNotification *) notification{
	
	NSInteger row= [postsTable selectedRow];
	if(row <0 || row > [posts count]-1){
		[postsTable setSelectedCellRowIndex:[[NSNumber alloc] initWithInt:-1]];
        [postsTable setSelectedCellColumnIndex:[[NSNumber alloc] initWithInt:-1]];
		NSLog(@"No hay seleccioada fila");
		
		return;
	}
	
	NSString *selectedPost= [posts objectAtIndex:row];
	DDLogInfo(@"Nuevo post = %@", selectedPost);
	
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex{
	Post *p = [posts objectAtIndex:rowIndex];
	//DDLogInfo(@"objectValue: %@",[tableColumn identifier]);
	if ([[tableColumn identifier] isEqualToString:@"titleColumn"]) {
		return p.title;
	}
	
	if ([[tableColumn identifier] isEqualToString:@"dateColumn"]) {
		return p.dateCreated;
	}
    return @"42";
}

- (BOOL) syncSelectedItem{
	DDLogInfo(@"deleteSelectedItems...");
	
	NSAlert *testAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"UPDATED_FROM_BLOG", @"Did you update this post on your Wordpress dashboard?")
                                         defaultButton:NSLocalizedString(@"CANCEL", @"Cancel")
                                       alternateButton:NSLocalizedString(@"YES", @"Yes")
                                           otherButton:NSLocalizedString(@"NO", @"No")
                             informativeTextWithFormat:NSLocalizedString(@"INFO_UPDATE", @"If so, the local version must be updated to keep both versions synced.")];
	
	
	[testAlert setAlertStyle:NSCriticalAlertStyle];
	
	[testAlert beginSheetModalForWindow:[postsTable window]
						  modalDelegate:self
						 didEndSelector:@selector(syncAlertDidEnd:returnCode:contextInfo:)
							contextInfo:nil];
	
	return YES;
}

-(void)handleSyncResult:(NSAlert *)alert withResult:(NSInteger)result
{
	//DDLogInfo(@"Handling result %@",result);
	// report which button was clicked
	switch(result)
	{
		case NSAlertDefaultReturn:
			DDLogInfo(@"result: NSAlertDefaultReturn");
			break;
			
		case NSAlertAlternateReturn:
			DDLogInfo(@"result: NSAlertAlternateReturn");				
			[self syncLocalCurrentPost];
			
			break;
            
        default:
			DDLogInfo(@"result: NSAlertOtherReturn");
			[self syncServerCurrentPost];
			
            break;
	}
	
	
}

- (void)syncAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	DDLogInfo(@"Alert did end.");
#pragma unused (contextInfo)
	[[alert window] orderOut:self];
	//DDLogInfo(@"Result code: %@", returnCode);
	[self handleSyncResult:alert withResult:returnCode];
}

- (void) syncLocalCurrentPost{
	
	WordpressApi *api = [[WordpressApi alloc] initWithUser:blog.userName andPassword:blog.password andUrl:blog.xmlrpc andBlogId:[blog.blogId stringValue]];
	
	[loadingIndicator startAnimation:loadingSheet];
	[NSApp beginSheet:loadingSheet modalForWindow:[postsTable window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
	
	DDLogInfo(@"Sincronizando post...");
	[loadingLabel setStringValue:NSLocalizedString(@"SYNCING_LOCAL_POST",@"Syncing server post...")];
	
	if(post.postId!=nil && [post.postId intValue]!=0){
		DDLogInfo(@"El post tiene id %@ así que se edita el existente...", [post.postId stringValue]);
		id response = [api getPostWithId:[post.postId stringValue]];
		
		if (response !=nil && ![response isKindOfClass:[NSError class]]) {
			
			[post updateFromDictionary:response];
			DDLogInfo(@"Post local sincronizado... OK");
			[blog saveData];
			
		}else{
			
			if(response!=nil){
				
				
				[NSApp presentError:response];
				
				/*[loadingIndicator stopAnimation:loadingSheet];
				[loadingSheet orderOut:loadingSheet];
				[NSApp endSheet:loadingSheet];*/
				
			}else{
				
				NSString* value= @"404";
				NSString* errorMessage=NSLocalizedString(@"UNABLE_CONNECT_HOST", @"Unable to connect to host.");
				
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				[errorDetail setValue:errorMessage forKey:NSLocalizedDescriptionKey];
				NSError *error = [NSError errorWithDomain:@"com.kyr.post-off" code:(int)value userInfo:errorDetail];
				
				[NSApp presentError:error];
				
				/*[loadingIndicator stopAnimation:loadingSheet];
				[loadingSheet orderOut:loadingSheet];
				[NSApp endSheet:loadingSheet];*/
			}
			
			
		}
		
		
	}
	
	[loadingIndicator stopAnimation:loadingSheet];
	
	[loadingSheet orderOut:self];
	[NSApp endSheet:loadingSheet];
	
	[windowController setContentViewNewArticleViewWithPost:self.post];
	
}

- (void) syncServerCurrentPost{
	
	[windowController setContentViewNewArticleViewWithPost:self.post];
	
	
}
@end
