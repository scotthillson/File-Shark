//
//  SharkBrain.m
//  File Shark
//
//  Created by Scott Hillson on 2/6/14.
//  Copyright (c) 2014 Scott Hillson. All rights reserved.
//

#import "SharkBrain.h"
#import "AppDelegate.h"

@implementation SharkBrain

@synthesize urls;
@synthesize errors;
@synthesize filesAlreadyCopied;
@synthesize filesAlreadySearched;

- (void)directoryEnumerate{
    AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
    [appDelegate.circularProgress startAnimation:self];
    NSURL *source = appDelegate.source;
    if (!urls) urls = [[NSMutableArray alloc] init];
    NSArray *keys = [NSArray arrayWithObjects:
                     NSURLIsDirectoryKey, NSURLIsPackageKey, NSURLLocalizedNameKey, nil];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]
                                         enumeratorAtURL:source
                                         includingPropertiesForKeys:keys
                                         options:(NSDirectoryEnumerationSkipsHiddenFiles)
                                         errorHandler:^(NSURL *url, NSError *error) {
                                             // Return YES if the enumeration should continue after the eror.
                                             NSLog(@"%@", error);
                                             return YES;
                                         }];
    for (NSURL *url in enumerator) {
        // Error-checking is omitted for clarity.
        NSNumber *isDirectory = nil;
        [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        NSString *pathName = nil;
        [url getResourceValue:&pathName forKey:NSURLLocalizedNameKey error:NULL];
        NSNumber *isPackage = nil;
        [url getResourceValue:&isPackage forKey:NSURLIsPackageKey error:NULL];
        if ([isDirectory boolValue]) {
            //Just a folder, do nothing.
        }
        else {
            [urls addObject:url];
        }
    }
    [appDelegate.circularProgress stopAnimation:self];
}

- (void)juice{
    AppDelegate *appDelegate = (AppDelegate *) [NSApp delegate];
    NSError *error = nil;
    NSURL *destination = appDelegate.destination;
    NSArray *files = [[appDelegate.fileString stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"] componentsSeparatedByString:@"\n"];
    NSArray *extensions = [[appDelegate.extensionString stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"] componentsSeparatedByString:@"\n"];
    [self directoryEnumerate];
    [appDelegate.circularProgress setHidden:YES];
    double filesCount = files.count;
    double extensionCount = extensions.count;
    double urlCount = urls.count;
    int count = filesCount * extensionCount * urlCount;
    double progress = 0;
    int i = 1;
    for ( NSString *targetFile in files){
        if (targetFile.length){
            if ( ![filesAlreadySearched containsObject:targetFile]){
                [filesAlreadySearched addObject:targetFile];
                BOOL success = NO;
                for ( NSString *targetExtension in extensions){
                    for ( NSURL *url in urls ){
                        NSString *extension = url.pathExtension;
                        NSString *file = url.lastPathComponent;
                        progress = i/count;
                        i++;
                        [appDelegate updateProgressIndicator:&progress];
                        if ( [targetExtension caseInsensitiveCompare:extension] == NSOrderedSame ){
                            NSRegularExpression *test = [NSRegularExpression regularExpressionWithPattern:[[[[targetFile componentsSeparatedByString:@"."] objectAtIndex:0] componentsSeparatedByString:@"/"] lastObject] options:NSRegularExpressionCaseInsensitive error:&error];
                            NSInteger numberOfMatches = [test numberOfMatchesInString:file options:0 range:NSMakeRange(0, [file length])];
                            if ( numberOfMatches ) {
                                success = YES;
                                [[NSFileManager defaultManager] copyItemAtURL:url toURL:[destination URLByAppendingPathComponent:file] error:&error];
                                if ( error ){
                                    
                                }
                            }
                        }
                    }
                }
                if ( !success ){
                    if (!errors) errors = [[NSMutableArray alloc] init];
                    [errors  addObject:[NSString stringWithFormat:@"%@%@", @"Couldn't find ", [[targetFile componentsSeparatedByString:@"/"] lastObject]]];
                }
            }
        }
    }
    if (errors){
        [appDelegate writeErrors:errors];
    }
}

@end