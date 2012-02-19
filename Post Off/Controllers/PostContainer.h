//
//  PostContainer.h
//  Post Off
//
//  Created by Rene Fernandez on 30/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"

@interface PostContainer : NSObject

@property (nonatomic, retain) Post *post;
@property (nonatomic) BOOL checkStatus;

- (id) initWithPost:(Post*) cat andStatus:(BOOL) s;

- (NSString*) getTitle;

- (NSString*) getAuthor;

- (NSString*) getStatus;

- (NSString*) getPostFormat;

- (NSDate*) getDateCreated;

@end
