//
//  ViewController.m
//  BlowfishTest
//
//  Created by Prabu Arumugam on 23/03/13.
//  Copyright (c) 2013 CODEDING. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

NSString *key = @"aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ";
NSString *initVector = @"1a2b3c4d";

////////////////
//UIView methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    plainTextView.delegate = self;
    cipherTextView.delegate = self;
    [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

////////////////
//control-events

- (IBAction)encryptButton_touched:(id)sender
{
    NSString *modeString = [encryptionModeControl titleForSegmentAtIndex:encryptionModeControl.selectedSegmentIndex];
    BlowfishAlgorithm *blowFish = [BlowfishAlgorithm new];
    [blowFish setMode:[BlowfishAlgorithm buildModeEnum:modeString]];
    [blowFish setKey:key];
    [blowFish setInitVector:initVector];
    [blowFish setupKey];
    
    NSString *plainText = plainTextView.text;
    NSString *cipherText = [blowFish encrypt:plainText];
    
    NSLog(@"plain-text: %@", plainText);
    NSLog(@"cipher-text: %@", cipherText);
    
    cipherTextView.text = cipherText;
    [plainTextView resignFirstResponder];
}

- (IBAction)decryptButton_touched:(id)sender
{
    NSString *modeString = [encryptionModeControl titleForSegmentAtIndex:encryptionModeControl.selectedSegmentIndex];
    BlowfishAlgorithm *blowFish = [BlowfishAlgorithm new];
    [blowFish setMode:[BlowfishAlgorithm buildModeEnum:modeString]];
    [blowFish setKey:key];
    [blowFish setInitVector:initVector];
    [blowFish setupKey];
    
    NSString *cipherText = cipherTextView.text;
    NSString *plainText = [blowFish decrypt:cipherText];
    
    NSLog(@"cipher-text: %@", cipherText);
    NSLog(@"plain-text: %@", plainText);
    
    plainTextView.text = plainText;
    [cipherTextView resignFirstResponder];
}

/////////////////////
//UITextField methods

UITextView *activeTextView;

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    activeTextView = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    activeTextView = nil;
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (activeTextView == plainTextView) return;
    
    //scroll-up the container to show cipher-text-field
    [controlsContainer setContentOffset:CGPointMake(0.0, 210) animated:YES];
    [controlsContainer setScrollEnabled:NO];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if (activeTextView == plainTextView) return;
    
    //reset the container
    [controlsContainer setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    [controlsContainer setScrollEnabled:YES];
}

@end
