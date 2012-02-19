//
//  Category.m
//  Post Off
//
//  Created by Rene Fernandez on 17/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Category.h"
#import "Blog.h"
#import "WordpressApi.h"
@implementation Category


@dynamic categoryId, categoryName, parentId, posts;
@dynamic blog;

/*
 Comprueba si una categoría ya existe en el blog parámetro.
 */
+ (BOOL)existsName:(NSString *)name forBlog:(Blog *)blog withParentId:(NSNumber *)parentId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(categoryName like %@) AND (parentID = %@)", 
                              name,
                              (parentId ? parentId : [NSNumber numberWithInt:0])];
    NSSet *items = [blog.categories filteredSetUsingPredicate:predicate];
    if ((items != nil) && (items.count > 0)) {
        // Already exists
        return YES;
    } else {
        return NO;
    }
	
}

/*
 Busca el ID de una categoría para ver si existe en el blog parámetro.
 Si existe, devuelve la categoría.
 Si no existe, devuelve nil.
 */
+ (Category *)findWithBlog:(Blog *)blog andCategoryId:(NSNumber *)categoryId {
    NSSet *results = [blog.categories filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"categoryId == %@",categoryId]];
    
    if (results && (results.count > 0)) {
        return [[results allObjects] objectAtIndex:0];
    }
    return nil;    
}

/*
 Crea o sustituye una categoría basándose en los datos del diccionario parámetro.
 Si no existe, la crea.
 Si ya existe, sustituye sus atributos.
 */
+ (Category *)createOrReplaceFromDictionary:(NSDictionary *)categoryInfo forBlog:(Blog *)blog {
    
	//Si no hay "Id" ni "Name", es que los datos son erróneos.
	if ([categoryInfo objectForKey:@"categoryId"] == nil) {
        return nil;
    }
    if ([categoryInfo objectForKey:@"categoryName"] == nil) {
        return nil;
    }
	
    Category *category = [self findWithBlog:blog andCategoryId:[categoryInfo objectForKey:@"categoryId"]];
    
	//Si la cateogría no existe, se crea.
    if (category == nil) {
        category = [[Category newCategoryForBlog:blog] autorelease];
    }
    
	//Se establecen los atributos de la categoría.
    category.categoryId     = [NSNumber numberWithInt:[[categoryInfo objectForKey:@"categoryId"] intValue]];
    category.categoryName   = [categoryInfo objectForKey:@"categoryName"];
    category.parentId       = [NSNumber numberWithInt:[[categoryInfo objectForKey:@"parentId"] intValue]];
    
    return category;
}

/*
 Añade una categoría al blog parámetro.
 */
+ (Category *)newCategoryForBlog:(Blog *)blog {
    Category *category = [[Category alloc] initWithEntity:[NSEntityDescription entityForName:@"Category"
																	  inManagedObjectContext:[blog managedObjectContext]]
						   insertIntoManagedObjectContext:[blog managedObjectContext]];
    
    category.blog = blog;
    
    return category;
}

+ (Category *)createCategoryWithError:(NSString *)name parent:(Category *)parent forBlog:(Blog *)blog error:(NSError **)error{
    /*Category *category = [Category newCategoryForBlog:blog];
	WordpressApi *api = [[WordpressApi alloc] init];
    category.categoryName = name;
	if (parent.categoryId != nil)
		category.parentId = parent.categoryId;
    int newId = [api addNewCategory:category];
	if(api.error) {
		if (error != nil) 
			*error = api.error;
		DDLogInfo(@"Error while creating category: %@", [api.error localizedDescription]);
	}
    if (newId > 0 && !api.error) {
        category.categoryId = [NSNumber numberWithInt:newId];
        [blog dataSave]; // Commit core data changes
		[api release];
        return [category autorelease];
    } else {
        // Just in case another thread has saved while we were creating
        [[blog managedObjectContext] deleteObject:category];
		[blog dataSave]; // Commit core data changes
        [category release];
		[api release];
        return nil;
    }*/
    return nil;
}

/*
 Description.
 */
- (NSString*) description{
    
    NSNumber *pCatId= self.categoryId;
    NSString *pCatName= self.categoryName;
    NSNumber *pParentId= self.parentId;
    
    NSString *myString = [NSString stringWithFormat:@"Category = %@, %@, %@",pCatId, pCatName, pParentId];
    
    return myString;
}


@end
