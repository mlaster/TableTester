//
//  ViewController.h
//  TableTester
//
//  Created by Mike Laster on 5/24/12.
//  Copyright (c) 2012 iCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIButton *button;
@property (nonatomic, strong) IBOutlet UITableView *beforeTableView;
@property (nonatomic, strong) IBOutlet UITableView *afterTableView;
@property (nonatomic, strong) IBOutlet UITableView *dynamicTableView;

@property (nonatomic, strong) NSArray *beforeList;
@property (nonatomic, strong) NSArray *afterList;
@property (nonatomic, strong) NSArray *dynamicList;

- (IBAction)change:(id)sender;
- (void)animateUpdateFromOldList:(NSArray *)oldList newList:(NSArray *)newList;

@end
