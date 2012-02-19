//
//  CustomFieldTableDelegate.h
//  Post Off
//
//  Created by René on 16/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomField.h"
#import "Post.h"
#import "Blog.h"
#import "CustomTable.h"


@class NewArticleViewController;
@interface CustomFieldTableDelegate : NSObject<NSTableViewDelegate, NSTableViewDataSource,DeleteKeyDelegate, NSAlertDelegate>{
	IBOutlet CustomTable *cfTable;
}

@property (nonatomic, retain) Post *post;
@property (nonatomic, retain) Blog *blog;
@property (nonatomic, retain) NSMutableArray *customFields;
@property (nonatomic, retain) CustomTable *cfTable;
@property (nonatomic, retain) NewArticleViewController *viewController;

- (void) fetchPostCustomFields;
- (void) addCustomField:(CustomField*) c toPost:(Post*) p;


- (void) editCustomField;
- (void)editSelectedCustomField:(CustomField* ) field;
-(void) setViewController:(NewArticleViewController *)v;
@end
