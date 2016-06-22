//
//  Array.h
//  FastEnumerationSample
//
//  Created by leichunfeng on 16/6/22.
//  Copyright © 2016年 leichunfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Array : NSObject <NSFastEnumeration>

- (instancetype)initWithCapacity:(NSUInteger)numItems;

@end
