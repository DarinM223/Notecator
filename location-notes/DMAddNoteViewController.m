//
//  DMAddNoteViewController.m
//  location-notes
//
//  Created by Darin Minamoto on 9/3/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <Parse/Parse.h>
#import "DMAddNoteViewController.h"

@interface DMAddNoteViewController () {
    NSString *noNoteText;
}

@property (nonatomic, weak) IBOutlet UITextView *noteText;

@end

@implementation DMAddNoteViewController

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
        
        noNoteText = @"Enter note here...";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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

#pragma mark - Gesture Recognizer Actions

- (IBAction)onTapInTextField:(id)sender {
    if ([self.noteText.text isEqualToString:noNoteText]) {
        self.noteText.text = @"";
    }
    [self.noteText becomeFirstResponder];
}
                                                                                                        
- (IBAction)onTapOutsideTextField:(id)sender {
    if (self.noteText.text.length == 0) {
        self.noteText.text = noNoteText;
    }
    [self.noteText resignFirstResponder];
}

#pragma mark - Interface Builder Actions

- (IBAction)imagesClicked:(id)sender {
    NSLog(@"Images clicked!");
}

- (IBAction)locationClicked:(id)sender {
    NSLog(@"Location clicked!");
}

#pragma mark - Bar Button Actions

- (IBAction)cancelNote:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveNote:(id)sender {
    NSLog(@"Note text: %@", self.noteText.text);
    if ([self.noteText.text isEqualToString:noNoteText] || self.noteText.text.length == 0) {
        UIAlertView *noNoteAlert = [[UIAlertView alloc] initWithTitle:@"Note text required" message:@"You need to fill in the note description" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [noNoteAlert show];
    } else {
        [self.note setObject:self.noteText.text forKey:@"note"];
        [self.note saveInBackgroundWithTarget:self selector:@selector(onSavedNote:)];
    }
}

- (IBAction)onSavedNote:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
