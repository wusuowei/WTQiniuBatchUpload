//
//  WTOperation.m
//  TestOperation
//
//  Created by 温天恩 on 16/6/28.
//  Copyright © 2016年 温. All rights reserved.
//

#import "WTOperation.h"
#import <QiniuSDK.h>

NSString * const WTOperationLockName = @"WTOperationLockName";
//typedef NS_ENUM(NSInteger, WTOperationState) {
//    WTOperationStateReady       = 1,
//    WTOperationStateExecuting   = 2,
//    WTOperationStateFinished    = 3,
//};
//
//static inline NSString * AFKeyPathFromOperationState(WTOperationState state) {
//    switch (state) {
//        case WTOperationStateReady:
//            return @"isReady";
//        case WTOperationStateExecuting:
//            return @"isExecuting";
//        case WTOperationStateFinished:
//            return @"isFinished";
//        default: {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wunreachable-code"
//            return @"state";
//#pragma clang diagnostic pop
//        }
//    }
//}
//
//static inline BOOL AFStateTransitionIsValid(WTOperationState fromState, WTOperationState toState, BOOL isCancelled) {
//    switch (fromState) {
//        case WTOperationStateReady:
//            switch (toState) {
//                case WTOperationStateExecuting:
//                    return YES;
//                case WTOperationStateFinished:
//                    return isCancelled;
//                default:
//                    return NO;
//            }
//        case WTOperationStateExecuting:
//            switch (toState) {
//                case WTOperationStateFinished:
//                    return YES;
//                default:
//                    return NO;
//            }
//        case WTOperationStateFinished:
//            return NO;
//        default: {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wunreachable-code"
//            switch (toState) {
//                case WTOperationStateReady:
//                case WTOperationStateExecuting:
//                case WTOperationStateFinished:
//                    return YES;
//                default:
//                    return NO;
//            }
//        }
//#pragma clang diagnostic pop
//    }
//}

@interface WTOperation ()

@property (nonatomic, strong) QNUploadManager *uploadManager;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) void (^success)();
@property (nonatomic, copy) void (^failure)(NSError *error);

@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, copy) NSArray *runLoopModes;


@end

@implementation WTOperation

@synthesize executing = _executing;
@synthesize finished  = _finished;
@synthesize cancelled = _cancelled;

#pragma mark - init
+ (instancetype)operationWithUploadManager:(QNUploadManager *)uploadManager filePath:(NSString *)filePath key:(NSString *)key token:(NSString *)token success:(void (^)())success failure:(void (^)(NSError *))failure {
    WTOperation *operation = [[self alloc] initWithUploadManager:uploadManager filePath:filePath key:key token:token success:success failure:failure];
    return operation;
}

- (instancetype)initWithUploadManager:(QNUploadManager *)uploadManager filePath:(NSString *)filePath key:(NSString *)key token:(NSString *)token success:(void (^)())success failure:(void (^)(NSError *))failure {
    if (self = [super init]) {
        self.uploadManager = uploadManager;
        self.filePath = filePath;
        self.key = key;
        self.token = token;
        self.success = success;
        self.failure = failure;
        
        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = WTOperationLockName;
        self.runLoopModes = @[NSRunLoopCommonModes];
    }
    return self;
}

+ (void)networkRequestThreadEntryPoint:(id)__unused object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"WTAsyncOperation"];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

+ (NSThread *)operationThread {
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

#pragma mark - operation
- (void)cancel {
    [self.lock lock];
    NSLog(@"---------cancel %@", self);
    if (self.isCancelled || self.isFinished || self.isExecuting) {
        [self.lock unlock];
        return;
    }
    [super cancel];
    [self KVONotificationWithNotiKey:@"isCancelled" state:&_cancelled stateValue:YES];
    [self finish];
    [self.lock unlock];
}

- (void)start {
    if (self.isCancelled || self.isFinished || self.isExecuting) {
        NSLog(@"start %d %d %d %@", self.isCancelled, self.isFinished, self.isExecuting, self);
        return;
    }
    [self runSelector:@selector(startUpload)];
}

- (void)startUpload {
    if (self.isCancelled || self.isFinished || self.isExecuting) {
        return;
    }
    [self uploadFile];
}

- (void)uploadFile {
    [self KVONotificationWithNotiKey:@"isExecuting" state:&_executing stateValue:YES];
    NSLog(@"upload start %@", self);
    __weak typeof(self) weakSelf = self;
    [self.uploadManager putFile:self.filePath key:self.key token:self.token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        NSLog(@"---upload------结束 %@", weakSelf);
        if (weakSelf) {
            if (resp == nil) {
                weakSelf.failure(info.error);
            } else {
                weakSelf.success();
            }
            [weakSelf finish];
        }
    } option:nil];
}

- (void)finish {
    [self.lock lock];
    [self KVONotificationWithNotiKey:@"isExecuting" state:&_executing stateValue:NO];
    [self KVONotificationWithNotiKey:@"isFinished" state:&_finished stateValue:YES];
    NSLog(@"finish %@", self);
    [self.lock unlock];
}

- (BOOL)isAsynchronous {
    return YES;
}

- (void)KVONotificationWithNotiKey:(NSString *)key state:(BOOL *)state stateValue:(BOOL)stateValue {
    [self.lock lock];
    [self willChangeValueForKey:key];
    *state = stateValue;
    [self didChangeValueForKey:key];
    [self.lock unlock];
}

- (void)runSelector:(SEL)selecotr {
    [self performSelector:selecotr onThread:[[self class] operationThread] withObject:nil waitUntilDone:NO modes:self.runLoopModes];
}

@end
