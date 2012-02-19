//
//  Blog.h
//  Post Off
//
//  Created by Rene Fernandez on 17/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "WordpressApi.h"
#import "EMKeychain.h"

@class Category, Post, CustomFieldTemplate;
@interface Blog : NSManagedObject

@property (nonatomic, retain) NSNumber *blogId;
@property (nonatomic, retain) NSNumber *localId;
@property (nonatomic, retain) NSNumber *isAdmin;
@property (nonatomic, retain) NSDate *lastPostsSync;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *blogName;
@property (nonatomic, retain) NSString *xmlrpc;

//relaciones
@property (nonatomic, retain) NSMutableSet *categories;
@property (nonatomic, retain) NSMutableSet *cFields;
@property (nonatomic, retain) NSMutableSet *posts;


+ (Blog *) createBlogFromDictionary:(NSDictionary*) blogInfo withContext:(NSManagedObjectContext *)c andPassWord:(NSString*) password;
+ (BOOL)blogExistsForURL:(NSString *)theURL withContext:(NSManagedObjectContext *)moc;


- (BOOL)syncCategoriesFromArray:(NSMutableArray *)categories;
- (Category*) findCategoryWithName:(NSString*) name;

- (void)saveData;

// Creates an empty local post associated with blog
- (Post*)newDraftForBlog:(NSMutableDictionary*) data andCustomFields:(NSMutableArray*) cf andCategories:(NSMutableArray*) c;
//- (void)newPostForBlog:(Blog *)blog;
- (BOOL)newCustomFieldForBlog:(NSDictionary*) fields;
- (BOOL)deleteCustomFields:(NSArray*) fields;
- (BOOL)deleteCategories:(NSArray*) cats;
- (BOOL)deletePosts:(NSArray*) posts;
- (BOOL) existsPostWithId:(NSNumber*) n;
- (BOOL)syncPostsFromArray:(NSMutableArray *)posts;

- (NSString*) password;
@end
