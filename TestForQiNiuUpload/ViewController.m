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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupQiniuUpload];
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
    return @"uploadToken";
}

@end
