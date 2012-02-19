//
//  Post_OffTests.m
//  Post OffTests
//
//  Created by René on 21/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Post_OffTests.h"

@implementation Post_OffTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    NSLog(@"Se ejecutan los tests!");
	NSString *string1 = @"test";
    NSString *string2 = @"test";
    STAssertEquals(string1, string2, @"FAILURE");
    NSUInteger uint_1 = 4;
    NSUInteger uint_2 = 4;
    STAssertEquals(uint_1, uint_2, @"FAILURE");
}

@end
