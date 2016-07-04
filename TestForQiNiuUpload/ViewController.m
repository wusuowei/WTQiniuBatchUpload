//
//  ViewController.m
//  TestForQiNiuUpload
//
//  Created by 无所谓 on 16/2/23.
//  Copyright © 2016年 温. All rights reserved.
//

#import "ViewController.h"
#import <QiniuSDK.h>
#import <AFNetworking.h>
#import "WTOperation.h"

@interface ViewController ()

@property (nonatomic, strong) QNUploadManager *uploadManager;
@property (nonatomic, strong) NSOperationQueue *uploadOperationQueue;

@property (nonatomic, strong) AFHTTPSessionManager *httpManager;
@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@property (nonatomic, copy) NSMutableArray *uploadTasks;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupQiniuUpload];
    self.httpManager = [AFHTTPSessionManager manager];
    self.sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:nil];
}

- (void)setupQiniuUpload {
    QNConfiguration *configuration = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.timeoutInterval = 10;
    }];
    self.uploadManager = [QNUploadManager sharedInstanceWithConfiguration:configuration];
    self.uploadOperationQueue = [[NSOperationQueue alloc] init];
    self.uploadOperationQueue.maxConcurrentOperationCount = 3;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self qiniuUpload];
}

#pragma mark - qiniu
- (void)qiniuUpload {
    NSLog(@"operationCount-----%zd", self.uploadOperationQueue.operationCount);
    if (self.uploadOperationQueue.operationCount > 0) {
        [self.uploadOperationQueue cancelAllOperations];
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"jpg"];
    NSString *key = @"123456.jpg";
    NSString *token = [self token];
    for (NSInteger i = 0; i < 100; i++) {
        WTOperation *operation = [WTOperation operationWithUploadManager:self.uploadManager filePath:path key:key token:token success:^{
            NSLog(@"---------成功");
        } failure:^(NSError *error) {
            NSLog(@"----------失败   %@", error.description);
        }];
        [self.uploadOperationQueue addOperation:operation];
    }
}

- (NSString *)token {
    return @"a0h5P_uSX_opuu0veh0W3gBYxunaVmIjpgQur9BM:VPCqeNsYV0saNAHSslys7WoB0lY=:eyJzY29wZSI6InFhLW1lZGljYWwtcHJpdmF0ZS1jb21tb24iLCJkZWFkbGluZSI6MTQ2NzM2MTY0M30=";
}

#pragma mark - custom
- (void)beginUpload {
    NSMutableArray *uploadTasks = [NSMutableArray array];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"jpg"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    for (NSInteger i = 0; i < 1000; i++) {
        NSString *key = [NSString stringWithFormat:@"234642/2C24529B-3774-4827-BE33-2ED4DDBA8125/9EF9C203-6FF3-4CA0-926F-C30A0F9F5B1A%zd.jpeg", i];
        NSString *url = [NSString stringWithFormat:@"http://upload.qiniu.com?a=%zd", i];
        [uploadTasks addObject:[self uploadData:data key:key url:url]];
    }
}

- (NSURLSessionUploadTask *)uploadData:(NSData *)data key:(NSString *)key url:(NSString *)url{
    NSDictionary *params = @{@"key": key,
                             @"token": @"a0h5P_uSX_opuu0veh0W3gBYxunaVmIjpgQur9BM:0frqrjlj_g2R53WJGEstqXIaM34=:eyJzY29wZSI6InFhLW1lZGljYWwtcHJpdmF0ZS1jb21tb24iLCJkZWFkbGluZSI6MTQ2NjM1NDY1MiwiY2FsbGJhY2tVcmwiOiJodHRwOi8vbWVkY2hhcnQucWEueGluZ3NodWxpbi5jb20vY2FzZWZvbGRlci1tZWRpY2FsL3Fpbml1Q2FsbGJhY2siLCJjYWxsYmFja0JvZHkiOiJuYW1lPSQoa2V5KVx1MDAyNmhhc2g9JChldGFnKSJ9"};
    NSMutableURLRequest *request = [self.httpManager.requestSerializer
                                    multipartFormRequestWithMethod:@"POST"
                                    URLString:url
                                    parameters:params
                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                        [formData appendPartWithFileData:data name:@"file" fileName:key mimeType:@"application/octet-stream"];
                                    }
                                    
                                    error:nil];
    request.timeoutInterval = 10;
    NSURLSessionUploadTask *uploadTask = [self.httpManager uploadTaskWithRequest:request fromData:nil progress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error == nil) {
            NSLog(@"文件上传成功");
        } else {
            NSLog(@"文件上传失败 -> %@", error.userInfo[@"NSErrorFailingURLStringKey"]);
        }
    }];
    [uploadTask resume];
    return uploadTask;
}

@end
