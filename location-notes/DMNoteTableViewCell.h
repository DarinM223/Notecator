//
//  DMNoteTableViewCell.h
//  location-notes
//
//  Created by Darin Minamoto on 9/10/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@class DMImageStore;
@class CLLocation;
@class DMImagePreviewView;

@interface DMNoteTableViewCell : PFTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *noteDescription;
@property (nonatomic, weak) IBOutlet UILabel *locationDescription;

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, getter=setNote) PFObject *note;

@end
