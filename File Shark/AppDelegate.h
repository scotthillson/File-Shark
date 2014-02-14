//
//  AppDelegate.h
//  File Shark
//
//  Created by Scott Hillson on 2/5/14.
//  Copyright (c) 2014 Scott Hillson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SharkBrain.h"
#import "ViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property SharkBrain *sharkBrain;
@property ViewController *viewController;

@property BOOL cancel;
@property BOOL isRunning;
@property BOOL allowCaptures;

@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSTextView *fileText;
@property (strong) IBOutlet NSTextView *errorText;
@property (strong) IBOutlet NSTextView *extensionText;

@property (weak) IBOutlet NSTabView *sharkTab;
@property (weak) IBOutlet NSTextField *sourceLabel;
@property (weak) IBOutlet NSTextField *destinationLabel;
@property (strong) IBOutlet NSButton *alternateButton;
@property (strong) IBOutlet NSButton *allowButton;
@property (strong) IBOutlet NSProgressIndicator *progressBar;
@property (strong) IBOutlet NSProgressIndicator *circularProgress;

@property (strong) NSURL *destination;
@property (strong) NSURL *source;
@property (strong) NSString *fileString;
@property (strong) NSString *extensionString;

- (IBAction)save:(id)sender;
- (IBAction)start:(id)sender;
- (IBAction)selectFile:(id)sender;
- (IBAction)selectSource:(id)sender;
- (IBAction)selectDestination:(id)sender;
- (IBAction)gatherAlternates:(id)sender;
- (IBAction)allowCaptures:(id)sender;

- (void)writeErrors:(NSArray *)errors;
- (void)updateProgressIndicator:(double *)progress;

@end