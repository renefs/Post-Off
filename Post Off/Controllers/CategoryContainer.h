//
//  StateCategory.h
//  Post Off
//
//  Created by Rene Fernandez on 30/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Category.h"

@interface CategoryContainer : NSObject

    @property (nonatomic, retain) Category *category;
    @property (nonatomic) BOOL checkStatus;

- (id) initWithCategory:(Category*) cat andStatus:(BOOL) s;

- (NSString*) getCategoryName;
- (NSNumber*) getCategoryId;
- (NSNumber*) getParentId;

@end
