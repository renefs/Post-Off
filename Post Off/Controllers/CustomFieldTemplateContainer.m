//
//  CustomFieldTemplateContainer.m
//  Post Off
//
//  Created by Rene Fernandez on 30/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomFieldTemplateContainer.h"

@implementation CustomFieldTemplateContainer

@synthesize cf,checkStatus;


- (id) initWithCFTemplate:(CustomFieldTemplate*) c andStatus:(BOOL) s{
    
    self = [super init];
    
    if(self){
        
        self.cf=c;
        self.checkStatus=s;
    }
    
    return self;
    
}

- (NSString*) getKey{
    return cf.key;
}

- (NSString*) getName{
    return cf.name;
}

- (NSString*) getOptions{
    return cf.options;
}

- (NSString*) getType{
    return cf.type;
}

@end
