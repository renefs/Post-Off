//
//  WordpressApi.h
//  Post Off
//
//  Created by Rene Fernandez on 29/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DateUtils.h"
#import "XMLRPC.h"
#import "XMLRPCDecoder.h"
#import "Category.h"

@class Post;
@interface WordpressApi : NSObject{

    //RequestManager *manager;
    NSString* user;
    NSString* password;
    NSString* blogId;
    NSString* url;

    
}

@property (nonatomic, retain) NSString *user;
@property (nonatomic, retain) NSString *blogId;
@property (nonatomic, retain) NSError *error;


- (WordpressApi*) initWithUser:(NSString*) u andPassword:(NSString*) p andUrl:(NSString*) u andBlogId:(NSString*) bid;
- (WordpressApi*) initWithUser:(NSString*) u andPassword:(NSString*) p andUrl:(NSString*) u;

- (id) sendSynchronousRequestWithMethod:(NSString*) me andParameters:(NSArray*) param;

/**wp.getUsersBlogs
Retrieve the blogs of the users.
 */
- (id) getUsersBlogs;
/**
 wp.getTags
 Get list of all tags.
 */
- (id) getTags;
/**
 wp.getAuthors
 Get an array of users for the blog.
  */
- (id) getAuthors;
/**
 wp.getOptions
 Retrieve blog options. If passing in a struct, search for options listed within it. This call return also settings available in the Media Settings area of wp-admin. For example: If a user has specified properties for Image Sizes such as Thumbnail Size, Medium Size, and Large Size, this call would return those propertie
  */
- (id) getOptionName:(NSString*) name;
- (id) getOptions;

/**
 wp.getPostStatusList
 Retrieve post statuses.
  */
//wp.getPostStatusList
- (id) getPostStatusList;
/**
 wp.getPostFormats
 Retrieves a list of post formats used by the site. A filter parameter could be provided that would allow the caller to filter the result. At this moment the only supported filter is 'show-supported' that enable the caller to retrieve post formats supported by the active theme.
  */
- (id) getPostFormats;

/**
 wp.getCategories
 Get an array of available categories on a blog.
  */
- (id) getCategories;
//wp.newCategory
/*- (NSArray*) newCategoryWithName:(NSString*) n;
//wp.deleteCategory
- (NSArray*) deleteCategory;

//metaWeblog.newPost (blogid, username, password, struct, publish) returns string
- (NSString*) newPostWithContent:(NSString*) c;
//metaWeblog.editPost (postid, username, password, struct, publish) returns true
- (BOOL) editPost;
//metaWeblog.getPost (postid, username, password) returns struct
- (NSArray*) getPost;*/

/**
 metaWeblog.getRecentPosts
 */
- (id) getPostWithId:(NSString*) postId;
- (id) editPostWithId:(NSString*) postId andPost:(Post*) post;

- (id) getRecentPosts:(int) numberOfPosts;
- (id) sayHello;

//wp.suggestCategories
//wp.uploadFile
//wp.getMediaLibrary
//wp.getMediaItem

- (void) printData: (NSArray*) data;
- (BOOL) isErrorResponse: (id) responseData;
- (id) addNewCategory: (Category*) c;

- (id) addNewPost: (Post*) p;
- (NSMutableDictionary *)getXMLRPCDictionaryForPost:(Post *)post;

@end
