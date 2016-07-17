//
//  WTQiniuManager.h
//  TestForQiNiuUpload
//
//  Created by 温天恩 on 16/7/17.
//  Copyright © 2016年 温. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QNUploadManager, WTQiniuManagerConfig;

@interface WTQiniuManager : NSObject

@property (nonatomic, assign) NSInteger max;

+ (nonnull instancetype)shareManager;
+ (nonnull instancetype)shareManagerWithCinfig:(WTQiniuManagerConfig * _Nullable)config;

/**
 *  将文件上传任务添加到队列
 *
 *  @param filePath 文件路径
 *  @param key      上传到七牛的key
 *  @param token    上传token
 *  @param success  成功回调
 *  @param failure  失败回调
 */
- (void)uploadWithFilePath:(NSString * _Nonnull)filePath
                       key:(NSString * _Nonnull)key
                     token:(NSString * _Nonnull)token
                   success:(nullable void(^)())success
                   failure:(nullable void(^)(NSError * _Nullable error))failure;

/**
 *  取消所有文件上传任务
 */
- (void)cancelUploadOperations;

@end
