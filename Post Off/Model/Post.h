//
//  Post.h
//  Post Off
//
//  Created by Rene Fernandez on 17/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Blog.h"
#import "CustomField.h"


@interface Post : NSManagedObject

@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSNumber *authorId;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSDate *dateCreated;
@property (nonatomic, retain) NSString *excerpt;
@property (nonatomic, retain) NSString *moreTag;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *permalink;
@property (nonatomic, retain) NSNumber *postId;
@property (nonatomic, retain) NSString *slug;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *tags;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *postFormat;
@property (nonatomic, retain) NSNumber *localId;

//relaciones
@property (nonatomic, retain) Blog *blog;
@property (nonatomic, retain) NSMutableSet *categories;
@property (nonatomic, retain) NSMutableSet *cFields;





#pragma mark -
#pragma mark Methods
#pragma mark     Helpers

+ (Post *)findWithBlog:(Blog *)blog andPostId:(NSNumber *)postId;
// Takes the NSDictionary from a XMLRPC call and creates or updates a post
//+ (Post *)createOrReplaceFromDictionary:(NSDictionary *)postInfo forBlog:(Blog *)blog;

// Returns categories as a comma-separated list
- (NSString *)categoriesText;
- (void)setCategoriesFromNames:(NSArray *)categoryNames;

- (void)save;

#pragma mark     Data Management
// Autosave for local drafts
- (void)autosave;
// Upload a new post to the server
//- (void)upload;
//update the post using values retrieved the server
- (void )updateFromDictionary:(NSDictionary *)postInfo;

- (BOOL)removeWithError:(NSError **)error;

- (BOOL) addCustomFieldFromDictionary:(NSDictionary*) d;
- (void) addPostCustomFieldTemplates:(NSMutableArray*) customFields;
- (void) addCustomFieldsFromArray:(NSMutableArray*) customFields;
@end
