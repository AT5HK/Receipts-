//
//  ReceiptViewController.m
//  Receipts++
//
//  Created by Auston Salvana on 7/21/15.
//  Copyright (c) 2015 ASolo. All rights reserved.
//

#import "ReceiptViewController.h"

@interface ReceiptViewController ()
@property (weak, nonatomic) IBOutlet UITextField *amountField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionField;
@property (weak, nonatomic) IBOutlet UITextField *tagsField;

@end

@implementation ReceiptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.amountField.text = [[self.managedObjectReceipt valueForKey:@"amount"]stringValue];
//    self.descriptionField.text = [self.managedObjectReceipt valueForKey:@"descrptionProp"];
//    self.tagsField.text = [[self.managedObjectReceipt valueForKeyPath:@"tag.tagName"]anyObject];
}

-(IBAction)saveManagedObject:(id)sender {
    [self.managedObjectReceipt setValue:self.descriptionField.text forKey:@"descrptionProp"]; //descript
    [self.managedObjectReceipt setValue:[NSNumber numberWithInt:[self.amountField.text intValue]] forKey:@"amount"]; //amount
    [self.managedObjectReceipt setValue:[NSDate date] forKey:@"timeStamp"];// set timeStamp
    
    //adding tag to managedobject
    NSEntityDescription *tagEntity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:self.managedObjectReceipt.managedObjectContext];
    NSManagedObject *newTag = [[NSManagedObject alloc] initWithEntity:tagEntity insertIntoManagedObjectContext:self.managedObjectReceipt.managedObjectContext];
    [newTag setValue:self.tagsField.text forKey:@"tagName"];
    [self.managedObjectReceipt setValue:[NSSet setWithObject:newTag] forKey:@"tag"];
    
    //saving data to manageObjectContext
    NSError *error = nil;
    if (![self.managedObjectReceipt.managedObjectContext save:&error]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.amountField resignFirstResponder];
    [self.descriptionField resignFirstResponder];
    [self.tagsField resignFirstResponder];
}

@end
