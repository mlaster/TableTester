//
//  ViewController.m
//  TableTester
//
//  Created by Mike Laster on 5/24/12.
//  Copyright (c) 2012 iCloud. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.beforeList = [NSArray arrayWithObjects:
                       [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"key", @"One", @"name", nil],
                       nil];
    self.afterList = [NSArray arrayWithObjects:
                       [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"key", @"One", @"name", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"key", @"Two", @"name", nil],
                       nil];
    self.dynamicList = [NSArray array];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dynamicList = [self.beforeList copy];
    [self animateUpdateFromOldList:[NSArray array] newList:self.beforeList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)change:(UIButton *)sender {
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"Before"]) {
        NSArray *oldList = [self.dynamicList copy];
        
        NSLog(@"Changing to After");
        [sender setTitle:@"After" forState:UIControlStateNormal];
        self.dynamicList = [self.afterList copy];
        [self animateUpdateFromOldList:oldList newList:self.afterList];
    } else {
        NSLog(@"Changing to Before");
        [sender setTitle:@"Before" forState:UIControlStateNormal];
        [self animateUpdateFromOldList:self.dynamicList newList:self.beforeList];
        self.dynamicList = [self.beforeList copy];
    }
}

- (void)animateUpdateFromOldList:(NSArray *)oldList newList:(NSArray *)newList {
    NSMutableArray *workArray = [oldList mutableCopy];
    NSMutableSet *oldSet = [[NSMutableSet alloc] initWithArray:oldList];
    NSMutableSet *newSet = [[NSMutableSet alloc] initWithArray:newList];
    NSMutableSet *deleteSet = nil;
    NSMutableSet *insertSet = nil;
    static NSInteger offset = 0;
    
    deleteSet = [oldSet mutableCopy];
    [deleteSet minusSet:newSet];
    
    insertSet = [newSet mutableCopy];
    [insertSet minusSet:oldSet];

    NSLog(@"oldList.count: %d  newList.count: %d", [oldList count], [newList count]);
    [self.dynamicTableView beginUpdates];
    
    // Process deletes
    for (NSDictionary *deletedObject in deleteSet) {
        NSUInteger index = [oldList indexOfObject:deletedObject];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(NSInteger)index + offset inSection:0];
        [workArray removeObjectAtIndex:index];
        NSLog(@"DELETE row at %@", [NSArray arrayWithObject:indexPath]);
        [self.dynamicTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    // Process inserts
    for (NSDictionary *insertObject in insertSet) {
        NSUInteger index = [newList indexOfObject:insertObject];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(NSInteger)index + offset inSection:0];
        NSLog(@"INSERT row at %@", [NSArray arrayWithObject:indexPath]);
        [self.dynamicTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    // Process moves
    for (NSUInteger i = 0; i < [newList count]; i++) {
        NSDictionary *candidateObject = newList[i];
        
        if ([deleteSet containsObject:candidateObject] == NO &&
            [insertSet containsObject:candidateObject] == NO) {
            NSUInteger oldIndex = [oldList indexOfObject:candidateObject];
            NSUInteger newIndex = [newList indexOfObject:candidateObject];
            NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:(NSInteger)oldIndex + offset inSection:0];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(NSInteger)newIndex + offset inSection:0];
            
            if (oldIndex != newIndex) {
                NSLog(@"MOVE row at %@ to %@", oldIndexPath, newIndexPath);
                [self.dynamicTableView moveRowAtIndexPath:oldIndexPath toIndexPath:newIndexPath];
            }
        }
    }
    [self.dynamicTableView endUpdates];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)inTableView numberOfRowsInSection:(NSInteger)inSection {
    NSInteger retValue = 0;
    
    if (inTableView == self.beforeTableView) {
        retValue = [self.beforeList count];
    } else if (inTableView == self.afterTableView) {
        retValue = [self.afterList count];
    } else if (inTableView == self.dynamicTableView) {
        retValue = [self.dynamicList count];
    }
    
    return retValue;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)inTableView cellForRowAtIndexPath:(NSIndexPath *)inIndexPath {
    UITableViewCell *retValue = nil;
    
    retValue = [inTableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (retValue == nil) {
        retValue = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }

    if (inTableView == self.beforeTableView) {
        retValue.textLabel.text = [self.beforeList[inIndexPath.row] valueForKey:@"name"];
    } else if (inTableView == self.afterTableView) {
        retValue.textLabel.text = [self.afterList[inIndexPath.row] valueForKey:@"name"];
    } else if (inTableView == self.dynamicTableView) {
        retValue.textLabel.text = [self.dynamicList[inIndexPath.row] valueForKey:@"name"];
    }

    return retValue;
}

@end
