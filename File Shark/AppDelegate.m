//
//  AppDelegate.m
//  File Shark
//
//  Created by Scott Hillson on 2/5/14.
//  Copyright (c) 2014 Scott Hillson. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize sharkBrain;
@synthesize viewController;

@synthesize cancel;
@synthesize window;
@synthesize isRunning;
@synthesize fileText;
@synthesize errorText;
@synthesize extensionText;
@synthesize sharkTab;
@synthesize sourceLabel;
@synthesize destinationLabel;
@synthesize progressBar;
@synthesize circularProgress;
@synthesize source;
@synthesize destination;
@synthesize fileString;
@synthesize extensionString;
@synthesize alternateButton;
@synthesize allowButton;
@synthesize allowCaptures;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [sharkTab selectFirstTabViewItem:self];
    sharkBrain = [[SharkBrain alloc] init];
    [extensionText setString:@"TIF\nPSD\nCR2\nMOS\nJPG\nIIQ\nNEF"];
}

- (IBAction)start:(id)sender {
    fileString = [fileText string];
    extensionString = [extensionText string];
    if (destination == nil) {
        NSAlert *destAlert = [[NSAlert alloc] init];
        [destAlert addButtonWithTitle:@"OK"];
        [destAlert setMessageText:@"You must select a destination folder first."];
        [destAlert runModal];
    }
    else if ( fileString.length < 3 ){
        NSAlert *fileAlert = [[NSAlert alloc] init];
        [fileAlert addButtonWithTitle:@"OK"];
        [fileAlert setMessageText:@"You must select or paste a list of file names first."];
        [fileAlert runModal];
    }
    else if ( extensionString.length < 3 ) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"You must have at least one extension listed."];
        [alert runModal];
    }
    else {
        if (isRunning == NO){
            isRunning = YES;
            if (progressBar.isHidden){
                [progressBar setHidden:NO];
            }
            dispatch_queue_t fileQueue = dispatch_queue_create("File Queue",NULL);
            dispatch_async(fileQueue, ^{
                [sharkBrain juice];
                isRunning = NO;
                [progressBar setHidden:YES];
                [self updateProgressIndicator:0];
            });
        }
    }
}

- (IBAction)selectFile:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    // This method displays the panel and returns immediately.
    // The completion handler is called when the user selects an
    // item or cancels the panel.
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSURL  *docURL = [[panel URLs] objectAtIndex:0];
            NSString *fileContent = [NSString stringWithContentsOfURL:docURL encoding:NSUTF8StringEncoding error:NULL];
            [fileText setString: [NSString stringWithFormat:@"%@", fileContent]];
        }
    }];
}

- (IBAction)selectSource:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result ==NSFileHandlingPanelOKButton) {
            source = [[panel URLs] objectAtIndex:0];
            [sourceLabel setStringValue:[ NSString stringWithFormat:@"%@%@%@", @"Source: /", source.lastPathComponent, @"/"]];
        }
    }];
}

- (IBAction)selectDestination:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result ==NSFileHandlingPanelOKButton) {
            destination = [[panel URLs] objectAtIndex:0];
            [destinationLabel  setStringValue:[ NSString stringWithFormat:@"%@%@", @"Destination: ", destination.path]];
        }
    }];
}

- (IBAction)gatherAlternates:(id)sender {
    if (isRunning == NO){
        isRunning = YES;
        if (progressBar.isHidden){
            [progressBar setHidden:NO];
        }
        dispatch_queue_t fileQueue = dispatch_queue_create("File Queue",NULL);
        dispatch_async(fileQueue, ^{
            [sharkBrain collectAlternates];
            isRunning = NO;
            [progressBar setHidden:YES];
            [self updateProgressIndicator:0];
        });
    }
    
}

- (IBAction)allowCaptures:(id)sender {
    if (allowCaptures){
        allowCaptures = NO;
        [allowButton highlight:NO];
        [allowButton setTitle:@"Allow Captures?"];
    }
    else {
        allowCaptures = YES;
        [allowButton highlight:YES];
        [allowButton setTitle:@"Allow Captures"];
    }
    
}

- (IBAction)save:(id)sender {
    if ([[errorText string] length]){
        NSSavePanel *panel = [NSSavePanel savePanel];
        [panel setNameFieldStringValue:@"sharkErrors.txt"];
        [panel beginSheetModalForWindow:window completionHandler:^(NSInteger result){
            if (result == NSFileHandlingPanelOKButton) {
                NSURL *url = [panel URL];
                NSError *error = nil;
                [[errorText string] writeToURL:url atomically:YES encoding:NSUnicodeStringEncoding error:&error];
            }
        }];
    }
}

- (void)updateProgressIndicator:(double *)progress{
    if (progressBar.isHidden == NO){
        [progressBar setDoubleValue:*progress];
    }
}

- (void)writeErrors:(NSArray *)errors{
    //write the error array into the error browser
    [errorText setString:[errors componentsJoinedByString:@"\n"]];
    [sharkTab selectLastTabViewItem:self];
    if (sharkBrain.alternates){
        [alternateButton setHidden:NO];
    }
}

@end