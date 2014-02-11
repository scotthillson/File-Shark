//
//  SharkBrain.h
//  File Shark
//
//  Created by Scott Hillson on 2/6/14.
//  Copyright (c) 2014 Scott Hillson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharkBrain : NSObject

@property (strong) NSMutableArray *urls;
@property (strong) NSMutableArray *errors;
@property (strong) NSMutableArray *filesAlreadySearched;

- (void)directoryEnumerate;
- (void)juice;

@end
