//
//  ManagePostsViewController.m
//  Post Off
//
//  Created by René on 22/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ManagePostsViewController.h"
#import "MainWindowController.h"

@implementation ManagePostsViewController

@synthesize post,posts, windowController,blog;

- (id) initWithBlog:(Blog*) b andWindowController:(MainWindowController*) m{
	
	if(![super initWithNibName:@"ManagePostsView" bundle:nil]){
		return nil;
	}
	[self setTitle:@"Manage Posts"];
    
	self.windowController=m;
    self.blog=b;
	[self fetchPosts];
    
	return self;
	
}

-(void) fetchPosts{
	
    posts = [[NSMutableArray alloc] init];
    

            if([blog.posts count]>0){
				
				for (Post *p in blog.posts) {
                    DDLogInfo(@"%@", p);
                    
                    PostContainer *sc = [[PostContainer alloc] initWithPost:p andStatus:NO];
                    
                    if(![p.status isEqualToString:@"deleted"]){                    
                        [posts addObject:sc];
                    }
                }
                
            }else{
                DDLogInfo(@"EROR: No posts found.");            
           }
	
}

-(void) awakeFromNib{
	DDLogInfo(@"AwakeFromNib");
	
	[postsTable setDoubleAction:@selector(editPost)];
	
	[titleColumn setIdentifier:@"titleColumn"];
    [formatColumn setIdentifier:@"formatColumn"];
    [dateColumn setIdentifier:@"dateColumn"];
	[statusColumn setIdentifier:@"statusColumn"];
	[authorColumn setIdentifier:@"authorColumn"];
	[checkColumn setIdentifier:@"checkColumn"];
	
	[titleColumn setSortDescriptorPrototype:[NSSortDescriptor sortDescriptorWithKey:@"title"
																	   ascending:YES
																		selector:@selector(caseInsensitiveCompare:)]];
	[formatColumn setSortDescriptorPrototype:[NSSortDescriptor sortDescriptorWithKey:@"postFormat"
																	   ascending:YES
																		selector:@selector(caseInsensitiveCompare:)]];
	[dateColumn setSortDescriptorPrototype:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated"
																	   ascending:YES
																		selector:@selector(compare:)]];
	[statusColumn setSortDescriptorPrototype:[NSSortDescriptor sortDescriptorWithKey:@"status"
																	   ascending:YES
																		selector:@selector(caseInsensitiveCompare:)]];
	[authorColumn setSortDescriptorPrototype:[NSSortDescriptor sortDescriptorWithKey:@"author"
																	   ascending:YES
																		selector:@selector(caseInsensitiveCompare:)]];
	
	[postsTable scrollRowToVisible:0];
	[deleteButton setEnabled:NO];
}

- (NSInteger)count{
	
	return [self.posts count];
	
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *) tv{
	DDLogInfo(@"posts class=: %@", [self.posts class]);
	return [self.posts count];
	
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex{
	

	Post *p = [[posts objectAtIndex:rowIndex] post];
	//DDLogInfo(@"objectValue: %@",[tableColumn identifier]);
	if ([[tableColumn identifier] isEqualToString:@"titleColumn"]) {
		return p.title;
	}
	
	if ([[tableColumn identifier] isEqualToString:@"formatColumn"]) {
		return p.postFormat;
	}
	
	if ([[tableColumn identifier] isEqualToString:@"authorColumn"]) {
		return p.author;
	}
	
	if ([[tableColumn identifier] isEqualToString:@"dateColumn"]) {
		return p.dateCreated;
	}
	
	if ([[tableColumn identifier] isEqualToString:@"statusColumn"]) {
		
		
		if([p.status isEqualToString:@"draft"]){
			return NSLocalizedString(@"DRAFT", @"Draft");
		}else if([p.status isEqualToString:@"publish"]){
			return NSLocalizedString(@"PUBLISH", @"Publish");
		}
		
		return NSLocalizedString(@"NONE", @"None");
	}
	
	
	return @"42";
}

- (void)tableView:(NSTableView *)tv willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
	
	if ([[aTableColumn identifier] isEqualToString:@"checkColumn"]) {
		[aCell setTitle:@""];
		[aCell setButtonType:NSSwitchButton];
		[aCell setEnabled:YES];
		[aCell setTransparent:NO];
        
        PostContainer *p = [posts objectAtIndex:rowIndex];
        
		[aCell setState:p.checkStatus];
	}
	
	
	
}

- (IBAction)checkboxChanged:(CustomTable*)sender {
    int row = [[sender selectedCellRowIndex] intValue];
    int column = [[sender selectedCellColumnIndex] intValue];
	DDLogInfo(@"Slected column=%d and row=%d", column,row);
    
    if(row!=-1 && column!=-1){
        
        NSTableColumn* theColumn = [[sender tableColumns] objectAtIndex:column];
        id dataCell = [theColumn dataCellForRow:row];
        
        if ([dataCell isKindOfClass:[NSButtonCell class]]){
            DDLogInfo(@"La celda column=%d and row=%d es un checkbox", column,row);
            
            if(column==0){
                
                PostContainer *p = [posts objectAtIndex:row];
                
                [p setCheckStatus:!p.checkStatus];
                
                if([posts count]<1 || [self numberOfSelectedItems]<1){
                    [deleteButton setEnabled:NO];
                }else{
                    [deleteButton setEnabled:YES];
                }
                
                [sender reloadData]; // update listing
            }
        }
        
    }
    
    
}

- (void) tableViewSelectionDidChange:(NSNotification *) notification{
	
	NSInteger row= [postsTable selectedRow];
	if(row <0 || row > [posts count]-1){
		[postsTable setSelectedCellRowIndex:[[NSNumber alloc] initWithInt:-1]];
        [postsTable setSelectedCellColumnIndex:[[NSNumber alloc] initWithInt:-1]];
		DDLogInfo(@"No hay seleccioada fila");
		
		return;
	}
	
	NSString *selectedPost= [posts objectAtIndex:row];
	DDLogInfo(@"Nuevo post = %@", selectedPost);
	
}

#pragma mark Delegate Methods

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)tv
{
	
	return YES;
	
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
	// Either reverse the sort or change the sorting column
	[posts sortUsingDescriptors: [tableView sortDescriptors]];
    [tableView reloadData];
}


- (void) editPost{
	
	NSInteger row= [postsTable selectedRow];
	if(row <0 || row > [posts count]-1){
		
        [postsTable setSelectedCellRowIndex:[[NSNumber alloc] initWithInt:-1]];
        [postsTable setSelectedCellColumnIndex:[[NSNumber alloc] initWithInt:-1]];
		DDLogInfo(@"Doble clic sin fila");

	}else{
	
		PostContainer *selectedPost= [posts objectAtIndex:row];
		DDLogInfo(@"Doble clic = %@", selectedPost.post);
		
		self.post=selectedPost.post;
		
		if(post.postId!=nil && [post.postId intValue]!=0){
		
			[self syncSelectedItem];
		
		}else{
			
			[windowController setContentViewNewArticleViewWithPost:self.post];
			
		}
		
		
	}
}

- (IBAction)applyAction:(id)sender {
    
    [self deleteSelectedItems];
	
}

- (BOOL) deleteSelectedItems{
	DDLogInfo(@"deleteSelectedItems...");
	
	NSAlert *testAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"SURE_DELETE", @"Are you sure you want delete these items?")
                                         defaultButton:NSLocalizedString(@"CANCEL", @"Cancel")
                                       alternateButton:NSLocalizedString(@"DELETE", @"Delete")
                                           otherButton:nil
                             informativeTextWithFormat:NSLocalizedString(@"INFO_TRASH", @"This items will be send to trash.")];
	
	
	[testAlert setAlertStyle:NSCriticalAlertStyle];
	
	[testAlert beginSheetModalForWindow:[postsTable window]
						  modalDelegate:self
						 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
							contextInfo:nil];
	
	return YES;
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
			/*
			 Si se han realizado cambios en el servidor, no tenemos la versión actualizada, así que no hay que hacer nada.
			 */
			DDLogInfo(@"result: NSAlertAlternateReturn");				
			[self syncLocalCurrentPost];
			
			break;
            
        default:
			/*
			 Si no se han realizado cambios en el servidor, tenemos la versión actualizada, así que no hay que hacer nada.
			 */
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
		[loadingLabel setStringValue:NSLocalizedString(@"SYNCING_LOCAL_POST", @"Syncing local post...")];
	
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

-(void)handleResult:(NSAlert *)alert withResult:(NSInteger)result
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
			
			DDLogInfo(@"Obteniendo posts activados...");
			//NSMutableArray *tempPosts= [[NSMutableArray alloc] init];
			
			for(PostContainer *p in posts){
                if(p.checkStatus == YES){
                    [p.post setStatus:@"deleted"];
                    [p.post save];
                }
            }
			
			//Borrar los campos personalizados del array.
			[self fetchPosts];
			[postsTable reloadData];
			
			if([posts count]<1 || [self numberOfSelectedItems]<1){
				[deleteButton setEnabled:NO];
			}
			
			break;
            
        default:
            break;
	}
	
	
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	DDLogInfo(@"Alert did end.");
#pragma unused (contextInfo)
	[[alert window] orderOut:self];
	//DDLogInfo(@"Result code: %@", returnCode);
	[self handleResult:alert withResult:returnCode];
}

-(int) numberOfSelectedItems{
	
	int n=0;
	int i;
	for(i=0;i<[posts count];i++){
		
        PostContainer *sc = [posts objectAtIndex:i];
        
		BOOL e=sc.checkStatus;
		if(e==YES)
			n=n+1;
	}
	return n;
}

@end
