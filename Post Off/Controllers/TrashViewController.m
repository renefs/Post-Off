//
//  TrashViewController.m
//  Post Off
//
//  Created by René on 14/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TrashViewController.h"

@implementation TrashViewController

@synthesize posts,blog;

- (id) initWithBlog:(Blog*) b{
	
	if(![super initWithNibName:@"TrashView" bundle:nil]){
		return nil;
	}
	[self setTitle:@"Trash"];
	
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
                    
                    if([p.status isEqualToString:@"deleted"]){                    
                        [posts addObject:sc];
                    }
                }
                
            }else{
                DDLogInfo(@"No posts found.");            
            }

}

-(void) awakeFromNib{
	DDLogInfo(@"AwakeFromNib");
	
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
    [recoverButton setEnabled:NO];
	
}

- (NSInteger)count{
	
	return [self.posts count];
	
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *) tv{
	return [posts count];
	
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex{
	
	
	Post *p = [[posts objectAtIndex:rowIndex] post];
	DDLogInfo(@"objectValue: %@",[tableColumn identifier]);
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
		return p.status;
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
                    [recoverButton setEnabled:NO];
                }else{
                    [deleteButton setEnabled:YES];
                    [recoverButton setEnabled:YES];
                }
                
                [sender reloadData]; // update listing
            }
        }
        
    }
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

- (void) tableViewSelectionDidChange:(NSNotification *) notification{
	
	NSInteger row= [postsTable selectedRow];
	if(row <0 || row > [posts count]-1){
		
		NSLog(@"No hay seleccioada fila");
		
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


- (IBAction)recoverAction:(id)sender {
	
    [self recoverSelectedItems];
	
}

- (BOOL) recoverSelectedItems{
	DDLogInfo(@"deleteSelectedItems...");
	
	NSAlert *testAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"SURE_RECOVER", @"Are you sure you want recover this items?")
                                         defaultButton:NSLocalizedString(@"CANCEL", @"Cancel")
                                       alternateButton:NSLocalizedString(@"RECOVER", @"Recover")
                                           otherButton:nil
                             informativeTextWithFormat:NSLocalizedString(@"INFO_RECOVER", @"Thess items will be available on the \"Manage Posts\" screen as drafts")];
	
	
	[testAlert setAlertStyle:NSCriticalAlertStyle];
	
	[testAlert beginSheetModalForWindow:[postsTable window]
						  modalDelegate:self
						 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
							contextInfo:nil];
	
	return YES;
}

-(void)handleRecoverResult:(NSAlert *)alert withResult:(NSInteger)result
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
                    [p.post setStatus:@"draft"];
                    [p.post save];
                }
            }
			
			//Borrar los campos personalizados del array.
			[self fetchPosts];
			[postsTable reloadData];
			
			if([posts count]<1 || [self numberOfSelectedItems]<1){
                [deleteButton setEnabled:NO];
                [recoverButton setEnabled:NO];
            }else{
                [deleteButton setEnabled:YES];
                [recoverButton setEnabled:YES];
            }
			
			break;
            
        default:
            break;
	}
	
	
}

- (IBAction)deleteAction:(id)sender {
	
    [self deleteSelectedItems];
	
}

- (BOOL) deleteSelectedItems{
	DDLogInfo(@"deleteSelectedItems...");
	
	NSAlert *testAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"SURE_DELETE", @"Are you sure you want delete these items?")
                                         defaultButton:NSLocalizedString(@"CANCEL", @"Cancel")
                                       alternateButton:NSLocalizedString(@"DELETE", @"Delete")
                                           otherButton:nil
                             informativeTextWithFormat:NSLocalizedString(@"PERMANENTLY_DELETE", @"These items will be permanently deleted.")];
	
	
	[testAlert setAlertStyle:NSCriticalAlertStyle];
	
	[testAlert beginSheetModalForWindow:[postsTable window]
						  modalDelegate:self
						 didEndSelector:@selector(deleteAlertDidEnd:returnCode:contextInfo:)
							contextInfo:nil];
	
	return YES;
}

-(void)handleDeleteResult:(NSAlert *)alert withResult:(NSInteger)result
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
			NSMutableArray *tempPosts= [[NSMutableArray alloc] init];
			
			for(PostContainer *p in posts){
                if(p.checkStatus == YES){
                    [tempPosts addObject:p.post];
                }
            }
            
            [blog deletePosts:tempPosts];
			
			//Borrar los campos personalizados del array.
			[self fetchPosts];
			[postsTable reloadData];
			
			if([posts count]<1 || [self numberOfSelectedItems]<1){
                [deleteButton setEnabled:NO];
                [recoverButton setEnabled:NO];
            }else{
                [deleteButton setEnabled:YES];
                [recoverButton setEnabled:YES];
            }
			
			break;
            
        default:
            break;
	}
	
	
}

- (void)deleteAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	DDLogInfo(@"Alert did end.");
#pragma unused (contextInfo)
	[[alert window] orderOut:self];
	//DDLogInfo(@"Result code: %@", returnCode);
	[self handleDeleteResult:alert withResult:returnCode];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	DDLogInfo(@"Alert did end.");
#pragma unused (contextInfo)
	[[alert window] orderOut:self];
	//DDLogInfo(@"Result code: %@", returnCode);
	[self handleRecoverResult:alert withResult:returnCode];
}

@end
