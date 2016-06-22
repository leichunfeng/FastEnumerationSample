//
//  Array.mm
//  FastEnumerationSample
//
//  Created by leichunfeng on 16/6/22.
//  Copyright © 2016年 leichunfeng. All rights reserved.
//

#import "Array.h"
#include <vector>

@implementation Array {
    std::vector<NSNumber *> _list;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    self = [super init];
    if (self) {
        for (NSUInteger i = 0; i < numItems; i++) {
            _list.push_back(@(random()));
        }
    }
    return self;
}

#define USE_STACKBUF 1

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])stackbuf count:(NSUInteger)len {
    // 这个方法的返回值，即我们需要返回的 C 数组的长度
    NSUInteger count = 0;
    
    // 我们前面已经知道了，这个方法是会被多次调用的
    // 因此，我们需要使用 state->state 来保存当前遍历到了 _list 的什么位置
    unsigned long countOfItemsAlreadyEnumerated = state->state;
    
    // 当 countOfItemsAlreadyEnumerated 为 0 时，表示第一次调用这个方法
    // 我们可以在这里做一些初始化的设置
    if (countOfItemsAlreadyEnumerated == 0) {
        // 我们前面已经提到了，state->mutationsPtr 是用来追踪集合在遍历过程中的突变的
        // 它不能为 NULL ，并且也不应该指向 self
        //
        // 这里，因为我们的 Array 类是不可变的，所以我们不需要追踪它的突变
        // 因此，我们的做法是将它指向 state->extra 的其中一个值
        // 因为我们知道 NSFastEnumeration 协议本身并没有用到 state->extra
        //
        // 但是，如果你的集合是可变的，那么你可以考虑将 state->mutationsPtr 指向一个内部变量
        // 而这个内部变量的值会在你的集合突变时发生变化
        state->mutationsPtr = &state->extra[0];
    }
    
#if USE_STACKBUF
    
    // 判断我们是否已经遍历完 _list
    if (countOfItemsAlreadyEnumerated < _list.size()) {
        // 我们知道 state->itemsPtr 就是这个方法返回的 C 数组指针，它不能为 NULL
        // 这里，我们将 state->itemsPtr 指向调用者提供的 C 数组 stackbuf
        state->itemsPtr = stackbuf;
        
        // 将 _list 中的值填充到 stackbuf 中，直到以下两个条件中的任意一个满足时为止
        // 1. 已经遍历完 _list 中的元素
        // 2. 已经填充满 stackbuf
        while (countOfItemsAlreadyEnumerated < _list.size() && count < len) {
            // 取出 _list 中的元素填充到 stackbuf 中
            stackbuf[count] = _list[countOfItemsAlreadyEnumerated];
            
            // 更新我们的遍历位置
            countOfItemsAlreadyEnumerated++;
            
            // 更新我们返回的 C 数组的长度，使之与 state->itemsPtr 中的元素个数相匹配
            count++;
        }
    }
    
#else
    
    // 判断我们是否已经遍历完 _list
    if (countOfItemsAlreadyEnumerated < _list.size()) {
        // 直接将 state->itemsPtr 指向内部的 C 数组指针，因为它的内存地址是连续的
        __unsafe_unretained const id * const_array = _list.data();
        state->itemsPtr = (__typeof__(state->itemsPtr))const_array;
        
        // 因为我们一次性返回了 _list 中的所有元素
        // 所以，countOfItemsAlreadyEnumerated 和 count 的值均为 _list 中的元素个数
        countOfItemsAlreadyEnumerated = _list.size();
        count = _list.size();
    }
    
#endif
    
    // 将本次调用得到的 countOfItemsAlreadyEnumerated 保存到 state->state 中
    // 因为 NSFastEnumeration 协议本身并没有用到 state->state
    // 所以，我们可以将这个值一直保留到下一次调用时使用
    state->state = countOfItemsAlreadyEnumerated;
    
    // 返回 C 数组的长度
    return count;
}

@end
