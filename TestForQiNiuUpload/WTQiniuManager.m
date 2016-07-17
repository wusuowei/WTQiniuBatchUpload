//
//  WTQiniuManager.m
//  TestForQiNiuUpload
//
//  Created by 温天恩 on 16/7/17.
//  Copyright © 2016年 温. All rights reserved.
//

#import "WTQiniuManager.h"
#import "QNUploadManager.h"
#import "WTOperation.h"
#import "WTQiniuManagerConfig.h"

static WTQiniuManager *_shareManager;

@interface WTQiniuManager ()

@property (nonatomic, strong) QNUploadManager *qNUploadManager;
@property (nonatomic, strong) NSOperationQueue *uploadQueue;
@property (nonatomic, strong) dispatch_queue_t addOperationSerialQueue;

@end

@implementation WTQiniuManager

#pragma mark - upload 
- (void)uploadWithFilePath:(NSString *)filePath
                       key:(NSString *)key
                     token:(NSString *)token
                   success:(void (^)())success
                   failure:(void (^)(NSError * _Nullable))failure {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.addOperationSerialQueue, ^{
        if ([weakSelf isUploadingFile:key]) {
            NSLog(@"重复添加上传任务->\nkey:%@", key);
            return;
        }
        WTOperation *operation = [WTOperation operationWithUploadManager:weakSelf.qNUploadManager filePath:filePath key:key token:token success:success failure:failure];
        operation.wt_identifier = key;
        [weakSelf.uploadQueue addOperation:operation];
    });
}

- (BOOL)isUploadingFile:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"wt_identifier = %@", key];
    NSArray *filterResult = [self.uploadQueue.operations filteredArrayUsingPredicate:predicate];
    return filterResult.count > 0;
}

#pragma mark - cancel
- (void)cancelAffixUploadOperations {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.uploadQueue cancelAllOperations];
    });
}

#pragma mark - shareManager
+ (void)initialize {
    [super initialize];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_shareManager == nil) {
            _shareManager = [[WTQiniuManager alloc] init];
            _shareManager.uploadQueue = [[NSOperationQueue alloc] init];
            NSUInteger const WTFileUploadMaxConcurrentOperationCount = 3;
            _shareManager.uploadQueue.maxConcurrentOperationCount = WTFileUploadMaxConcurrentOperationCount;
            _shareManager.addOperationSerialQueue = dispatch_queue_create("com..QNUploadManagerAddOperationSerializeQueue", DISPATCH_QUEUE_SERIAL);
            _shareManager.qNUploadManager = [QNUploadManager sharedInstanceWithConfiguration:nil];
        }
    });
}

+ (instancetype)shareManager {
    return _shareManager;
}

+ (instancetype)shareManagerWithCinfig:(WTQiniuManagerConfig *)config {
    if (config) {
        if (config.uploadQueueMaxConcurrentOperationCount > 0) {
            _shareManager.uploadQueue.maxConcurrentOperationCount = config.uploadQueueMaxConcurrentOperationCount;
        }
        if (config.qNUploadManager) {
            _shareManager.qNUploadManager = config.qNUploadManager;
        }
    }
    return _shareManager;
}

- (instancetype)copy {
    return _shareManager;
}

@end
