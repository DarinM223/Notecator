//
//  DMAddNoteViewController.m
//  location-notes
//
//  Created by Darin Minamoto on 9/3/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <Parse/Parse.h>
#import "DMAddNoteViewController.h"

@interface DMAddNoteViewController ()

@end

@implementation DMAddNoteViewController

- (instancetype)initWithNote:(PFObject *)note {
    self = [super init];
    if (self) {
        self.note = note;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelNote:)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveNote:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)cancelNote:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveNote:(id)sender {
    // TODO(darin): implement saving of note
    if (self.note == nil) {
        // Create and save new note
        PFObject *newNote = [[PFObject alloc] initWithClassName:@"Note"];
        [newNote setObject:[PFUser currentUser] forKey:@"user"];
        [newNote setObject:@"Hello" forKey:@"note"];
        [newNote saveInBackgroundWithTarget:self selector:@selector(onSavedNote:)];
    } else {
        // Save existing note
        [self.note saveInBackgroundWithTarget:self selector:@selector(onSavedNote:)];
    }
}

- (IBAction)onSavedNote:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
