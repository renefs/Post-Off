//
//  StateCategory.m
//  Post Off
//
//  Created by Rene Fernandez on 30/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CategoryContainer.h"

@implementation CategoryContainer

@synthesize category,checkStatus;

- (id) initWithCategory:(Category*) cat andStatus:(BOOL) s{
    
    self = [super init];
    
    if(self){
        
        self.category=cat;
        self.checkStatus=s;
    }
    
    return self;
    
}

- (NSString*) getCategoryName{
    return category.categoryName;
}

- (NSNumber*) getCategoryId{
    return category.categoryId;
}

- (NSNumber*) getParentId{
    return category.parentId;
}

@end
