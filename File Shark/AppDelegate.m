//
//  AppDelegate.m
//  File Shark
//
//  Created by Scott Hillson on 2/5/14.
//  Copyright (c) 2014 Scott Hillson. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

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
@synthesize sharkBrain;
@synthesize fileString;
@synthesize extensionString;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [sharkTab selectFirstTabViewItem:self];
    [extensionText setString:@"TIF\nPDS\nCR2\nMOS\nJPG\nIIQ\nNEF"];
}

- (void)exportDocument {
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

- (IBAction)start:(id)sender {
    sharkBrain = [[SharkBrain alloc] init];
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
            dispatch_queue_t fileQueue = dispatch_queue_create("File Queue",NULL);
            dispatch_async(fileQueue, ^{
                [self.sharkBrain juice]; // hit the juice
                isRunning = NO;
                [progressBar setHidden:YES];
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

- (IBAction)save:(id)sender {
    if ([[errorText string] length]){
        [self exportDocument];
    }
}

- (void)updateProgressIndicator:(double *)progress{
    [progressBar setDoubleValue:*progress];
}

- (void)writeErrors:(NSArray *)errors{
    //write the error array into the error browser
    dispatch_queue_t errorWrite = dispatch_queue_create("Error Queue",NULL);
    dispatch_async(errorWrite, ^{
        [errorText setString:[errors componentsJoinedByString:@"\n"]];
        [sharkTab selectLastTabViewItem:self];
    });
}

@end