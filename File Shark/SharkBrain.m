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
@synthesize alternates;
@synthesize filesAlreadySearched;
@synthesize allowCaptures;

- (void)directoryEnumerate {
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
                                             if ([error.localizedDescription rangeOfString:@"permission"].location == NSNotFound){
                                                 NSLog(@"%@", error);
                                             }
                                             else {
                                                 [errors addObject:@"Warning, permission issues were present."];
                                             }
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
    [self juiceHelper];
    AppDelegate *appDelegate = (AppDelegate *) [NSApp delegate];
    NSError *error = nil;
    NSURL *destination = appDelegate.destination;
    NSArray *files = [[appDelegate.fileString stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"] componentsSeparatedByString:@"\n"];
    NSArray *extensions = [[appDelegate.extensionString stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"] componentsSeparatedByString:@"\n"];
    [self directoryEnumerate];
    double count = files.count*extensions.count*urls.count;
    double progress = 0;
    int i = 1;
    for ( NSString *file in files){
        if (file.length){
            NSString *smallfile = [[[[file componentsSeparatedByString:@"."] objectAtIndex:0] componentsSeparatedByString:@"/"] lastObject];
            if ( ![filesAlreadySearched containsObject:file]){
                [filesAlreadySearched addObject:file];
                BOOL success = NO;
                NSString *alternate = nil;
                for ( NSURL *url in urls ){
                    NSString *urlFile = url.lastPathComponent;
                    NSString *extension = url.pathExtension;
                    BOOL haystackResult = NO;
                    if (appDelegate.allowCaptures){
                        haystackResult = [self juiceCompare:smallfile :urlFile];
                    }
                    else {
                        haystackResult = [smallfile caseInsensitiveCompare:urlFile] == NSOrderedSame;
                    }
                    
                    for ( NSString *targetExtension in extensions){
                        progress = (i/count)*100;
                        i++;
                        [appDelegate updateProgressIndicator:&progress];
                        if ( haystackResult ) {
                            if ( [targetExtension caseInsensitiveCompare:extension] == NSOrderedSame ){
                                success = YES;
                                [[NSFileManager defaultManager] copyItemAtURL:url toURL:[destination URLByAppendingPathComponent:urlFile] error:&error];
                                //if ( error ){??}
                            }
                            else {
                                alternate = urlFile;
                            }
                        }
                    }
                }
                if ( !success ){
                    NSString *message = [NSString stringWithFormat:@"%@%@", @"Couldn't find ", [[file componentsSeparatedByString:@"/"] lastObject]];
                    if (alternate.length){
                        message = [message stringByAppendingString:[NSString stringWithFormat:@"%@%@", @" with the given extension(s) but we did find ", alternate]];
                        [alternates addObject:alternate];
                    }
                    [errors  addObject:message];
                }
            }
        }
    }
    if (errors){
        dispatch_async(dispatch_get_main_queue(), ^{
            [appDelegate writeErrors:errors];
            errors = nil;
        });
    }
    urls = nil;
    filesAlreadySearched = nil;
}

- (void)juiceHelper {
    if (!errors) errors = [[NSMutableArray alloc] init];
    if (!alternates) alternates = [[NSMutableArray alloc] init];
}

- (BOOL)juiceCompare:(NSString *)needle :(NSString *)haystack {
    NSError *error = nil;
    NSRegularExpression *test = [NSRegularExpression regularExpressionWithPattern:needle options:NSRegularExpressionCaseInsensitive error:&error];
    NSInteger numberOfMatches = [test numberOfMatchesInString:haystack options:0 range:NSMakeRange(0, [haystack length])];
    return numberOfMatches ? YES : NO;
}

- (void)collectAlternates {
    AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
    NSURL *destination = appDelegate.destination;
    NSError *error = nil;
    [self directoryEnumerate]; // I almost didn't do this, but there's a possibility that our files have changed.
    for (NSString *alternate in alternates){
        for ( NSURL *url in urls ){
            NSString *urlFile = url.lastPathComponent;
            if ([alternate isEqualToString:urlFile]){
                [[NSFileManager defaultManager] copyItemAtURL:url toURL:[destination URLByAppendingPathComponent:alternate] error:&error];
            }
        }
    }
}

@end