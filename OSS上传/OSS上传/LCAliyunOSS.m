//
//  AliyunOSSDemo.m
//  OSS上传
//
//  Created by edison on 2017/6/7.
//  Copyright © 2017年 edison. All rights reserved.
//

#import "LCAliyunOSS.h"
#import <AliyunOSSiOS/OSSService.h>
#import <AFNetworking.h>
#import "LCUploadViewController.h"
NSString * const endPoint = @"https://oss-cn-shenzhen.aliyuncs.com";
OSSClient * client;

@interface LCAliyunOSS ()
//获取token返回的json数据
@property(nonatomic,strong)NSDictionary *responseObject;
@property(nonatomic,strong)LCUploadViewController *upVC;
@property (assign, nonatomic) int age;
@end

@implementation LCAliyunOSS

#pragma mark ====创建上传的单例====
+ (instancetype)sharedInstance {
    static LCAliyunOSS *instance;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [LCAliyunOSS new];
    });
    
    return instance;
}


#pragma mark ===开启上传环境====
- (void)setupEnvironment {
    // 打开调试log
    [OSSLog enableLog];
    
    // 初始化sdk
    [self initOSSClient];
    }

#pragma maek ===  初始化阿里云sdk====
- (void)initOSSClient {
    
    // 明文设置AccessKeyId/AccessKeySecret的方式建议只在测试时使用LTAIUqUzNn0NgLQn   p5dgVPGj39s4TBizt9axFWcgg9Nacr
    id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:@"填入ID" secretKey:@"填入key"];
    client = [[OSSClient alloc] initWithEndpoint:endPoint credentialProvider:credential];
    
    
//    //STS鉴权模式
//   NSString *mobile = @"13715006982";
//    NSString  *secretString = [NSString stringWithFormat:@"%@",mobile];
// 
//    //直接设置StsToken
//    id<OSSCredentialProvider> credential2 = [[OSSFederationCredentialProvider alloc] initWithFederationTokenGetter:^OSSFederationToken * {
//        OSSTaskCompletionSource * tcs = [OSSTaskCompletionSource taskCompletionSource];
//        
//        NSString *string = @"//////////////////";
//        NSDictionary *dict = @{@"mobile":mobile,@"sign":secretString};
//        
//        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//        
//        //设置信任CA证书 在https传输情况下需要设置
//        AFSecurityPolicy * policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//        policy.allowInvalidCertificates = YES;
//        policy.validatesDomainName = NO;
//        manager.securityPolicy = policy;
//    
//        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
//        [manager POST:string parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSLog(@"%@",responseObject);
//            
//        self.responseObject = responseObject;
//        [tcs setResult:responseObject];
//            
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            NSLog(@"%@",error);
//            if (error) {
//                [tcs setError:error];
//                return;
//            }
//        }];
//        
//        //同步
//        [tcs.task waitUntilFinished];
//        
//        if (tcs.task.error) {
//            NSLog(@"get token error: %@", tcs.task.error);
//            return nil;
//        }
//        else {
//            //获取token返回的参数
//            OSSFederationToken * token = [OSSFederationToken new];
//            token.tAccessKey = [self.responseObject objectForKey:@"AccessKeyId"];
//            token.tSecretKey = [self.responseObject objectForKey:@"AccessKeySecret"];
//            token.tToken = [self.responseObject objectForKey:@"SecurityToken"];
//            token.expirationTimeInGMTFormat = [self.responseObject objectForKey:@"Expiration"];
//            NSLog(@"get token: %@", token);
//            return token;
//        }
//        
//    }];
//    
//    //网络配置
//    OSSClientConfiguration * conf = [OSSClientConfiguration new];
//    conf.maxRetryCount = 2;
//    conf.timeoutIntervalForRequest = 30;
//    conf.timeoutIntervalForResource = 24 * 60 * 60;
//    
//    client = [[OSSClient alloc] initWithEndpoint:endPoint credentialProvider:credential2 clientConfiguration:conf];
}




#pragma mark ==== 同步上传=====
- (void)uploadObjectAsyncWith:(NSData *)uploadData withObjectKey:(NSString *)objectKey withAlbumNumber:(NSString *)number{
    
   
    //上传请求类
    OSSPutObjectRequest * request = [OSSPutObjectRequest new];
    //文件夹名 后台给出
    request.bucketName = @"文件夹名";
    //objectKey为文件名 一般自己拼接
    request.objectKey = objectKey;
    //上传数据类型为NSData
    request.uploadingData = uploadData;
    


//    //上传回调URL
//    获取用户ID
//    NSString *userId = @"13715006982";
//    NSString *upUrl = @"//////////////";
//    
//    
//    //不同类型的数据设置不同的文件名 根据文件名可以设置不同类型的回调参数
//    //头像
//    if ([objectKey rangeOfString:@"anchorImage"].location != NSNotFound){
//        //头像上传回调请求体 这里objectKey充当返回给后台URL的后缀
//        NSString *callBackBody = [NSString stringWithFormat:@"imageUrl=%@&mimeType=headimage&userId=%@",objectKey,userId];
//        // 设置回调参数
//        request.callbackParam = @{
//                                  @"callbackUrl":upUrl,
//                                  @"callbackBody":callBackBody,
//                                  @"callbackBodyType":@"application/json"
//                                  };
//    }
    
    
    
    OSSTask * putTask = [client putObject:request];
    [putTask continueWithBlock:^id(OSSTask *task) {
        
        if (!task.error) {
            
            //每次上传完一个文件都要回调
            NSLog(@"上传成功!");
        } else {
            
            //每上传失败一个文件后都要回调
            NSLog(@"upload object failed, error: %@" , task.error);
            //在即使上传失败后如果不作处理，那么上传时当调度组里面的方法执行了，不管方法执行成功还是失败，最后调度组执行完之后还是要回调，由于回调里只写了成功弹框，所以这里需要加上通知处理上传失败的结果
            //创建一个消息对象
            NSNotification * notice = [NSNotification notificationWithName:@"123" object:nil];
            //发送消息
            [[NSNotificationCenter defaultCenter]postNotification:notice];
            
        }
        return nil;
    }];
    
       //同步上传（去掉就是异步）因为我上传的文件有多种包括音视频,图片。而且OSS这边是每上传成功一个文件都要回调一次。比如我成功上传5张图片，那么就要回调5次。所以这个时候我就无法判断文件是否都上传完成。所以我就把这些上传的文件放在调度组里面，这样所有文件上传成功后我这边就知道了。如果上传放在调度组里，那么这里的同步上传就必须加上。
    [putTask waitUntilFinished];
    
    //上传进度
    request.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
        
    };
}

#pragma mark ===移除通知===
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self.upVC name:@"123" object:self];
}

@end
