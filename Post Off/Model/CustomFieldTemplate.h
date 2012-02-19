//
//  CustomFieldTemplate.h
//  Post Off
//
//  Created by René on 19/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Blog;
@interface CustomFieldTemplate : NSManagedObject

//atributos
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *options;
@property (nonatomic, retain) NSString *type;


//relaciones
@property (nonatomic, retain) Blog *blog;

@end
