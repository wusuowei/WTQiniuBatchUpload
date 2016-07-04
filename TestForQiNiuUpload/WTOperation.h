//
//  WTOperation.h
//  TestOperation
//
//  Created by 温天恩 on 16/6/28.
//  Copyright © 2016年 温. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QNUploadManager;

@interface WTOperation : NSOperation

+ (instancetype)operationWithUploadManager:(QNUploadManager *)uploadManager
                                  filePath:(NSString *)filePath
                                  key:(NSString *)key
                                token:(NSString *)token
                              success:(void(^)())success
                              failure:(void(^)(NSError *error))failure;
- (instancetype)initWithUploadManager:(QNUploadManager *)uploadManager
                             filePath:(NSString *)filePath
                             key:(NSString *)key
                           token:(NSString *)token
                         success:(void (^)())success
                         failure:(void (^)(NSError *))failure;

@end
