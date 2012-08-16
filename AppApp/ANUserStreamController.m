//
//  ANUserStreamController.m
//  AppApp
//
//  Created by Nick Pannuto on 8/11/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANUserStreamController.h"

@interface ANUserStreamController ()

@end

@implementation ANUserStreamController

- (NSString *)sideMenuTitle
{
    return @"User Stream";
}

- (NSString *)sideMenuImageName
{
    return @"sidemenu_userstream_icon";
}

- (void)addItemsOnTop
{
    // Call this to indicate that we have finished "refreshing".
    // This will then result in the headerView being unpinned (-unpinHeaderView will be called).
    [[ANAPICall sharedAppAPI] getUserStream:^(id dataObject, NSError *error) {
        streamData = [NSMutableArray arrayWithArray:dataObject];
        [self.tableView reloadData];
        [self refreshCompleted];
    }];
}

- (void)addItemsOnBottom
{
    // grab the last post
    id lastPost = [streamData lastObject];
    
    // if we have a post
    if (lastPost) {
        
        // fetch old data
        [[ANAPICall sharedAppAPI] getUserStreamBeforePost:[lastPost objectForKey:@"id"] withCompletionBlock:^(id dataObject, NSError *error) {
            
            // verify object
            if ([dataObject isKindOfClass:[NSArray class]])
            {
                // begin updates on table
                [self.tableView beginUpdates];
                
                // get start indexpath
                NSUInteger startIndexPathRow = [streamData count];
                NSUInteger endIndexPathRow = [dataObject count] + startIndexPathRow;
                
                // add data
                [streamData addObjectsFromArray:dataObject];
                
                // initialize indexpaths
                NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:[dataObject count]];
                
                // create array of index paths
                while (startIndexPathRow < endIndexPathRow) {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:startIndexPathRow inSection:0]];
                    startIndexPathRow++;
                }
                
                // insert rows
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }
            
            [self loadMoreCompleted];
        }];
    } else {
        [self loadMoreCompleted];
    }
}

@end
