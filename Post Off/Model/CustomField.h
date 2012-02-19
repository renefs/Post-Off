//
//  CustomField.h
//  Post Off
//
//  Created by Rene Fernandez on 17/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Post;
@interface CustomField : NSManagedObject{
	
}

//atributos
@property (nonatomic, retain) NSNumber *cfId;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *value;


//relaciones
@property (nonatomic, retain) Post *post;

//- (id) initWithName:(NSString*) n andKey:(NSString*) k andOptions:(NSString*) o withType:(NSString*) type;

@end
