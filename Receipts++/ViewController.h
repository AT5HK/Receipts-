//
//  ViewController.h
//  Receipts++
//
//  Created by Auston Salvana on 7/21/15.
//  Copyright (c) 2015 ASolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSFetchRequest *fetchRequest;

@end

