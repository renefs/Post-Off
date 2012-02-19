//
//  CustomTable.m
//  Post Off
//
//  Created by René on 14/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomTable.h"

@implementation CustomTable
@synthesize selectedCellRowIndex, selectedCellColumnIndex, customSelectedCell;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        selectedCellRowIndex = [[NSNumber alloc] initWithInt:1];
        selectedCellColumnIndex = [[NSNumber alloc] initWithInt:1];
        customSelectedCell = [[NSCell alloc] init];
    }
    
    return self;
}

-(void)mouseDown:(NSEvent *)theEvent {
    NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	// which column and cell has been hit?
	
	long column = [self columnAtPoint:p];
	long row = [self rowAtPoint:p];
    DDLogInfo(@"c: %d r: %d", column,row);
    
    /* The following lines can be used if you want to retrieve the selected cell instead of the row/column indices 
	 */
    if(column == -1 || row == -1) {
        [self setSelectedCellRowIndex:[NSNumber numberWithLong:row]];
        [self setSelectedCellColumnIndex:[NSNumber numberWithLong:column]];
    }
    else {
        NSTableColumn* theColumn = [[self tableColumns] objectAtIndex:column];
        NSCell *dataCell = [theColumn dataCellForRow:row];
        
        [self setSelectedCellRowIndex:[NSNumber numberWithLong:row]];
        [self setSelectedCellColumnIndex:[NSNumber numberWithLong:column]];	
        [self setCustomSelectedCell:dataCell];
    }
    [super mouseDown:theEvent];
}

- (void) keyDown:(NSEvent *) theEvent
{
    NSString * tString;
    unsigned int stringLength;
    unsigned int i;
    unichar tChar;
    id obj = [self delegate];
    
    tString= [theEvent characters];
    
    stringLength=(int)[tString length];
    
    DDLogInfo(@"Keydown!!");
    
    for(i=0;i<stringLength;i++)
    {
        tChar=[tString characterAtIndex:i];
        
        if (tChar==NSDeleteCharacter)
        {
            DDLogInfo(@"Delete Key!!!");
            
            if (([self selectedRow] < 0 || [self selectedRow] >= [self numberOfRows]) && !([obj respondsToSelector: @selector( deleteKeyPressed:onRow: )]))
                return;
            
            id <DeleteKeyDelegate> delegate = ( id <DeleteKeyDelegate> ) obj;
				
            [delegate deleteKeyPressed: self onRow: (int)[self selectedRow]];
            
            DDLogInfo(@"Deleting item: %d", [self selectedRow]);
            //NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:[self selectedRow]];
            
            //[self dataSource] 
            
            [self reloadData];
            
            return;
        }
    }
    
    [super keyDown:theEvent];
}


@end
