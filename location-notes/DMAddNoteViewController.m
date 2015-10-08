//
//  DMAddNoteViewController.m
//  location-notes
//
//  Created by Darin Minamoto on 9/3/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <Parse/Parse.h>
#import "DMAddNoteViewController.h"
#import "DMImageCollectionViewController.h"
#import "DMLocationMapViewController.h"
#import "DMImageStore.h"
#import "DMSpinner.h"

@interface DMAddNoteViewController () {
    NSString *noNoteText;
    DMSpinner *spinner;
}

@property (nonatomic, weak) IBOutlet UITextView *noteText;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) DMImageStore *imageStore;

@end

@implementation DMAddNoteViewController

@synthesize delegate;

- (instancetype)initWithNote:(PFObject *)note {
    self = [super init];
    if (self) {
        if (note == nil) {
            PFObject *newNote = [[PFObject alloc] initWithClassName:@"Note"];
            [newNote setObject:[PFUser currentUser] forKey:@"user"];
            self.note = newNote;
        } else {
            self.note = note;
        }
        self.imageStore = [[DMImageStore alloc] initWithNote:self.note];
        
        noNoteText = @"Enter note here...";
    }
    return self;
}

- (void)viewDidLayoutSubviews {
    [self.noteText setContentOffset:CGPointZero animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.toolbar.barTintColor = [UIColor colorWithRed:0.05 green:0.47 blue:0.91 alpha:1.0];
    for (UIBarButtonItem *button in self.toolbar.items) {
        [button setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    }
    
    self.noteText.layer.borderColor = [[UIColor blackColor] CGColor];
    self.noteText.layer.borderWidth = 1.0;
    self.noteText.scrollEnabled = NO;
    
    UIBarButtonItem *flexKeyboard = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *cancelKeyboard = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(onKeyboardDone:)];
    
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    keyboardToolbar.barStyle = UIBarStyleDefault;
    keyboardToolbar.items = [NSArray arrayWithObjects:
                             flexKeyboard,
                             cancelKeyboard, nil];
    self.noteText.inputAccessoryView = keyboardToolbar;
    
    // Set gesture recogizers
    UITapGestureRecognizer *tapInTextField = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapInTextField:)];
    tapInTextField.numberOfTapsRequired = 1;
    tapInTextField.cancelsTouchesInView = NO;
    [self.noteText addGestureRecognizer:tapInTextField];
    
    UITapGestureRecognizer *tapOutTextField = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapOutsideTextField:)];
    tapOutTextField.numberOfTapsRequired = 1;
    tapOutTextField.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapOutTextField];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelNote:)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveNote:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = doneButton;
    
    // Set note properties
    NSString *noteStr = [self.note objectForKey:@"note"];
    if (noteStr == nil || noteStr.length == 0) {
        self.noteText.text = noNoteText;
    } else {
        self.noteText.text = noteStr;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Bar Button Actions

- (IBAction)onKeyboardDone:(id)sender {
    [self.noteText endEditing:YES];
    [self.noteText resignFirstResponder];
}

#pragma mark -
#pragma mark Gesture Recognizer Actions

- (IBAction)onTapInTextField:(id)sender {
    if ([self.noteText isFirstResponder]) {
        [self.noteText endEditing:YES];
        [self.noteText resignFirstResponder];
    } else {
        if ([self.noteText.text isEqualToString:noNoteText]) {
            self.noteText.text = @"";
        }
        [self.noteText becomeFirstResponder];
    }
}
                                                                                                        
- (IBAction)onTapOutsideTextField:(id)sender {
    if (self.noteText.text.length == 0) {
        self.noteText.text = noNoteText;
    }
    [self.noteText resignFirstResponder];
}

#pragma mark -
#pragma mark Interface Builder Actions

- (IBAction)imagesClicked:(id)sender {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    double itemSize = self.view.bounds.size.width / 3.0;
    [flowLayout setItemSize:CGSizeMake(itemSize, itemSize)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.minimumInteritemSpacing = 0.0f;
    
    DMImageCollectionViewController *imageCollectionController = [[DMImageCollectionViewController alloc] initWithCollectionViewLayout:flowLayout];
    imageCollectionController.note = self.note;
    imageCollectionController.imageStore = self.imageStore;
    [self.navigationController pushViewController:imageCollectionController animated:YES];
}

- (IBAction)locationClicked:(id)sender {
    DMLocationMapViewController *locationController = [[DMLocationMapViewController alloc] initWithNote:self.note];
    [self.navigationController pushViewController:locationController animated:YES];
}

#pragma mark -
#pragma mark Bar Button Actions

- (IBAction)cancelNote:(id)sender {
    [self.imageStore cancelAllChanges];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveNote:(id)sender {
    if ([self.note objectForKey:@"location"] == nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location not selected" message:@"You have to select a location" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if ([self.noteText.text isEqualToString:noNoteText] || self.noteText.text.length == 0) {
        UIAlertView *noNoteAlert = [[UIAlertView alloc] initWithTitle:@"Note text required" message:@"You need to fill in the note description" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [noNoteAlert show];
        return;
    }
    
    if (spinner == nil) {
        spinner = [[DMSpinner alloc] initWithView:self.view color:[UIColor greenColor]];
    }
    [spinner addSpinner];
    [self.imageStore applyWithBlock:^(NSArray *errors) {
        if (errors.count != 0) {
            for (NSError *error in errors) {
                NSLog(@"Image saving error: %@", error.description);
            }
        } else {
            [self.note setObject:self.noteText.text forKey:@"note"];
            [self.note saveInBackgroundWithTarget:self selector:@selector(onSavedNote:)];
        }
    }];
}

- (IBAction)onSavedNote:(id)sender {
    if (spinner != nil) {
        [spinner removeSpinner];
    }
    [self.delegate didDismissModalWindow];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
