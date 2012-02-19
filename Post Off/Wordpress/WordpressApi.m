//
//  WordpressApi.m
//  Post Off
//
//  Created by Rene Fernandez on 29/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WordpressApi.h"
#import "Post.h"

@implementation WordpressApi

@synthesize user, blogId;
@synthesize error;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (WordpressApi*) initWithUser:(NSString*) us andPassword:(NSString*) p andUrl:(NSString *)ur andBlogId:(NSString*) bid{
    
    self = [super init];
    if (self) {
        self->user=us;
        self->password=p;
        self->url=ur;
		self->blogId=bid;
    }
    
    return self;
    
}

- (WordpressApi*) initWithUser:(NSString*) us andPassword:(NSString*) p andUrl:(NSString *)ur{
    
    self = [super init];
    if (self) {
        self->user=us;
        self->password=p;
        self->url=ur;
    }
    
    return self;
    
}

- (id) sendSynchronousRequestWithMethod:(NSString*) me andParameters:(NSArray*) param{
	
	XMLRPCResponse *myResponse;
	id returnedData=nil;
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	
	//NSArray* param = [NSArray arrayWithObjects:self->user,self->password, nil];
	
	NSURL *URL = [NSURL URLWithString: self->url];
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: URL];
	
	if(param!=nil){
		[request setMethod:me withParameters:param];
	}else{
		DDLogWarn(@"Error on requestParameters.");		
	}
	
	myResponse=[XMLRPCConnection sendSynchronousXMLRPCRequest:request error:&error];
	
	[request release];
	
	if(error){
		[alert setMessageText: @"The XML-RPC response returned a fault."];
	}
	
	//DDLogInfo(@"Cuerpo de la respuesta: %@", [myResponse body]);
	
	if ([[myResponse body] rangeOfString:@"<!DOCTYPE"].location != NSNotFound){
		
		return nil;
		
	}
	
	//Preparing response data to be parsed. Parser should receive a NSData
	NSData* contenidoXMLData = [[myResponse body] dataUsingEncoding:NSUTF8StringEncoding];
	
	XMLRPCDecoder *decoder = [[XMLRPCDecoder alloc] initWithData: contenidoXMLData];
	
	returnedData=[decoder decode];
	
	//[myResponse release];
	
	return returnedData;
}

-(BOOL) isErrorResponse: (id) responseData{
	
	DDLogInfo(@"El objeto recibido es: %@", [responseData class]);
	
	NSDictionary *a = responseData;
	
	if([a isKindOfClass:[NSDictionary class]]){
		
		id value= [a objectForKey:@"faultCode"];
		
		if(value!=nil){
			
			NSString* errorMessage=[a objectForKey:@"faultString"];
			
			DDLogInfo(@"Error: %@ (%@)",value, errorMessage);
			
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:errorMessage forKey:NSLocalizedDescriptionKey];
			error = [NSError errorWithDomain:@"com.kyr.post-off" code:(int)value userInfo:errorDetail];
			
			return YES;
		}
		
	}
	
	return NO;
}

- (id) getUsersBlogs{
    
    id data=nil;
    
    data= [self sendSynchronousRequestWithMethod:@"wp.getUsersBlogs" andParameters:[NSArray arrayWithObjects:self->user,self->password, nil]];	
    [self printData:data];	
	
	if([self isErrorResponse:data]){
		return error;
	}
    
	return data;
}

- (id) getTags{
    
    NSArray* data=nil;
    
    data= [self sendSynchronousRequestWithMethod:@"wp.getTags" andParameters:[NSArray arrayWithObjects:self->user,self->password, nil]];
	
    [self printData:data];
	
	if([self isErrorResponse:data]){
		return error;
	}
    
	return data;
}

- (id) getAuthors{
    
    id data=nil;
    
    data= [self sendSynchronousRequestWithMethod:@"wp.getAuthors" andParameters:[NSArray arrayWithObjects:self->user,self->password, nil]];
	
    [self printData:data];
	
	if([self isErrorResponse:data]){
		return error;
	}
    
	return data;
}

- (id) getOptionName:(NSString *)name{
    
    id data=nil;
    
	NSDictionary *myActions = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"software_name",@"2",@"software_version",@"3",@"blog_url",@"4",@"time_zone",@"5",@"blog_title",@"6",@"blog_tagline",@"7",@"date_format",@"8",@"time_format",@"9",@"users_can_register",@"10",@"thumbnail_size_w",@"11",@"thumbnail_size_h",@"12",@"thumbnail_crop",@"13",@"medium_size_w",@"14",@"medium_size_h",@"15",@"large_size_w",@"16",@"large_size_h", nil];
	
	int switchCode = [[myActions objectForKey: name] intValue];
	DDLogInfo(@"switch_code= %d", switchCode);
	
	NSMutableDictionary *errorDetail;
	errorDetail = [NSMutableDictionary dictionary];
	[errorDetail setValue:@"La opción seleccionada es errónea" forKey:NSLocalizedDescriptionKey];
	error = [NSError errorWithDomain:@"wordpressApi" code:001 userInfo:errorDetail];
	
	switch (switchCode) {
		case 1:
		case 2:
		case 3:
		case 4:
		case 5:
		case 6:
		case 7:
		case 8:
		case 9:
		case 10:
		case 11:
		case 12:
		case 13:
		case 14:
		case 15:
		case 16:

			data= [self sendSynchronousRequestWithMethod:@"wp.getAuthors" andParameters:[NSArray arrayWithObjects:self->blogId,self->user,self->password, name, nil]];
			break;
			
		default:
			[NSApp presentError:error];
			break;
	}
	
	[self printData:data];
	
	if([self isErrorResponse:data]){
		return error;
	}
    
	return data;
}

- (id) getOptions{
    
    id data=nil;
    
	data= [self sendSynchronousRequestWithMethod:@"wp.getOptions" andParameters:[NSArray arrayWithObjects:self->blogId,self->user,self->password, nil]];
	
	[self printData:data];
	
	if([self isErrorResponse:data]){
		return error;
	}
    
	return data;
}

- (id) getPostStatusList{
	id data=nil;
    
	data= [self sendSynchronousRequestWithMethod:@"wp.getPostStatusList" andParameters:[NSArray arrayWithObjects:self->blogId,self->user,self->password, nil]];
	
	[self printData:data];
	
	if([self isErrorResponse:data]){
		return error;
	}
    
	return data;
}

- (id) getPostFormats{
	id data=nil;
    
    data= [self sendSynchronousRequestWithMethod:@"wp.getPostFormats" andParameters:[NSArray arrayWithObjects:self->blogId,self->user,self->password, nil]];
	
	[self printData:data];
	
	if([self isErrorResponse:data]){
		return error;
	}
    
	return data;
}

- (id) getCategories{
	id data=nil;
    
	data= [self sendSynchronousRequestWithMethod:@"wp.getCategories" andParameters:[NSArray arrayWithObjects:self->blogId,self->user,self->password, nil]];
	
	[self printData:data];
	
	if([self isErrorResponse:data]){
		return error;
	}
    
	return data;
}

- (id) getRecentPosts:(int) numberOfPosts{
	
	id data=nil;
    
    data= [self sendSynchronousRequestWithMethod:@"metaWeblog.getRecentPosts" andParameters:[NSArray arrayWithObjects:self->blogId, self->user,self->password, [[[NSString alloc] initWithFormat:@"%d",numberOfPosts] autorelease], nil]];
	
	[self printData:data];
	
	if([self isErrorResponse:data]){
		return error;
	}
    
	return data;
	
}




- (void) printData: (NSArray*) data{
	
	DDLogInfo(@"Se imprimen los datos(WordpressApi):");
    if(data!=nil){
		
		DDLogInfo(@"%@", [data description]);
		

    }else{DDLogWarn(@"Los datos devueltos son nil");}
}

- (id) addNewCategory: (Category*) c{
	
	id data=nil;
	
	NSMutableDictionary *categoryDict = [NSMutableDictionary dictionary];
	
	[categoryDict setObject: c.categoryName forKey: @"name"];
	
	if(c.parentId!=nil)
		[categoryDict setObject: c.categoryName forKey: @"parent_id"];
    
    
    data = [self sendSynchronousRequestWithMethod:@"wp.newCategory" andParameters:[NSArray arrayWithObjects:self->blogId,self->user,self->password, categoryDict, nil]];
	
	[self printData:data];
	
	if([self isErrorResponse:data]){
		return error;
	}
	
	return data;
	
}

- (NSMutableDictionary *)getXMLRPCDictionaryForPost:(Post *)post {
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    if (post.title != nil)
        [postParams setObject:post.title forKey:@"title"];
    if (post.content != nil)
        [postParams setObject:post.content forKey:@"description"];
    if ([post isKindOfClass:[Post class]]) {
        if ([post valueForKey:@"tags"] != nil)
            [postParams setObject:[post valueForKey:@"tags"] forKey:@"mt_keywords"];
        if ([post valueForKey:@"categories"] != nil) {
            NSMutableSet *categories = [post mutableSetValueForKey:@"categories"];
            NSMutableArray *categoryNames = [NSMutableArray arrayWithCapacity:[categories count]];
            for (Category *cat in categories) {
                [categoryNames addObject:cat.categoryName];
            }
            [postParams setObject:categoryNames forKey:@"categories"];
        }

		NSMutableArray *customFields = [NSMutableArray array];
		
		for(CustomField *cf in post.cFields){
			
			NSMutableDictionary *cfDict= [[NSMutableDictionary alloc] init];			
			[cfDict setValue:cf.value forKey:@"value"];
			[cfDict setValue:cf.key forKey:@"key"];
			
			if(cf.cfId!=nil && [cf.cfId intValue] !=0){
				[cfDict setValue:cf.cfId forKey:@"id"];
			}
			
			[customFields addObject:cfDict];
			[cfDict release];
		}
		
		if ([customFields count] > 0) {
			DDLogInfo(@"El post tiene custom fields: %@", customFields);
			[postParams setObject:customFields forKey:@"custom_fields"];
		}
    }
	
    if (post.status != nil)
		[postParams setObject:post.status forKey:@"post_status"];
    
	if (post.dateCreated != nil) {
        post.dateCreated = [DateUtils localDateToGMTDate:[NSDate date]];
    }
	[postParams setObject:post.dateCreated forKey:@"date_created_gmt"];
	
    if (post.password != nil)
        [postParams setObject:post.password forKey:@"wp_password"];
	
	if (post.permalink != nil)
        [postParams setObject:post.permalink forKey:@"permaLink"];
	
	if (post.excerpt != nil)
        [postParams setObject:post.excerpt forKey:@"mt_excerpt"];
	
	if (post.moreTag != nil && [post.moreTag length] > 0)
        [postParams setObject:post.moreTag forKey:@"mt_text_more"];
	
	if (post.slug != nil)
        [postParams setObject:post.slug forKey:@"wp_slug"];
	
    return postParams;
}

- (id) addNewPost:(Post *)post{
	
	id data=nil;
	
	NSMutableDictionary *postParams = [self getXMLRPCDictionaryForPost:post];
    
    //manager = [[RequestManager alloc] initWithMethod:@"metaWeblog.getRecentPosts" andParametersArray:[NSArray arrayWithObjects:@"1", self->user,self->password, nil] andURL:self->url];
    
    data = [self sendSynchronousRequestWithMethod:@"metaWeblog.newPost" andParameters:[NSArray arrayWithObjects:self->blogId,self->user,self->password, postParams, nil]];
	
	[self printData:data];
	
	if([self isErrorResponse:data]){
		return error;
	}
	
	return data;
	
}

- (id) editPostWithId:(NSString*) postId andPost:(Post*) post{
	
	id data=nil;
	
	NSMutableDictionary *postParams = [self getXMLRPCDictionaryForPost:post];
    
    //manager = [[RequestManager alloc] initWithMethod:@"metaWeblog.getRecentPosts" andParametersArray:[NSArray arrayWithObjects:@"1", self->user,self->password, nil] andURL:self->url];
    
    data = [self sendSynchronousRequestWithMethod:@"metaWeblog.editPost" andParameters:[NSArray arrayWithObjects:postId,self->user,self->password, postParams, nil]];
	
	[self printData:data];
	
	if([self isErrorResponse:data]){
		return error;
	}
	
	return data;
	
}

- (id) getPostWithId:(NSString*) postId{
	
	id data=nil;
	
	//NSMutableDictionary *postParams = [self getXMLRPCDictionaryForPost:post];
    
    //manager = [[RequestManager alloc] initWithMethod:@"metaWeblog.getRecentPosts" andParametersArray:[NSArray arrayWithObjects:@"1", self->user,self->password, nil] andURL:self->url];
    
    data = [self sendSynchronousRequestWithMethod:@"metaWeblog.getPost" andParameters:[NSArray arrayWithObjects:postId,self->user,self->password, nil]];
	
	[self printData:data];
	
	if([self isErrorResponse:data]){
		return error;
	}
	
	return data;
	
}

- (id) sayHello{
	
	id data=nil;

    data = [self sendSynchronousRequestWithMethod:@"demo.sayHello" andParameters:[NSArray arrayWithObjects:self->user,self->password, nil]];
	
	[self printData:data];
	
	if([self isErrorResponse:data]){
		return error;
	}
	
	return data;
	
}

- (void) dealloc{
	//[myResponse release];
	[super dealloc];
}

@end
