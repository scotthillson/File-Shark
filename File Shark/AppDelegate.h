//
//  AppDelegate.h
//  File Shark
//
//  Created by Scott Hillson on 2/5/14.
//  Copyright (c) 2014 Scott Hillson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SharkBrain.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property BOOL isRunning;
@property SharkBrain *sharkBrain;
@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *fileText;
@property (unsafe_unretained) IBOutlet NSTextView *errorText;
@property (unsafe_unretained) IBOutlet NSTextView *extensionText;

@property (weak) IBOutlet NSTabView *sharkTab;
@property (weak) IBOutlet NSTextField *sourceLabel;
@property (weak) IBOutlet NSTextField *destinationLabel;
@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSProgressIndicator *circularProgress;
@property (weak) IBOutlet NSMenuItem *menuSave;

@property (strong) NSURL *destination;
@property (strong) NSURL *source;
@property (strong) NSString *fileString;
@property (strong) NSString *extensionString;

- (IBAction)save:(id)sender;
- (IBAction)start:(id)sender;
- (IBAction)selectFile:(id)sender;
- (IBAction)selectSource:(id)sender;
- (IBAction)selectDestination:(id)sender;

- (void)writeErrors:(NSArray *)errors;
- (void)updateProgressIndicator:(double *)progress;

@end