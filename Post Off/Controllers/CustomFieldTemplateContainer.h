//
//  CustomFieldTemplateContainer.h
//  Post Off
//
//  Created by Rene Fernandez on 30/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomFieldTemplate.h"

@interface CustomFieldTemplateContainer : NSObject{
    
}

@property (nonatomic, retain) CustomFieldTemplate *cf;
@property (nonatomic) BOOL checkStatus;


- (id) initWithCFTemplate:(CustomFieldTemplate*) c andStatus:(BOOL) s;

- (NSString*) getKey;
- (NSString*) getName;
- (NSString*) getOptions;
- (NSString*) getType;

@end
