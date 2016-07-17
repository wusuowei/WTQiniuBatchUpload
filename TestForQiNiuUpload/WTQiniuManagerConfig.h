//
//  WTQiniuManagerConfig.h
//  TestForQiNiuUpload
//
//  Created by 温天恩 on 16/7/17.
//  Copyright © 2016年 温. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QNUploadManager;

@interface WTQiniuManagerConfig : NSObject

/**
 *  七牛上传manager
 */
@property (nonatomic, strong, nonnull) QNUploadManager *qNUploadManager;
/**
 *  上传队列的最大并发数
 */
@property (nonatomic, assign) NSInteger uploadQueueMaxConcurrentOperationCount;

@end
