//
//  Blog.m
//  Post Off
//
//  Created by Rene Fernandez on 17/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Blog.h"
#import "Category.h"
#import "Post.h"
#import "CustomFieldTemplate.h"

@implementation Blog

@dynamic blogId,isAdmin,lastPostsSync,password,url,userName,xmlrpc, blogName, localId;
@dynamic categories,cFields,posts;
/*
 Comprueba si un blog ya existe en CD comparando la url parámetro con alguna de las existentes. 
 */
+ (BOOL)blogExistsForURL:(NSString *)theURL withContext:(NSManagedObjectContext *)moc {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Blog"
                                        inManagedObjectContext:moc]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"url like %@", theURL]];
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release]; fetchRequest = nil;
    
    return (results.count > 0);
}

/*
 Crea un blog desde los datos pasados en el diccionario parámetro con unos datos Core Data determinados.
 */
+ (Blog *) createBlogFromDictionary:(NSDictionary*) blogInfo withContext:(NSManagedObjectContext *)c andPassWord:(NSString*) password{
    
    Blog *blog = nil;
    /*NSString *blogUrl = [[dict objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"http://" withString:@""];
	if([blogUrl hasSuffix:@"/"])
		blogUrl = [blogUrl substringToIndex:blogUrl.length-1];
	blogUrl= [blogUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];*/
    
	
    NSString *blogUrl = [blogInfo objectForKey:@"url"];
    
	//Se comprueba que no exista ya un blog para la URL obtenida.
	//Si no existe se crea una nueva entidad blog de CD.
	//Si existe se actualizan sus datos.
    if (![self blogExistsForURL:blogUrl withContext:c]) {
        blog = [[[Blog alloc] initWithEntity:[NSEntityDescription entityForName:@"Blog"
                                                         inManagedObjectContext:c]
              insertIntoManagedObjectContext:c] autorelease];
        
        blog.url = blogUrl;
        blog.blogId = [NSNumber numberWithInt:[[blogInfo objectForKey:@"blogid"] intValue]];
        

        
        blog.blogName = [blogInfo objectForKey:@"blogName"];
		blog.xmlrpc = [blogInfo objectForKey:@"xmlrpc"];
        blog.userName = [blogInfo objectForKey:@"username"];
        blog.password = [blogInfo objectForKey:@"password"];
        blog.isAdmin = [NSNumber numberWithInt:[[blogInfo objectForKey:@"isAdmin"] intValue]];
        
		//El password se guarda en el llavero. Si el código no está firmado, saldrá un "pop up" preguntando al usuario si desea modificar el llavero".
        NSString *pass = [[EMGenericKeychainItem genericKeychainItemForService:@"com.kyr.post-off" withUsername:[blogInfo objectForKey:@"username"] ] password];
		if(!pass){
			DDLogInfo(@"El pass será: %@", password);
			[EMGenericKeychainItem addGenericKeychainItemForService:@"com.kyr.post-off" withUsername:[blogInfo objectForKey:@"username"] password:password];
		}else{			
			
			[EMGenericKeychainItem setKeychainPassword:password forUsername:[blogInfo objectForKey:@"username"] service:@"com.kyr.post-off"];
		}

	}
    return blog;
    
}

- (NSString*) password{
	
	NSString* p = [[EMGenericKeychainItem genericKeychainItemForService:@"com.kyr.post-off" withUsername:self.userName ] password];
	
	return p;
}

/*
 Sincroniza las categorías locales y las del servidor desde un array pasado por parámetro (obtenido mediante XML-RPC).
 */
- (BOOL)syncCategoriesFromArray:(NSMutableArray *)categories {
	
	
	//Añade las categorías a un array que almacenará todas las categorías que se mantendrán.
	//Si no existen se crearán, y si existen se actualizarán.
	NSMutableArray *categoriesToKeep = [NSMutableArray array];
    for (NSDictionary *categoryInfo in categories) {
		[categoriesToKeep addObject:[Category createOrReplaceFromDictionary:categoryInfo forBlog:self]];
    }
	
	//Se obtienen las actuales categorías del blog y se van recorriendo las anteriormente obtenidas.
	//Si en categoriesToKeep no existe la categoría local, entonces se borra. (Se dejan solo las del server).
	NSSet *syncedCategories = self.categories;
	if (syncedCategories && (syncedCategories.count > 0)) {
		for (Category *cat in syncedCategories) {
			if(![categoriesToKeep containsObject:cat]) {
				DDLogInfo(@"Deleting Category: %@", cat);
				[[self managedObjectContext] deleteObject:cat];
			}
		}
    }
	
    [self saveData];
	
    return YES;
}

- (Category*) findCategoryWithName:(NSString*) name{
	
	for(Category *c in self.categories){
		
		if([c.categoryName isEqualToString:name]){
			return c;
		}
		
	}
	
	return nil;
	
}

- (BOOL) existsPostWithId:(NSNumber*) n{
	
	for (Post *p in self.posts) {
		if([p.postId intValue] == [n intValue]){
			return YES;
		}
	}
	
	return NO;
}

- (BOOL)syncPostsFromArray:(NSMutableArray *)posts {
    if ([posts count] == 0)
        return NO;
	DDLogInfo(@"Sincronizando posts...");
	//Se obtienen los posts con sus categorías.
	//NSMutableArray *postsToKeep = [NSMutableArray array];
    for (NSMutableDictionary *postInfo in posts) {
		DDLogInfo(@"Obteniendo post...");
		//NSMutableArray *postCategories = [[NSMutableArray alloc] init];
		DDLogInfo(@"Obteniendo categorías del post...");
		/*if ([postInfo objectForKey:@"categories"]) {
			
			NSMutableArray *categories = [postInfo objectForKey:@"categories"];
			
			for (NSString *categoryName in categories) {
				DDLogInfo(@"Obteniendo nombre de la categoría...");
				
				[postCategories addObject:[self findCategoryWithName:categoryName]];
				//[categoriesToKeep addObject:[Category createOrReplaceFromDictionary:categoryInfo forBlog:self]];
			}
			
		}*/
		DDLogInfo(@"Añadiendo el post a la lista temporal...");
		
		if(![self existsPostWithId:[postInfo objectForKey:@"postid"]]){
			Post *p = [[Post alloc] initWithEntity:[NSEntityDescription entityForName:@"Post"
																  inManagedObjectContext:self.managedObjectContext ]
					   insertIntoManagedObjectContext:self.managedObjectContext];
			p.blog=self;
			[p updateFromDictionary:postInfo];
			[self.posts addObject:p];
			//[postsToKeep addObject:p];
		}
		//[postCategories release];
    }
	
	//Se añaden los posts que no están ya en la aplicación.
	
	/*for(Post *p in postsToKeep){
		
		if(![self existsPostWithId:p.postId]){
			DDLogInfo(@"El post no existe: se añade.");
			[self.posts addObject:p];
		}
		
	}*/
	
	//for(Post *p in)
	
    [self saveData];

    return YES;
}

/*
 Salvar los datos en Core Data.
 */
- (void)saveData{
	NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        DDLogInfo(@"Unresolved Core Data Save error %@, %@", error, [error userInfo]);
        exit(-1);
    }
}

/*
 Crea un nuevo borrador.
 */
- (Post*)newDraftForBlog:(NSMutableDictionary*) data andCustomFields:(NSMutableArray*) cf andCategories:(NSMutableArray*) c{
	DDLogInfo(@"Se va a crear el post local...");
	
	NSManagedObjectContext *context= [self managedObjectContext];
	
	DDLogInfo(@"Se va a crear la entidad...");
	
	//NSManagedObject* post =[NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:context];
	Post *post=nil;
	//[post setValuesForKeysWithDictionary:fields];
	NSError *error;
	
	//post=[[self managedObjectContext] existingObjectWithID:[data objectForKey:@"objectID"] error:&error];
	if([data objectForKey:@"objectID"]!=nil){
		DDLogInfo(@"objectID: %@ ", [data objectForKey:@"objectID"]);
		post=(Post *)[[self managedObjectContext] objectWithID:[data objectForKey:@"objectID"]];
	}

	if(post==nil){
		//DDLogInfo(@"No se encuentra post con objectID %@...", [data objectForKey:@"objectID"]);
		post = [[Post alloc] initWithEntity:[NSEntityDescription entityForName:@"Post"
                                                          inManagedObjectContext:context]
               insertIntoManagedObjectContext:context];
		
	}
	if([data objectForKey:@"objectID"] != nil)
		[data removeObjectForKey:@"objectID"];
	[post setValuesForKeysWithDictionary:data];
    [post.categories removeAllObjects];
	if(c!=nil){
		DDLogInfo(@"Se van a añadir las categoías...");
		[post.categories addObjectsFromArray:c];
	}
	
	if(cf!=nil){
		DDLogInfo(@"Se van a añadir los campos personalizados...");
		[post.cFields removeAllObjects];
		[post.cFields addObjectsFromArray:cf];
	}
	
    //Post *post = [[Post alloc] initWithEntity:[NSEntityDescription entityForName:@"Post" inManagedObjectContext:[[NSApp delegate] managedObjectContext]] insertIntoManagedObjectContext:[[NSApp delegate] managedObjectContext]];
    
    /*post.blog = self;
	
	post.status = @"publish";
    [post save];
    */
	DDLogInfo(@"Guardando...");
	if(![context save:&error]){
		DDLogInfo(@"Whoops, couldn't save: %@", [error localizedDescription]);
		return nil;
	}
	DDLogInfo(@"Guardado...");
    return post;
}

- (BOOL)newCustomFieldForBlog:(NSDictionary*) fields{
	DDLogInfo(@"Se va a crear el cf local...");
	
	NSManagedObjectContext *context= [self managedObjectContext];
	
	DDLogInfo(@"Se va a crear la entidad...");
	
	//NSManagedObject* post =[NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:context];
	
	//[post setValuesForKeysWithDictionary:fields];
	CustomFieldTemplate *cf;
	NSError *error;
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"CustomFieldTemplate" inManagedObjectContext:context]];
	[request setPredicate:[NSPredicate predicateWithFormat:@"key=%@",[fields objectForKey:@"key"]]];
	
	cf = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if(!cf){
		DDLogInfo(@"L entidad no existe: se crea...");
		cf = [[CustomFieldTemplate alloc] initWithEntity:[NSEntityDescription entityForName:@"CustomFieldTemplate"
                                                          inManagedObjectContext:context]
               insertIntoManagedObjectContext:context];
	}
	
	DDLogInfo(@"Se le añaden los campos a la entidad...");
	[cf setValuesForKeysWithDictionary:fields];
	
    //Post *post = [[Post alloc] initWithEntity:[NSEntityDescription entityForName:@"Post" inManagedObjectContext:[[NSApp delegate] managedObjectContext]] insertIntoManagedObjectContext:[[NSApp delegate] managedObjectContext]];
    
    /*post.blog = self;
	 
	 post.status = @"publish";
	 [post save];
	 */
	DDLogInfo(@"Se guarda la entidad...");
	if(![context save:&error]){
		DDLogInfo(@"Whoops, couldn't save: %@", [error localizedDescription]);
		return NO;
	}
	
    return YES;
}

/*
 Description.
 */
- (NSString*) description{
    
    NSString *pUser= self.userName;
    NSString *pPass= self.password;
    NSString *pUrl= self.url;
    NSNumber *pBid= self.blogId;
    
    NSString *myString = [NSString stringWithFormat:@"Blog = %@, %@, %@, %@",pUser, pPass, pUrl, pBid];
    
    return myString;
}

- (BOOL)deleteCustomFields:(NSArray*) fields{
	
	NSManagedObjectContext *context= [self managedObjectContext];
	
	for(NSManagedObject *m in fields){
		[context deleteObject:m];
	}
	
	[self saveData];
	
	return YES;
}

- (BOOL)deleteCategories:(NSArray*) cats{
	
	NSManagedObjectContext *context= [self managedObjectContext];
	
	for(NSManagedObject *m in cats){
		[context deleteObject:m];
	}
	
	[self saveData];
	
	return YES;
	
}

- (BOOL)deletePosts:(NSArray*) posts{
    NSManagedObjectContext *context= [self managedObjectContext];
	
	for(NSManagedObject *m in posts){
		[context deleteObject:m];
	}
	
	[self saveData];
    
    return YES;
}
@end
