//
//  Category.h
//  Post Off
//
//  Created by Rene Fernandez on 17/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Blog;
@class WordpressApi;
@interface Category : NSManagedObject{
}

//atributos
@property (nonatomic, retain) NSNumber *categoryId;
@property (nonatomic, retain) NSString *categoryName;
@property (nonatomic, retain) NSNumber *parentId;


//relaciones
@property (nonatomic, retain) NSMutableSet *posts;
@property (nonatomic, retain) Blog *blog;

+ (BOOL)existsName:(NSString *)name forBlog:(Blog *)blog withParentId:(NSNumber *)parentId;
+ (Category *)findWithBlog:(Blog *)blog andCategoryId:(NSNumber *)categoryId;
// Takes the NSDictionary from a XMLRPC call and creates or updates a post
+ (Category *)createOrReplaceFromDictionary:(NSDictionary *)categoryInfo forBlog:(Blog *)blog;
+ (Category *)createCategoryWithError:(NSString *)name parent:(Category *)parent forBlog:(Blog *)blog error:(NSError **)error;
+ (Category *)newCategoryForBlog:(Blog *)blog;

@end
