//
//  ViewController.m
//  TestForQiNiuUpload
//
//  Created by 无所谓 on 16/2/23.
//  Copyright © 2016年 温. All rights reserved.
//

#import "ViewController.h"
#import <QiniuSDK.h>

@interface ViewController ()

@property (nonatomic, strong) QNUploadManager *uploadManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.uploadManager = [QNUploadManager sharedInstanceWithConfiguration:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIImage *image = [UIImage imageNamed:@"QQhaoyou"];
    NSData *imageData = UIImagePNGRepresentation(image);
    for (NSInteger i = 0; i < 200; i++) {
        NSString *key = @"23453/81A9C699-A62C-44C3-88BA-B00DE5119E4F/A4D60CEA-888C-4334-A7C8-EF788037D4E3.jpeg";
        NSString *token = @"a0h5P_uSX_opuu0veh0W3gBYxunaVmIjpgQur9BM:JUq2fgtdV9sQmXEvLUnUynudntw=:eyJzY29wZSI6InFhLW1lZGljYWwtcHJpdmF0ZS1jb21tb24iLCJkZWFkbGluZSI6MTQ1NjIxMTM1NywiY2FsbGJhY2tVcmwiOiJodHRwOi8vbWVkY2hhcnQucWEueGluZ3NodWxpbi5jb20vY2FzZWZvbGRlci1tZWRpY2FsL3Fpbml1Q2FsbGJhY2siLCJjYWxsYmFja0JvZHkiOiJuYW1lPSQoa2V5KVx1MDAyNmhhc2g9JChldGFnKSJ9";
        [self.uploadManager putData:imageData key:key token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            if (resp == nil) {
                // 失败
            } else {
                // 成功
            }
        } option:nil];
    }
}

@end
