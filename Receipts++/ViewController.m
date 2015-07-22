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
    NSString* tagKey = [self.headers allKeys][section];
    NSArray *tagsArrayForKey = self.headers[tagKey];
    return tagsArrayForKey.count;

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

    NSString* tagKey = [self.headers allKeys][indexPath.section];
    NSArray *tagsArrayForKey = self.headers[tagKey];
    Receipt *receipt1 = tagsArrayForKey[indexPath.row];
    cell.textLabel.text = receipt1.descrptionProp;
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
                [self.headers setObject:@[receiptObject] forKey:storedTags.tagName];
                NSLog(@"receipt object: %@ for Tag %@", receiptObject.descrptionProp, storedTags.tagName);
            }
        }
    }
}

#pragma mark - segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ReceiptViewController"])  {
        ReceiptViewController *receiptviewController = segue.destinationViewController;
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
    }
}

#pragma mark - IBAction add receipt

- (IBAction)addReceipt:(id)sender {

       //persist data
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Receipt" inManagedObjectContext:self.managedObjectContext];
        NSManagedObject *newManagedObject = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];

        //add objecct to receiptsObjects array
        NSMutableArray *mutableReceiptObjects = self.receiptsObjects.mutableCopy;
        [mutableReceiptObjects addObject:newManagedObject];
        self.receiptsObjects = mutableReceiptObjects;

    [self performSegueWithIdentifier:@"ReceiptViewController" sender:nil];
}

@end
