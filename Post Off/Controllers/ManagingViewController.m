//
//  ManagingViewController.m
//  Post Off
//
//  Created by René on 22/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ManagingViewController.h"

@implementation ManagingViewController
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void) dealloc{
	[managedObjectContext dealloc];
	[super dealloc];
	
}

@end
