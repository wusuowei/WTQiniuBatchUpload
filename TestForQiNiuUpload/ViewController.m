//
//  ViewController.m
//  TestForQiNiuUpload
//
//  Created by 无所谓 on 16/2/23.
//  Copyright © 2016年 温. All rights reserved.
//

#import "ViewController.h"
#import <QiniuSDK.h>
#import "WTQiniuManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - button action
- (IBAction)singleFileUpload:(UIButton *)sender {
    [self uploadWithFilePath:[self filePath] key:@"123456.jpg" token:[self token]];
}

- (IBAction)addRepeatFile:(UIButton *)sender {
    for (NSInteger i = 0; i < 100; i++) {
        [self singleFileUpload:nil];
    }
}

- (IBAction)batchUpload:(UIButton *)sender {
    NSString *filePath = [self filePath];
    NSString *token = [self token];
    NSString *key = nil;
    for (NSInteger i = 0; i < 100; i++) {
        @autoreleasepool {
            key = @(i).stringValue;
            [self uploadWithFilePath:filePath key:key token:token];
        }
    }
}

#pragma mark - upload 
- (void)uploadWithFilePath:(NSString *)filePath key:(NSString *)key token:(NSString *)token{
    [[WTQiniuManager shareManager] uploadWithFilePath:filePath key:key token:token success:^{
        NSLog(@"---------成功");
    } failure:^(NSError *error) {
        NSLog(@"----------失败   %@", error.description);
    }];
}

#pragma mark - data
- (NSString *)token {
    return @"uploadToken";
}

- (NSString *)filePath {
    return [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"jpg"];
}

@end
