//
//  MainWindowController.m
//  Post Off
//
//  Created by René on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MainWindowController.h"
#import "SidebarTableCellView.h"
#import "PreferencesWindowController.h"

@implementation MainWindowController

@synthesize blog,_mainContentView;

- (id) initWithBlog:(Blog*) b{
	
	self = [super initWithWindowNibName:@"MainWindow"];
	
	if(self){
        DDLogInfo(@"%s (%@)", (char*)_cmd, [self class]);
        self.blog=b;
	}
	
	return self;
	
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    DDLogInfo(@"Loaded Main Window");
	// The array determines our order
    _topLevelItems = [[NSArray arrayWithObjects:NSLocalizedString(@"DASHBOARD", @"Dashboard"), NSLocalizedString(@"POSTS", @"Posts"), NSLocalizedString(@"CATEGORIES", @"Categories"),NSLocalizedString(@"CUSTOM_FIELDS", @"Custom fields"), nil] retain];
	
    // The data is stored ina  dictionary. The objects are the nib names to load.
    _childrenDictionary = [NSMutableDictionary new];
    [_childrenDictionary setObject:[NSArray arrayWithObjects:
									[NSArray arrayWithObjects:@"StartView", NSLocalizedString(@"START", @"Start"), nil],
									nil] forKey:NSLocalizedString(@"DASHBOARD", @"Dashboard")];
    [_childrenDictionary setObject:[NSArray arrayWithObjects:
									[NSArray arrayWithObjects:@"NewArticleView", NSLocalizedString(@"NEW_POST", @"New post"), nil],
									[NSArray arrayWithObjects:@"ManagePostsView", NSLocalizedString(@"MANAGE_POSTS", @"Manage posts"), nil],
									[NSArray arrayWithObjects:@"TrashView", NSLocalizedString(@"TRASH", @"Trash"), nil],
									nil] forKey:NSLocalizedString(@"POSTS", @"Posts")];
	[_childrenDictionary setObject:[NSArray arrayWithObjects:
									[NSArray arrayWithObjects:@"ManageCategoriesView",NSLocalizedString(@"MANAGE_CATEGORIES", @"Manage categories"), nil],
									nil] forKey:NSLocalizedString(@"CATEGORIES", @"Categories")];
	[_childrenDictionary setObject:[NSArray arrayWithObjects:
									[NSArray arrayWithObjects:@"ManageCustomFieldsView", NSLocalizedString(@"MANAGE_CUSTOM_FIELDS", @"Mangage custom f."), nil],
									nil] forKey:NSLocalizedString(@"CUSTOM_FIELDS", @"Custom fields")];
    //[_childrenDictionary setObject:[NSArray arrayWithObjects:@"ContentView2", nil] forKey:@"Mailboxes"];
    //[_childrenDictionary setObject:[NSArray arrayWithObjects:@"ContentView1", @"ContentView1", @"ContentView1", @"ContentView1", @"ContentView2", nil] forKey:@"A Fourth Group"];
    
    // The basic recipe for a sidebar. Note that the selectionHighlightStyle is set to NSTableViewSelectionHighlightStyleSourceList in the nib
    [_sidebarOutlineView sizeLastColumnToFit];
    [_sidebarOutlineView reloadData];
    [_sidebarOutlineView setFloatsGroupRows:NO];
	
	
    // NSTableViewRowSizeStyleDefault should be used, unless the user has picked an explicit size. In that case, it should be stored out and re-used.
    [_sidebarOutlineView setRowSizeStyle:NSTableViewRowSizeStyleDefault];
    
    // Expand all the root items; disable the expansion animation that normally happens
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0];
	[_sidebarOutlineView expandItem:nil expandChildren:YES];
    [NSAnimationContext endGrouping];
	
	NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:1];
	[_sidebarOutlineView selectRowIndexes:indexes byExtendingSelection:YES];
	[indexes release];
	
	//Setting up start view
	//_currentContentViewController = [[NSViewController alloc] initWithNibName:@"StartView" bundle:nil]; // Retained
	_currentContentViewController = [[StartViewController alloc] initWithBlog:self.blog andWindowController:self]; // Retained
    
    NSView *view = [_currentContentViewController view];
    view.frame = _mainContentView.bounds;
    [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [_mainContentView addSubview:view];
    
    [_mainContentView setWantsLayer:YES];
    transition = [CATransition animation];
    [transition setType:kCATransitionPush];
    [transition setSubtype:kCATransitionFromLeft];
    
    NSDictionary *ani = [NSDictionary dictionaryWithObject:transition forKey:@"subviews"];
    [_mainContentView setAnimations:ani];
}

- (void)dealloc {
    [_currentContentViewController release];
    [_topLevelItems release];
    [_childrenDictionary release];
    [super dealloc];
}

//When switching on the sidebar
- (void)_setContentViewToName:(NSString *)name {
    
    NSView *currentView=nil;
        
    if (_currentContentViewController) {
        
        if([[_currentContentViewController nibName] isEqualToString:name]){
            return;
        }
        
        DDLogInfo(@"Switching from %@", _currentContentViewController);
        currentView = [_currentContentViewController view];
        
        //[[_currentContentViewController view] removeFromSuperview];
        [_currentContentViewController release];
    }
	if ([name isEqualToString:@"StartView"]) {
        _currentContentViewController = [[StartViewController alloc] initWithBlog:self.blog andWindowController:self]; // Retained
		[[self window] setTitle:NSLocalizedString(@"START", @"Start")];
    } else if ([name isEqualToString:@"NewArticleView"]) {
        _currentContentViewController = [[NewArticleViewController alloc] initWithBlog:self.blog andWindowController:self]; // Retained
		[[self window] setTitle:NSLocalizedString(@"NEW_POST", @"New post")];
    } else if ([name isEqualToString:@"ManagePostsView"]) {
        _currentContentViewController = [[ManagePostsViewController alloc] initWithBlog:self.blog andWindowController:self]; // Retained
		[[self window] setTitle:NSLocalizedString(@"MANAGE_POSTS", @"Manage posts")];
    } else if ([name isEqualToString:@"TrashView"]) {
        _currentContentViewController = [[TrashViewController alloc] initWithBlog:self.blog]; // Retained
		[[self window] setTitle:NSLocalizedString(@"TRASH", @"Trash")];
    }else if ([name isEqualToString:@"ManageCategoriesView"]) {
        _currentContentViewController = [[ManageCategoriesViewController alloc] initWithBlog:self.blog]; // Retained
		[[self window] setTitle:NSLocalizedString(@"MANAGE_CATEGORIES", @"Manage categories")];
    }else if ([name isEqualToString:@"ManageCustomFieldsView"]) {
        _currentContentViewController = [[ManageCustomFieldsViewController alloc] initWithBlog:self.blog]; // Retained
		[[self window] setTitle:NSLocalizedString(@"MANAGE_CUSTOM_FIELDS", @"Mangage custom f.")];
    }
    DDLogInfo(@"Switching to %@", _currentContentViewController);
    NSView *view = [_currentContentViewController view];
	//[view initWithFrame:[_mainContentView frame]];
    view.frame = _mainContentView.bounds;
    [view setWantsLayer:YES];
    [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
   
    [[_mainContentView animator] replaceSubview:currentView with:view];
    //This does a fade in...
    /*NSMutableDictionary *animDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [animDict setObject:view forKey:NSViewAnimationTargetKey];
    [animDict setObject:NSViewAnimationFadeInEffect forKey:NSViewAnimationEffectKey];
    NSViewAnimation *anim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:animDict]];
    [anim setDuration:0.5];
    [anim startAnimation];
    [anim autorelease];*/    
    
    //[_mainContentView addSubview:view];
}

//When switching on the sidebar
- (void)setContentViewNewArticleViewWithPost:(Post*) p {
    
    NSView *currentView=nil;
	
    if (_currentContentViewController) {
        
        if([[_currentContentViewController nibName] isEqualToString:@"NewArticleView"]){
            return;
        }
        
        DDLogInfo(@"Switching from %@", _currentContentViewController);
        currentView = [_currentContentViewController view];
        
        //[[_currentContentViewController view] removeFromSuperview];
        [_currentContentViewController release];
    }
	
	_currentContentViewController = [[NewArticleViewController alloc] initWithBlog:self.blog andPost:p andWindowController:self]; // Retained
   [[self window] setTitle:NSLocalizedString(@"EDIT_POST", @"Edit post")];
    DDLogInfo(@"Switching to %@", _currentContentViewController);
    NSView *view = [_currentContentViewController view];
	//[view initWithFrame:[_mainContentView frame]];
    view.frame = _mainContentView.bounds;
    [view setWantsLayer:YES];
    [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
	
    [[_mainContentView animator] replaceSubview:currentView with:view];
	
    [_sidebarOutlineView deselectAll:self];
	NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:3];
	[_sidebarOutlineView selectRowIndexes:indexes byExtendingSelection:YES];
	[indexes release];
	
}

- (void)setContentViewNewArticleView{
    
    NSView *currentView=nil;
	
    if (_currentContentViewController) {
        
        if([[_currentContentViewController nibName] isEqualToString:@"NewArticleView"]){
            return;
        }
        
        DDLogInfo(@"Switching from %@", _currentContentViewController);
        currentView = [_currentContentViewController view];
        
        //[[_currentContentViewController view] removeFromSuperview];
        [_currentContentViewController release];
    }
	
	_currentContentViewController = [[NewArticleViewController alloc] initWithBlog:self.blog andWindowController:self]; // Retained
    [[self window] setTitle:NSLocalizedString(@"NEW_POST", @"New post")];
    DDLogInfo(@"Switching to %@", _currentContentViewController);
    NSView *view = [_currentContentViewController view];
	//[view initWithFrame:[_mainContentView frame]];
    view.frame = _mainContentView.bounds;
    [view setWantsLayer:YES];
    [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
	
    [[_mainContentView animator] replaceSubview:currentView with:view];
	
    [_sidebarOutlineView deselectAll:self];
	NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:3];
	[_sidebarOutlineView selectRowIndexes:indexes byExtendingSelection:YES];
	[indexes release];
	
}


- (void)setContentViewManagePostsView{
    
    NSView *currentView=nil;
	
    if (_currentContentViewController) {
        
        if([[_currentContentViewController nibName] isEqualToString:@"ManagePostsView"]){
            return;
        }
        
        DDLogInfo(@"Switching from %@", _currentContentViewController);
        currentView = [_currentContentViewController view];
        
        //[[_currentContentViewController view] removeFromSuperview];
        [_currentContentViewController release];
    }
	
	_currentContentViewController = [[ManagePostsViewController alloc] initWithBlog:self.blog andWindowController:self]; // Retained
    [[self window] setTitle:NSLocalizedString(@"NEW_POST", @"New post")];
    DDLogInfo(@"Switching to %@", _currentContentViewController);
    NSView *view = [_currentContentViewController view];
	//[view initWithFrame:[_mainContentView frame]];
    view.frame = _mainContentView.bounds;
    [view setWantsLayer:YES];
    [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
	
    [[_mainContentView animator] replaceSubview:currentView with:view];
	
    [_sidebarOutlineView deselectAll:self];
	NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:4];
	[_sidebarOutlineView selectRowIndexes:indexes byExtendingSelection:YES];
	[indexes release];
	
}

- (void)setContentViewManageCategoriesView{
    
    NSView *currentView=nil;
	
    if (_currentContentViewController) {
        
        if([[_currentContentViewController nibName] isEqualToString:@"ManageCategoriesView"]){
            return;
        }
        
        DDLogInfo(@"Switching from %@", _currentContentViewController);
        currentView = [_currentContentViewController view];
        
        //[[_currentContentViewController view] removeFromSuperview];
        [_currentContentViewController release];
    }
	
	_currentContentViewController = [[ManageCategoriesViewController alloc] initWithBlog:self.blog]; // Retained
    [[self window] setTitle:NSLocalizedString(@"MANAGE_CATEGORIES", @"Manage categories")];
    DDLogInfo(@"Switching to %@", _currentContentViewController);
    NSView *view = [_currentContentViewController view];
	//[view initWithFrame:[_mainContentView frame]];
    view.frame = _mainContentView.bounds;
    [view setWantsLayer:YES];
    [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
	
    [[_mainContentView animator] replaceSubview:currentView with:view];
	
    [_sidebarOutlineView deselectAll:self];
	NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:7];
	[_sidebarOutlineView selectRowIndexes:indexes byExtendingSelection:YES];
	[indexes release];
	
}

- (void)setContentViewTrashView{
    
    NSView *currentView=nil;
	
    if (_currentContentViewController) {
        
        if([[_currentContentViewController nibName] isEqualToString:@"TrashView"]){
            return;
        }
        
        DDLogInfo(@"Switching from %@", _currentContentViewController);
        currentView = [_currentContentViewController view];
        
        //[[_currentContentViewController view] removeFromSuperview];
        [_currentContentViewController release];
    }
	
	_currentContentViewController = [[TrashViewController alloc] initWithBlog:self.blog]; // Retained
    [[self window] setTitle: NSLocalizedString(@"TRASH", @"Trash")];
    DDLogInfo(@"Switching to %@", _currentContentViewController);
    NSView *view = [_currentContentViewController view];
	//[view initWithFrame:[_mainContentView frame]];
    view.frame = _mainContentView.bounds;
    [view setWantsLayer:YES];
    [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
	
    [[_mainContentView animator] replaceSubview:currentView with:view];
	
    [_sidebarOutlineView deselectAll:self];
	NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:5];
	[_sidebarOutlineView selectRowIndexes:indexes byExtendingSelection:YES];
	[indexes release];
	
}

- (void)setContentViewStartView{
    
    NSView *currentView=nil;
	
    if (_currentContentViewController) {
        
        /*if([[_currentContentViewController nibName] isEqualToString:@"TrashView"]){
            return;
        }*/
        
        DDLogInfo(@"Switching from %@", _currentContentViewController);
        currentView = [_currentContentViewController view];
        
        //[[_currentContentViewController view] removeFromSuperview];
        [_currentContentViewController release];
    }
	
	_currentContentViewController = [[StartViewController alloc] initWithBlog:self.blog andWindowController:self]; // Retained
    [[self window] setTitle: NSLocalizedString(@"START", @"Start")];
    DDLogInfo(@"Switching to %@", _currentContentViewController);
    NSView *view = [_currentContentViewController view];
	//[view initWithFrame:[_mainContentView frame]];
    view.frame = _mainContentView.bounds;
    [view setWantsLayer:YES];
    [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
	
    [[_mainContentView animator] replaceSubview:currentView with:view];
	
    [_sidebarOutlineView deselectAll:self];
	NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:1];
	[_sidebarOutlineView selectRowIndexes:indexes byExtendingSelection:YES];
	[indexes release];
	
}

- (void)setContentViewManageCustomFieldsView{
    
    NSView *currentView=nil;
	
    if (_currentContentViewController) {
        
        if([[_currentContentViewController nibName] isEqualToString:@"ManageustomFieldsView"]){
            return;
        }
        
        DDLogInfo(@"Switching from %@", _currentContentViewController);
        currentView = [_currentContentViewController view];
        
        //[[_currentContentViewController view] removeFromSuperview];
        [_currentContentViewController release];
    }
	
	_currentContentViewController = [[ManageCustomFieldsViewController alloc] initWithBlog:self.blog]; // Retained
    [[self window] setTitle: NSLocalizedString(@"MANAGE_CUSTOM_FIELDS", @"Mangage custom f.")];
    DDLogInfo(@"Switching to %@", _currentContentViewController);
    NSView *view = [_currentContentViewController view];
	//[view initWithFrame:[_mainContentView frame]];
    view.frame = _mainContentView.bounds;
    [view setWantsLayer:YES];
    [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
	
    [[_mainContentView animator] replaceSubview:currentView with:view];
	
    [_sidebarOutlineView deselectAll:self];
	NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:9];
	[_sidebarOutlineView selectRowIndexes:indexes byExtendingSelection:YES];
	[indexes release];
	
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    if ([_sidebarOutlineView selectedRow] != -1) {
        NSArray *item = [_sidebarOutlineView itemAtRow:[_sidebarOutlineView selectedRow]];
        if ([_sidebarOutlineView parentForItem:item] != nil) {
            DDLogInfo(@"Changing to view: %@", [item objectAtIndex:0]);
            // Only change things for non-root items (root items can be selected, but are ignored)
            [self _setContentViewToName:[item objectAtIndex:0]];
        }        
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{	
	//Make sure that the item isn't a group as they can't be selected
	if ([_sidebarOutlineView parentForItem:item] != nil) {		
		return YES;
	}
	else {
		return NO;
	}
	
	return YES;
}

- (NSArray *)_childrenForItem:(id)item {
    NSArray *children;
    if (item == nil) {
        children = _topLevelItems;
    } else {
        children = [_childrenDictionary objectForKey:item];
    }
    return children;    
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return [[self _childrenForItem:item] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([outlineView parentForItem:item] == nil) {
        return YES;
    } else {
        return NO;
    }    
}

- (NSInteger) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return [[self _childrenForItem:item] count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return [_topLevelItems containsObject:item];
}


- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    // For the groups, we just return a regular text view. 
    if ([_topLevelItems containsObject:item]) {
        NSTextField *result = [outlineView makeViewWithIdentifier:@"HeaderTextField" owner:self];
        // Uppercase the string value, but don't set anything else. NSOutlineView automatically applies attributes as necessary
        NSString *value = [item uppercaseString];
        [result setStringValue:value];
        return result;
    } else  {
        // The cell is setup in IB. The textField and imageView outlets are properly setup.
        // Special attributes are automatically applied by NSTableView/NSOutlineView for the source list
        SidebarTableCellView *result = [outlineView makeViewWithIdentifier:@"MainCell" owner:self];
        result.textField.stringValue = [item objectAtIndex:1];
        // Setup the icon based on our section
        id parent = [outlineView parentForItem:item];
        NSInteger index = [_topLevelItems indexOfObject:parent];
        NSInteger iconOffset = index % 4;
        DDLogInfo(@"Sidebar Index: %d, offset: %d", index, iconOffset);
        DDLogInfo(@"Item: %@", result.textField.stringValue);
        
        if([result.textField.stringValue isEqualToString:NSLocalizedString(@"START", @"Start")]){
            
            result.imageView.image = [NSImage imageNamed:NSImageNameHomeTemplate];
            
        }else if([result.textField.stringValue isEqualToString:NSLocalizedString(@"NEW_POST", @"New post")]){
            
            result.imageView.image = [NSImage imageNamed:NSImageNameAddTemplate];
            
        }else if([result.textField.stringValue isEqualToString:NSLocalizedString(@"MANAGE_POSTS", @"Manage posts")]){
            
            result.imageView.image = [NSImage imageNamed:NSImageNameListViewTemplate];
            
        }else if([result.textField.stringValue isEqualToString:NSLocalizedString(@"TRASH", @"Trash")]){
            
            result.imageView.image = [NSImage imageNamed:NSImageNameTrashEmpty];
            
        }else if([result.textField.stringValue isEqualToString:NSLocalizedString(@"MANAGE_CATEGORIES", @"Manage categories")]){
            
            result.imageView.image = [NSImage imageNamed:NSImageNameListViewTemplate];
            
        }else if([result.textField.stringValue isEqualToString:NSLocalizedString(@"MANAGE_CUSTOM_FIELDS", @"Mangage custom f.")]){
            
            result.imageView.image = [NSImage imageNamed:NSImageNameListViewTemplate];
            
        }
        
        return result;
    }
}

- (void)buttonClicked:(id)sender {
    // Example target action for the button
    NSInteger row = [_sidebarOutlineView rowForView:sender];
    DDLogInfo(@"row: %ld", row);
}

- (IBAction)sidebarMenuDidChange:(id)sender {
    // Allow the user to pick a sidebar style
    NSInteger rowSizeStyle = [sender tag];
    [_sidebarOutlineView setRowSizeStyle:rowSizeStyle];
}

- (void)menuNeedsUpdate:(NSMenu *)menu {
    for (NSInteger i = 0; i < [menu numberOfItems]; i++) {
        NSMenuItem *item = [menu itemAtIndex:i];
        if (![item isSeparatorItem]) {
            // In IB, the tag was set to the appropriate rowSizeStyle. Read in that value.
            NSInteger state = ([item tag] == [_sidebarOutlineView rowSizeStyle]) ? 1 : 0;
            [item setState:state];
        }
    }
}

- (IBAction)showPreferencesWindow:(id)sender{
	
	if (!preferencesController) {
		preferencesController = [[PreferencesWindowController alloc] initWithBlog:self.blog andMainWindowController:self];
	}
	
	DDLogInfo(@"Showing %@", preferencesController);
	[preferencesController showWindow:self];
	
	
}

- (IBAction)showAboutWindow:(id)sender{
	
	[aboutWindow makeKeyAndOrderFront:self];
	
}

- (IBAction)showNewArticleView:(id)sender{
	[self setContentViewNewArticleView];
	
}

- (IBAction)showManagePostsView:(id)sender{
	[self setContentViewManagePostsView];
	
}

- (IBAction)showManageCategoriesView:(id)sender{
	[self setContentViewManageCategoriesView];
	
}

- (IBAction)showTrashView:(id)sender{
	[self setContentViewTrashView];
	
}

- (IBAction)showManageCustomFieldsView:(id)sender{
	[self setContentViewManageCustomFieldsView];
	
}

- (IBAction)showLogoutAccount:(id)sender{
	if (!preferencesController) {
		preferencesController = [[PreferencesWindowController alloc] initWithBlog:self.blog andMainWindowController:self];
	}
	DDLogInfo(@"Showing %@", preferencesController);
	[preferencesController showWindow:self];
    [preferencesController.tabs selectTabViewItemAtIndex:1];
	
}

- (IBAction)showEditDataAccount:(id)sender{
	if (!preferencesController) {
		preferencesController = [[PreferencesWindowController alloc] initWithBlog:self.blog andMainWindowController:self];
	}
	DDLogInfo(@"Showing %@", preferencesController);
	[preferencesController showWindow:self];
	
}

- (IBAction)showHelpUrl:(id)sender{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://renefernandez.com/post-off-app/help"]];
}


@end
