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

@interface ViewController ()

@property (nonatomic, strong) QNUploadManager *uploadManager;
@property (nonatomic, strong) AFHTTPSessionManager *httpManager;
@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@property (nonatomic, strong) NSURLSessionUploadTask *uploadTask;

@property (nonatomic, copy) NSMutableArray *uploadTasks;

@property (nonatomic, strong) NSProgress *progress;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.uploadManager = [QNUploadManager sharedInstanceWithConfiguration:nil];
    self.httpManager = [AFHTTPSessionManager manager];
    self.sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"jpg"];
////    NSData *imageData = [NSData dataWithContentsOfFile:path];
//    NSString *key = @"23453111/81A9C699-A62C-44C3-88BA-B00DE5119E4F/A4D60CEA-888C-4334-A7C8-EF788037D4E1.jpg";
//    NSString *token = @"a0h5P_uSX_opuu0veh0W3gBYxunaVmIjpgQur9BM:IYbeIx2h9BmGaIifnBSLo2im7YI=:eyJzY29wZSI6InFhLW1lZGljYWwtcHJpdmF0ZS1jb21tb24iLCJkZWFkbGluZSI6MTQ2NjA3NjUyOCwiY2FsbGJhY2tVcmwiOiJodHRwOi8vbWVkY2hhcnQucWEueGluZ3NodWxpbi5jb20vY2FzZWZvbGRlci1tZWRpY2FsL3Fpbml1Q2FsbGJhY2siLCJjYWxsYmFja0JvZHkiOiJuYW1lPSQoa2V5KVx1MDAyNmhhc2g9JChldGFnKSJ9";
//    for (NSInteger i = 0; i < 20; i++) {
//        [self.uploadManager putFile:path key:key token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
//            if (resp == nil) {
//                NSLog(@"----------失败   %@", info.error.description);
//            } else {
//                NSLog(@"---------成功");
//            }
//        } option:nil];
//    }
    NSMutableArray *uploadTasks = [NSMutableArray array];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"jpg"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    for (NSInteger i = 0; i < 1000; i++) {
        NSString *key = [NSString stringWithFormat:@"234642/2C24529B-3774-4827-BE33-2ED4DDBA8125/9EF9C203-6FF3-4CA0-926F-C30A0F9F5B1A%zd.jpeg", i];
        NSString *url = [NSString stringWithFormat:@"http://upload.qiniu.com?a=%zd", i];
        [uploadTasks addObject:[self uploadData:data key:key url:url]];
    }
}

- (void)beginUpload {
    NSMutableArray *uploadTasks = [NSMutableArray array];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"jpg"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    for (NSInteger i = 0; i < 100; i++) {
        NSString *key = [NSString stringWithFormat:@"%zd.jpeg", i];
        NSString *url = [NSString stringWithFormat:@"http://upload.server.com?a=%zd", i];
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
