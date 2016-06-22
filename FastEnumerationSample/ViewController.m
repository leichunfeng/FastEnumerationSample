//
//  ViewController.m
//  FastEnumerationSample
//
//  Created by leichunfeng on 16/6/22.
//  Copyright © 2016年 leichunfeng. All rights reserved.
//

#import "ViewController.h"
#import "Array.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Array *array = [[Array alloc] initWithCapacity:50];
    for (NSNumber *number in array) {
        NSLog(@"%@", number);
    }
}

@end
