//
//  UserDefaults.h
//  Post Off
//
//  Created by Rene Fernandez on 17/11/11.
//  Copyright (c) 2011 KYR Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kyrIsFirstLaunch;
extern NSString* const kyrNumberOfPostsToSync;
//extern NSString* const kyrBlogAutoId;
//extern NSString* const kyrPostAutoId;
extern NSString* const kyrSyncCategoriesOnStart;

@interface UserDefaultsHelper: NSObject{}

+ (id) getUserValueForKey:(NSString*)aKey withDefault:(NSString*)aDefaultValue;
+ (void) setUserBooleanValue: (BOOL) aValue forKey:(NSString*) aKey;
+ (void) setUserStringValue: (NSString*) aValue forKey:(NSString*) aKey;



@end
