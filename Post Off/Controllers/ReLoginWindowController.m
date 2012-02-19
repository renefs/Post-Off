//
//  ReLoginWindowController.m
//  Post Off
//
//  Created by René on 14/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReLoginWindowController.h"

@implementation ReLoginWindowController

@synthesize blog;

- (id) initWithBlog:(Blog*) b{
	
	self = [super initWithWindowNibName:@"ReLoginWindow"];
	
	if(self){
        DDLogInfo(@"%s (%@)", (char*)_cmd, [self class]);
        self.blog=b;
	}
	
	return self;
	
}

- (void)windowDidLoad{
	
	[super windowDidLoad];
    NSLog(@"Loaded Main Window");
	
	[userNameField setStringValue:blog.userName];
	[passwordField setStringValue:blog.password];
	[urlField setStringValue:blog.url];
	
}

- (IBAction)cancelLogin:(id)sender{
	
	NSAlert *testAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"SURE_BAD_CREDENTIALS", @"Are you sure you want to continue?")
                                         defaultButton:NSLocalizedString(@"CANCEL", @"Cancel")
                                       alternateButton:NSLocalizedString(@"YES", @"Yes")
                                           otherButton:nil
                             informativeTextWithFormat:NSLocalizedString(@"INFO_CREDENTIALS", @"If you continue without setting up your credentials, you won't be able to publish or sync until you change them on the preferences panel.")];
	
	
	[testAlert setAlertStyle:NSCriticalAlertStyle];
	
	[testAlert beginSheetModalForWindow:[userNameField window]
						  modalDelegate:self
						 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
							contextInfo:nil];
	
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
			DDLogInfo(@"result: NSAlertAlternateReturn (YES)");
			
			if (!mainController) {
				mainController = [[MainWindowController alloc] initWithBlog:blog];
			}
			
			[[self window] close];
			DDLogInfo(@"Showing %@", mainController);
			[mainController showWindow:self];
			
			
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


- (IBAction)login:(id)sender{
	
	[loadingIndicator startAnimation:loadingSheet];
	[NSApp beginSheet:loadingSheet modalForWindow:[urlField window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
	
	if(![blog.url isEqualToString: [urlField stringValue]]){
        blog.url=[urlField stringValue];
        
        NSString* sUrl= [urlField stringValue];
        
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
    
    if(![blog.userName isEqualToString: [userNameField stringValue]]){
        blog.userName=[userNameField stringValue];
    }
    
    NSString *pass = [[EMGenericKeychainItem genericKeychainItemForService:@"com.kyr.post-off" withUsername:blog.userName ] password];
    
    if(![pass isEqualToString:[passwordField stringValue]]){
        
        [EMGenericKeychainItem setKeychainPassword:[passwordField stringValue] forUsername:blog.userName service:@"com.kyr.post-off"];
    }
	
	api = [[WordpressApi alloc] initWithUser:blog.userName andPassword:blog.password andUrl:blog.xmlrpc andBlogId:[blog.blogId stringValue]];
	
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
		[loadingIndicator stopAnimation:sender];
		
		if (!mainController) {
			mainController = [[MainWindowController alloc] initWithBlog:blog];
		}
		
		[loadingSheet orderOut:self];
		[NSApp endSheet:loadingSheet];
		
		[[self window] close];
		DDLogInfo(@"Showing %@", mainController);
		[mainController showWindow:self];
		
	}else{
		
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
		
		[loadingIndicator stopAnimation:sender];
		
		[loadingSheet orderOut:self];
		[NSApp endSheet:loadingSheet];
		
	}
	
	
	
}

- (void) dealloc{
    [api release];
    [super release];
}

@end
