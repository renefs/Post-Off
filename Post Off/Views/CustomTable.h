//
//  CustomTable.h
//  Post Off
//
//  Created by René on 14/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface CustomTable : NSTableView  {
    NSNumber *selectedCellRowIndex;
    NSNumber *selectedCellColumnIndex;
    NSCell *customSelectedCell;
}

@property (nonatomic, retain) NSNumber *selectedCellRowIndex;
@property (nonatomic, retain) NSNumber *selectedCellColumnIndex;
@property (nonatomic, retain) NSCell *customSelectedCell;


@end

@protocol DeleteKeyDelegate
- ( void ) deleteKeyPressed: ( NSTableView * ) view onRow: ( int ) rowIndex;
@end