//
//  PostContainer.m
//  Post Off
//
//  Created by Rene Fernandez on 30/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PostContainer.h"

@implementation PostContainer

@synthesize post,checkStatus;

- (id) initWithPost:(Post*) p andStatus:(BOOL) s{
    
    self = [super init];
    
    if(self){
        
        self.post=p;
        self.checkStatus=s;
    }
    
    return self;
    
}

- (NSString*) getTitle{
    return post.title;
}

- (NSString*) getAuthor{
    return post.author;
}

- (NSString*) getStatus{
    return post.status;
}

- (NSString*) getPostFormat{
    return post.postFormat;
}

- (NSDate*) getDateCreated{
    return post.dateCreated;
}

@end
