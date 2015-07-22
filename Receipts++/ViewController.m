//
//  ViewController.m
//  Receipts++
//
//  Created by Auston Salvana on 7/21/15.
//  Copyright (c) 2015 ASolo. All rights reserved.
//

#import "ViewController.h"
#import "ReceiptViewController.h"
#import "Receipt.h"
#import "Tag.h"

@interface ViewController ()

@property (nonatomic) NSArray *receiptsObjects;
@property (nonatomic) UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableDictionary *headers;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.headers = [NSMutableDictionary dictionary];
    [self runFetch];
    
}

#pragma mark - Table View DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.headers allKeys].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *arrayKey = [[self.headers allKeys]objectAtIndex:section];
    Receipt *managedObj = [self.headers objectForKey:arrayKey];
    return managedObj.tag.count;
//    return self.receiptsObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerTitle = [[self.headers allKeys]objectAtIndex:section];
    return headerTitle;
}

#pragma mark - Fetch request

-(NSFetchRequest*)fetchRequest {
    if (_fetchRequest != nil) {
        return _fetchRequest;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Receipt" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return fetchRequest;
}

#pragma mark - helper methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = self.receiptsObjects[indexPath.section];
    cell.textLabel.text = [object valueForKey:@"descrptionProp"];
}

-(void)runFetch {
    NSError *error;
    self.receiptsObjects = [self.managedObjectContext executeFetchRequest:self.fetchRequest error:&error];
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        
    } else {
        for (Receipt *receiptObject in self.receiptsObjects) {
            NSSet *tags = receiptObject.tag;
            for (Tag *storedTags in tags) {
                [self.headers setObject:receiptObject forKey:storedTags.tagName];
            }
        }
//        NSLog(@"All the tag names: %@", self.headers);
    }
}

#pragma mark - segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ReceiptViewController"])  {
        ReceiptViewController *receiptviewController = segue.destinationViewController;
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        receiptviewController.managedObjectReceipt = [self.receiptsObjects lastObject];
    }
}

- (IBAction)unwindToMaster:(UIStoryboardSegue *)unwindSegue
{
    ReceiptViewController *editReceiptVC = unwindSegue.sourceViewController;
    
    if ([editReceiptVC isKindOfClass:[ReceiptViewController class]]) {
        for (Receipt *receiptObject in self.receiptsObjects) {
            NSSet *tags = receiptObject.tag;
            for (Tag *storedTags in tags) {
                [self.headers setObject:receiptObject forKey:storedTags.tagName];
            }
        }
        [self.tableView reloadData];
        NSLog(@"ssf");
    }
}

#pragma mark - IBAction add receipt

- (IBAction)addReceipt:(id)sender {
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Name the receipt" message:@"Input a name for your receipt!" preferredStyle:UIAlertControllerStyleAlert];
//    
//    UIAlertAction *save = [UIAlertAction actionWithTitle:@"save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        //persist data
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Receipt" inManagedObjectContext:self.managedObjectContext];
        NSManagedObject *newManagedObject = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
        
//        // If appropriate, configure the new managed object.
//        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
//        [newManagedObject setValue:self.textField.text forKey:@"descrptionProp"];
//        
//        // Save the context.
//        NSError *error = nil;
//        if (![_managedObjectContext save:&error]) {
//            // Replace this implementation with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
        //add objecct to receiptsObjects array
        NSMutableArray *mutableReceiptObjects = self.receiptsObjects.mutableCopy;
        [mutableReceiptObjects addObject:newManagedObject];
        self.receiptsObjects = mutableReceiptObjects;
//        [self.tableView reloadData];
//    }];
//    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
//    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//        self.textField = textField;
//    }];
//    
//    [alert addAction:save];
//    [alert addAction:cancel];
//    [self presentViewController:alert animated:YES completion:nil];
    [self performSegueWithIdentifier:@"ReceiptViewController" sender:nil];
}

@end
