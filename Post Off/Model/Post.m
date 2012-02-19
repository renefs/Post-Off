//
//  Post.m
//  Post Off
//
//  Created by Rene Fernandez on 17/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Post.h"

@implementation Post

@dynamic password,cFields,categories,blog, localId;
@dynamic slug,tags,title,author, authorId,postId,status,content,excerpt,moreTag,permalink,dateCreated,postFormat;


/*
 Busca un post en el blog por medio de su ID.
 */
+ (Post *)findWithBlog:(Blog *)blog andPostId:(NSNumber *)postId {
    NSSet *results = [blog.posts filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"postId == %@ AND original == NULL",postId]];
    
    if (results && (results.count > 0)) {
        return [[results allObjects] objectAtIndex:0];
    }
    return nil;
}

- (id) init{
	
	self = [super init];
	
	if(!self){
		return nil;		
	}
	
	return self;
	
}

/*
 Actualiza los datos del post desde el que se llama al método con la información del diccionario parámetro.
 */
- (void )updateFromDictionary:(NSDictionary *)postInfo {
    self.title      = [postInfo objectForKey:@"title"];
	//keep attention: getPosts and getPost returning IDs in different types
	if ([[postInfo objectForKey:@"postid"] isKindOfClass:[NSString class]]) {
        self.postId         = [NSNumber numberWithInt:[[postInfo objectForKey:@"postid"] intValue]];
	} else {
        self.postId         = [postInfo objectForKey:@"postid"];
	}
    self.author        = [postInfo objectForKey:@"wp_author_display_name"];
    self.authorId        = [NSNumber numberWithInt:[[postInfo objectForKey:@"userid"] intValue]];
	self.content        = [postInfo objectForKey:@"description"];
    self.dateCreated    = [postInfo objectForKey:@"date_created_gmt"];
    self.status         = [postInfo objectForKey:@"post_status"];
    self.password       = [postInfo objectForKey:@"wp_password"];
    self.tags           = [postInfo objectForKey:@"mt_keywords"];
	self.permalink      = [postInfo objectForKey:@"permaLink"];
	self.excerpt		= [postInfo objectForKey:@"mt_excerpt"];
	self.moreTag	= [postInfo objectForKey:@"mt_text_more"];
	self.slug		= [postInfo objectForKey:@"wp_slug"];
	self.postFormat = [postInfo objectForKey:@"wp_post_format"];
	
	
    self.status   = [postInfo objectForKey:@"post_status"];
    if ([postInfo objectForKey:@"categories"]) {
        [self setCategoriesFromNames:[postInfo objectForKey:@"categories"]];
    }
	
	if([postInfo objectForKey:@"custom_fields"]){
		
		DDLogInfo(@"Añadiendo plantillas de campos personalizados...");
		[self addPostCustomFieldTemplates: [postInfo objectForKey:@"custom_fields"]];
		DDLogInfo(@"Plantillas añadidas...");
		
		DDLogInfo(@"Añadiendo campos personalizados al post...");
		[self addCustomFieldsFromArray:[postInfo objectForKey:@"custom_fields"]];
		DDLogInfo(@"Campos añadidos...");
		
	}
    
	return;   
}

- (void) addCustomFieldsFromArray:(NSMutableArray*) customFields{
	
	for (NSDictionary *customField in customFields) {
		
		NSNumber *ID = [NSNumber numberWithInt:[[customField objectForKey:@"id"] intValue]];;
		NSString *key = [customField objectForKey:@"key"];
		NSString *value = [customField objectForKey:@"value"];
		
		if(![key hasPrefix:@"_"]){
		
			NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
		
			[dict setValue:ID forKey:@"cfId"];
			//[dict setValue:key forKey:@"name"];
			[dict setValue:key forKey:@"key"];
			[dict setValue:value forKey:@"value"];
			[dict setValue:self forKey:@"post"];
		
			[self addCustomFieldFromDictionary:dict];
		}
	}
}

- (void) addPostCustomFieldTemplates:(NSMutableArray*) customFields{
	
	for (NSDictionary *customField in customFields) {
		
		//NSString *ID = [customField objectForKey:@"id"];
		NSString *key = [customField objectForKey:@"key"];
		
		if(![key hasPrefix:@"_"]){
			
			//NSString *value = [customField objectForKey:@"value"];
			DDLogInfo(@"Añadiendo campo %@...", key);
			NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
			[dict setValue:key forKey:@"name"];
			[dict setValue:key forKey:@"key"];
			[dict setValue:@"" forKey:@"options"];
			[dict setValue:NSLocalizedString(@"TEXT", @"Text") forKey:@"type"];
			[dict setValue:self.blog forKey:@"blog"];
			
			if(self.blog!=nil){
				[self.blog newCustomFieldForBlog:dict];
			}else{
				DDLogInfo(@"Error: blog es nil");			
			}
			
		}
		
		
		
	}
	
}

/*
 Guarda el post utilizando Core Data.
 */
- (void)save {
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
        DDLogInfo(@"Unresolved Core Data Save error %@, %@", error, [error userInfo]);
        exit(-1);
    }
}

/*
 Borra un post utilizando Core Data.
 */
- (BOOL)removeWithError:(NSError **)error {
    [[self managedObjectContext] deleteObject:self];
    return YES;
}

- (void)autosave {
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        // We better not crash on autosave
        DDLogInfo(@"[Autosave] Unresolved Core Data Save error %@, %@", error, [error userInfo]);
    }
}


- (NSString *)categoriesText {
    return [[[self.categories valueForKey:@"categoryName"] allObjects] componentsJoinedByString:@", "];
}

- (void)setCategoriesFromNames:(NSArray *)categoryNames {
    [self.categories removeAllObjects];
	NSMutableSet *categories = nil;
	
    for (NSString *categoryName in categoryNames) {
        NSSet *results = [self.blog.categories filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"categoryName like %@", categoryName]];
        if (results && (results.count > 0)) {
			if(categories == nil) {
				categories = [NSMutableSet setWithSet:results];
			} else {
				[categories unionSet:results];
			}
		}
    }
	
	if (categories && (categories.count > 0)) {
		self.categories = categories;
	}
}

- (BOOL) addCustomFieldFromDictionary:(NSDictionary*) d{
	
	DDLogInfo(@"Se va a crear el cf local...");
	
	NSManagedObjectContext *context= [self managedObjectContext];
	
	DDLogInfo(@"Se va a crear la entidad...");
	
	//NSManagedObject* post =[NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:context];
	
	//[post setValuesForKeysWithDictionary:fields];
	NSError *error;
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"CustomField" inManagedObjectContext:context]];
	[request setPredicate:[NSPredicate predicateWithFormat:@"key=%@",[d objectForKey:@"key"]]];
	CustomField *cf;
	cf = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if(!cf){
		cf = [[CustomField alloc] initWithEntity:[NSEntityDescription entityForName:@"CustomField"
																	  inManagedObjectContext:context]
						   insertIntoManagedObjectContext:context];
	}
	
	[cf setValuesForKeysWithDictionary:d];
	
	if(![context save:&error]){
		NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
		return NO;
	}
	
    return YES;
}

/*
 Description.
 */
- (NSString*) description{
    
    return [NSString stringWithFormat:@"Post = %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@",self.title, self.author, self.dateCreated, self.tags, self.status, self.slug, self.permalink,self.postId,self.authorId,self.excerpt,self.moreTag];
}

@end
