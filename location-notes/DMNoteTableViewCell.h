//
//  DMNoteTableViewCell.h
//  location-notes
//
//  Created by Darin Minamoto on 9/10/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface DMNoteTableViewCell : PFTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *noteDescription;

@end
