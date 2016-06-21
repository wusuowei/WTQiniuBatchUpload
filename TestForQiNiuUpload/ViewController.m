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
    QNConfiguration *configuration = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.timeoutInterval = 10;
    }];
    self.uploadManager = [QNUploadManager sharedInstanceWithConfiguration:configuration];
//    self.httpManager = [AFHTTPSessionManager manager];
//    self.sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self qiniuUpload];
}

- (void)qiniuUpload {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"jpg"];
    NSString *key = @"123456.jpg";
    NSString *token = @"1AXRtAuXagE1dTL3onHnV9vP262l7ZD-J8VjZd0W:rRD_voTbA6ZysZK0b8TggX-9WCw=:eyJzY29wZSI6InByb2QtbWVkaWNhbC1wcml2YXRlLWNvbW1vbiIsImRlYWRsaW5lIjoxNDY2NDk0NzE0LCJjYWxsYmFja1VybCI6Imh0dHA6Ly9tZWRjaGFydC54aW5nc2h1bGluLmNvbS9jYXNlZm9sZGVyLW1lZGljYWwvcWluaXVDYWxsYmFjayIsImNhbGxiYWNrQm9keSI6Im5hbWU9JChrZXkpXHUwMDI2aGFzaD0kKGV0YWcpIn0=";
    for (NSInteger i = 0; i < 100; i++) {
        [self.uploadManager putFile:path key:key token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            if (resp == nil) {
                NSLog(@"----------失败   %@", info.error.description);
            } else {
                NSLog(@"---------成功");
            }
        } option:nil];
    }
    NSLog(@"七牛上传文件");
}

//- (void)beginUpload {
//    NSMutableArray *uploadTasks = [NSMutableArray array];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"jpg"];
//    NSData *data = [NSData dataWithContentsOfFile:path];
//    for (NSInteger i = 0; i < 1000; i++) {
//        NSString *key = [NSString stringWithFormat:@"234642/2C24529B-3774-4827-BE33-2ED4DDBA8125/9EF9C203-6FF3-4CA0-926F-C30A0F9F5B1A%zd.jpeg", i];
//        NSString *url = [NSString stringWithFormat:@"http://upload.qiniu.com?a=%zd", i];
//        [uploadTasks addObject:[self uploadData:data key:key url:url]];
//    }
//}
//
//- (NSURLSessionUploadTask *)uploadData:(NSData *)data key:(NSString *)key url:(NSString *)url{
//    NSDictionary *params = @{@"key": key,
//                             @"token": @"a0h5P_uSX_opuu0veh0W3gBYxunaVmIjpgQur9BM:0frqrjlj_g2R53WJGEstqXIaM34=:eyJzY29wZSI6InFhLW1lZGljYWwtcHJpdmF0ZS1jb21tb24iLCJkZWFkbGluZSI6MTQ2NjM1NDY1MiwiY2FsbGJhY2tVcmwiOiJodHRwOi8vbWVkY2hhcnQucWEueGluZ3NodWxpbi5jb20vY2FzZWZvbGRlci1tZWRpY2FsL3Fpbml1Q2FsbGJhY2siLCJjYWxsYmFja0JvZHkiOiJuYW1lPSQoa2V5KVx1MDAyNmhhc2g9JChldGFnKSJ9"};
//    NSMutableURLRequest *request = [self.httpManager.requestSerializer
//                                    multipartFormRequestWithMethod:@"POST"
//                                    URLString:url
//                                    parameters:params
//                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//                                        [formData appendPartWithFileData:data name:@"file" fileName:key mimeType:@"application/octet-stream"];
//                                    }
//                                    
//                                    error:nil];
//    request.timeoutInterval = 10;
//    NSURLSessionUploadTask *uploadTask = [self.httpManager uploadTaskWithRequest:request fromData:nil progress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//        if (error == nil) {
//            NSLog(@"文件上传成功");
//        } else {
//            NSLog(@"文件上传失败 -> %@", error.userInfo[@"NSErrorFailingURLStringKey"]);
//        }
//    }];
//    [uploadTask resume];
//    return uploadTask;
//}

@end
