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
                       [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"key", @"Two", @"name", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"3", @"key", @"Three", @"name", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"4", @"key", @"Four", @"name", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"5", @"key", @"Five", @"name", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"6", @"key", @"Six", @"name", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"7", @"key", @"Seven", @"name", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"8", @"key", @"Eight", @"name", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"9", @"key", @"Nine", @"name", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"10", @"key", @"Ten", @"name", nil],
                       nil];
    self.afterList = [NSArray arrayWithObjects:
//                      [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"key", @"One", @"name", nil],
//                      [NSDictionary dictionaryWithObjectsAndKeys:@"3", @"key", @"Three", @"name", nil],
//                      [NSDictionary dictionaryWithObjectsAndKeys:@"5", @"key", @"Five", @"name", nil],
//                      [NSDictionary dictionaryWithObjectsAndKeys:@"7", @"key", @"Seven", @"name", nil],
//                      [NSDictionary dictionaryWithObjectsAndKeys:@"9", @"key", @"Nine", @"name", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:@"10", @"key", @"Ten", @"name", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:@"8", @"key", @"Eight", @"name", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:@"6", @"key", @"Six", @"name", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:@"4", @"key", @"Four", @"name", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"key", @"Two", @"name", nil],
                       nil];
    self.dynamicList = [NSArray array];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dynamicList = [self.beforeList copy];
    [self animateTableViewUpdate:self.dynamicTableView FromOldList:[NSArray array] newList:self.beforeList comparisionKey:@"key"];
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
        [self animateTableViewUpdate:self.dynamicTableView FromOldList:oldList newList:self.afterList comparisionKey:@"key"];
    } else {
        NSArray *oldList = [self.dynamicList copy];

        NSLog(@"Changing to Before");
        [sender setTitle:@"Before" forState:UIControlStateNormal];
        self.dynamicList = [self.beforeList copy];
        [self animateTableViewUpdate:self.dynamicTableView FromOldList:oldList newList:self.beforeList comparisionKey:@"key"];
    }
}

- (void)animateTableViewUpdate:(UITableView *)inTableView FromOldList:(NSArray *)oldList newList:(NSArray *)newList comparisionKey:(NSString *)inKey {
    NSMutableDictionary *oldMap = [NSMutableDictionary dictionary];
    NSMutableDictionary *newMap = [NSMutableDictionary dictionary];
    NSMutableSet *oldSet = [NSMutableSet set];
    NSMutableSet *newSet = [NSMutableSet set];
    NSMutableSet *deleteSet = nil;
    NSMutableSet *insertSet = nil;
    static NSInteger offset = 0;

    [oldList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [oldMap setObject:obj forKey:[obj valueForKey:inKey]];
    }];

    [newList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [newMap setObject:obj forKey:[obj valueForKey:inKey]];
    }];

    [oldSet addObjectsFromArray:[oldMap allKeys]];
    [newSet addObjectsFromArray:[newMap allKeys]];
    
    deleteSet = [oldSet mutableCopy];
    [deleteSet minusSet:newSet];
    
    insertSet = [newSet mutableCopy];
    [insertSet minusSet:oldSet];

    [inTableView beginUpdates];

    // Process moves
    for (NSUInteger i = 0; i < [newList count]; i++) {
        NSString *candidateObject = newList[i];
        NSString *candidateKey = [candidateObject valueForKey:inKey];
        
        if ([deleteSet containsObject:candidateKey] == NO &&
            [insertSet containsObject:candidateKey] == NO) {
            NSUInteger oldIndex = [oldList indexOfObject:[oldMap objectForKey:candidateKey]];
            NSUInteger newIndex = [newList indexOfObject:[newMap objectForKey:candidateKey]];

            
            NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:(NSInteger)oldIndex + offset inSection:0];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(NSInteger)newIndex + offset inSection:0];
            
            if (oldIndex != newIndex) {
//                NSLog(@"MOVE row at %@ to %@", oldIndexPath, newIndexPath);
                [inTableView moveRowAtIndexPath:oldIndexPath toIndexPath:newIndexPath];
            }
        }
    }

    // Process deletes
    for (NSString *deleteKey in deleteSet) {
        NSUInteger index = [oldList indexOfObject:[oldMap objectForKey:deleteKey]];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(NSInteger)index + offset inSection:0];
        NSParameterAssert(index != NSNotFound);

//        NSLog(@"DELETE row at %@", [NSArray arrayWithObject:indexPath]);
        [inTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    // Process inserts
    for (NSString *insertKey in insertSet) {
        NSUInteger index = [newList indexOfObject:[newMap objectForKey:insertKey]];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(NSInteger)index + offset inSection:0];
        NSParameterAssert(index != NSNotFound);

//        NSLog(@"INSERT row at %@", [NSArray arrayWithObject:indexPath]);
        [inTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [inTableView endUpdates];
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
