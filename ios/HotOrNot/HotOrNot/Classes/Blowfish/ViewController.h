//
//  ViewController.h
//  BlowfishTest
//
//  Created by Prabu Arumugam on 23/03/13.
//  Copyright (c) 2013 CODEDING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlowfishAlgorithm.h"

@interface ViewController : UIViewController <UITextViewDelegate>
{
    IBOutlet UITextView *plainTextView;
    IBOutlet UITextView *cipherTextView;
    IBOutlet UIScrollView *controlsContainer;
    IBOutlet UISegmentedControl *encryptionModeControl;
}

//events

- (IBAction)encryptButton_touched:(id)sender;
- (IBAction)decryptButton_touched:(id)sender;

@end
