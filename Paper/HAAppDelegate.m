//
//  HAAppDelegate.m
//  Paper
//
//  Created by Heberti Almeida on 03/02/14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

#import "HAAppDelegate.h"
#import "HATransitionController.h"
#import "HACollectionViewSmallLayout.h"
#import "HASmallCollectionViewController.h"
#import "SL_ParseOperation.h"
#import "SL_StoreRecord.h"

#define kGenderIndex @"kGenderIndex"

static const int recordsPerPage = 15; //have to be changed only with pageItems parameter in stylightAPIURL !
static NSString *const stylightAPIURLStart = @"http://api.stylight.com/api/new?gender=";
static NSString *const stylightAPIURLEnd = @"&initializeBoards=true&initializeRows=1024000&pageItems=15&page=";
static NSString *const stylightAPIKey = @"D13A5A5A0A3602477A513E02691A8458";


@interface HAAppDelegate () <UINavigationControllerDelegate, HATransitionControllerDelegate>
// the queue to run our "ParseOperation"
@property (nonatomic, strong) NSOperationQueue *queue;
// RSS feed network connection to the App Store
@property (nonatomic, strong) NSURLConnection *thingsListConnection;
@property (nonatomic) NSInteger genderIndex;
@property (nonatomic, strong) NSMutableData *thingsListData;
@property (nonatomic) UINavigationController *navigationController;
@property (nonatomic) HATransitionController *transitionController;
@property (nonatomic, strong) HASmallCollectionViewController *collectionViewController;

@end


@implementation HAAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

// -------------------------------------------------------------------------------
//	CoreData methods
// -------------------------------------------------------------------------------
- (NSManagedObjectContext *) managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"PhoneBook.sqlite"]];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:nil error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.genderIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kGenderIndex];
    
    HACollectionViewSmallLayout *smallLayout = [[HACollectionViewSmallLayout alloc] init];
    self.collectionViewController = [[HASmallCollectionViewController alloc] initWithCollectionViewLayout:smallLayout];
    [self.collectionViewController setGenderIndex:self.genderIndex];
    [self.collectionViewController setRestorationIdentifier:@"rootView"];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.collectionViewController];
    self.navigationController.delegate = self;
    self.navigationController.navigationBarHidden = YES;
    
    self.transitionController = [[HATransitionController alloc] initWithCollectionView:self.collectionViewController.collectionView];
    self.transitionController.delegate = self;
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    [self performInitialDownloadIfNeeded];
    
    return YES;
}

- (void)loadRecordsFrom:(int)amountOfLoadedRecords
{
    int pageToLoad = amountOfLoadedRecords/recordsPerPage;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setValue:stylightAPIKey forHTTPHeaderField:@"X-apiKey"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%d", stylightAPIURLStart, self.genderIndex == 0 ? @"men" : @"women", stylightAPIURLEnd, pageToLoad];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    
    self.thingsListConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    // Test the validity of the connection object. The most likely reason for the connection object
    // to be nil is a malformed URL, which is a programmatic error easily detected during development
    // If the URL is more dynamic, then you should implement a more flexible validation technique, and
    // be able to both recover from errors and communicate problems to the user in an unobtrusive manner.
    //
    NSAssert(self.thingsListConnection != nil, @"Failure to create URL connection.");
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //    }
}

- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Show Information"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
}

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is how
// the connection object,  which is working in the background, can asynchronously communicate back to
// its delegate on the thread from which it was started - in this case, the main thread.
//
#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.thingsListData = [NSMutableData data];    // start off with new data
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.thingsListData appendData:data];  // append incoming data
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet)
	{
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No Connection Error"
															 forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
														 code:kCFURLErrorNotConnectedToInternet
													 userInfo:userInfo];
        [self handleError:noConnectionError];
    }
	else
	{
        // otherwise handle the error generically
        [self handleError:error];
    }
    
    self.thingsListConnection = nil;   // release our connection
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.thingsListConnection = nil;   // release our connection
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // create the queue to run our ParseOperation
    self.queue = [[NSOperationQueue alloc] init];
    
    // create an ParseOperation (NSOperation subclass) to parse the RSS feed data
    // so that the UI is not blocked
    SL_ParseOperation *parser = [[SL_ParseOperation alloc] initWithData:self.thingsListData];
    
    parser.errorHandler = ^(NSError *parseError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleError:parseError];
        });
    };
    
    // Referencing parser from within its completionBlock would create a retain
    // cycle.
    
    parser.completionBlock = ^(void) {
        // The completion block may execute on any thread.  Because operations
        // involving the UI are about to be performed, make sure they execute
        // on the main thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            // The root rootViewController is the only child of the navigation
            // controller, which is the window's rootViewController.
            
            HAPaperCollectionViewController *rootViewController = (HAPaperCollectionViewController *)self.navigationController.viewControllers[0];

            // fill table with CoreData entries
            rootViewController.entries = [self getAllFashionRecords];
            
            // tell our table view to reload its data, now that parsing has completed
            [rootViewController.collectionView reloadData];
        });
        
        // we are finished with the queue and our ParseOperation
        self.queue = nil;
    };
    
    [self.queue addOperation:parser]; // this will start the "ParseOperation"
    
    // ownership of appListData has been transferred to the parse operation
    // and should no longer be referenced in this thread
    self.thingsListData = nil;
}

-(void)performInitialDownloadIfNeeded
{
    NSArray *fashionRecords = [self getAllFashionRecords];
    if ([fashionRecords count] > 0) {
        HASmallCollectionViewController *rootViewController = (HASmallCollectionViewController *)[self.navigationController topViewController];
        // fill table with CoreData entries
        rootViewController.entries = fashionRecords;
        // tell our table view to reload its data, now that parsing has completed
        [rootViewController.collectionView reloadData];
    } else {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setValue:stylightAPIKey forHTTPHeaderField:@"X-apiKey"];
        NSString *urlString = [NSString stringWithFormat:@"%@%@%@0", stylightAPIURLStart, self.genderIndex == 0 ? @"men" : @"women", stylightAPIURLEnd];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"GET"];
        
        self.thingsListConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        // Test the validity of the connection object. The most likely reason for the connection object
        // to be nil is a malformed URL, which is a programmatic error easily detected during development
        // If the URL is more dynamic, then you should implement a more flexible validation technique, and
        // be able to both recover from errors and communicate problems to the user in an unobtrusive manner.
        //
        NSAssert(self.thingsListConnection != nil, @"Failure to create URL connection.");
        
        // show in the status bar that network activity is starting
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

-(NSArray*)getAllFashionRecords
{
    // initializing NSFetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //Setting Entity to be Queried
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FashionEntity"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gender == %@", self.genderIndex == 0 ? @"Mann" : @"Frau"];
    [fetchRequest setPredicate:predicate];
    
    NSError* error;
    
    // Query on managedObjectContext With Generated fetchRequest
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Returning Fetched Records
    return fetchedRecords;
}

-(void)reloadWithGender:(NSInteger)genderIndex {
    self.genderIndex = genderIndex;
    [self performInitialDownloadIfNeeded];
    NSArray *fashionRecords = [self getAllFashionRecords];
    if ([fashionRecords count] > 0) {
        // fill table with CoreData entries
        self.collectionViewController.entries = fashionRecords;
        // tell our table view to reload its data, now that parsing has completed
        [self.collectionViewController.collectionView reloadData];
    }
}

-(void)eraseAllRecords
{
    NSFetchRequest * allRecords = [[NSFetchRequest alloc] init];
    [allRecords setEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.managedObjectContext]];
    [allRecords setIncludesPropertyValues:NO];
    
    NSError * error = nil;
    NSArray * records = [self.managedObjectContext executeFetchRequest:allRecords error:&error];
    //error handling goes here
    for (NSManagedObject * record in records) {
        [self.managedObjectContext deleteObject:record];
    }
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
    
    
    HASmallCollectionViewController *rootViewController = (HASmallCollectionViewController *)[self.navigationController topViewController];
    // fill table with CoreData entries

    rootViewController.entries = [self getAllFashionRecords];
    [rootViewController.collectionView reloadData];
}

#pragma mark - work with SmallCollection

- (void)interactionBeganAtPoint:(CGPoint)point
{
    // Very basic communication between the transition controller and the top view controller
    // It would be easy to add more control, support pop, push or no-op
    HASmallCollectionViewController *presentingVC = (HASmallCollectionViewController *)[self.navigationController topViewController];
    HASmallCollectionViewController *presentedVC = (HASmallCollectionViewController *)[presentingVC nextViewControllerAtPoint:point];
    if (presentedVC!=nil)
    {
        [self.navigationController pushViewController:presentedVC animated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController
{
    if (animationController==self.transitionController) {
        return self.transitionController;
    }
    return nil;
}


- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    if (![fromVC isKindOfClass:[UICollectionViewController class]] || ![toVC isKindOfClass:[UICollectionViewController class]])
    {
        return nil;
    }
    if (!self.transitionController.hasActiveInteraction)
    {
        return nil;
    }
    
    self.transitionController.navigationOperation = operation;
    return self.transitionController;
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

-(BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    NSLog(@"%ld", self.genderIndex);
    [[NSUserDefaults standardUserDefaults] setInteger:self.genderIndex forKey:kGenderIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];

    return YES;
}

@end
