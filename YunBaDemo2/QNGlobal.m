//
//  QNGlobal.m
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/29.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import "QNGlobal.h"
#import <CommonCrypto/CommonDigest.h>
#import "QiniuSDK.h"
#import "AFNetworking.h"

#define QN_UPTOKEN @"https://yunba.io/publicapi/chatroom/uptoken"
#define QN_DOWNLOAD_URL @"https://od7uu00in.qnssl.com/"

@implementation QNGlobal

+(void)getImageURL:(UIImage *)image complete:(void(^)(BOOL success,NSString *url))complete {
    if (!image) {return;}
    [self getToken:^(BOOL success, NSString *token) {
        if (success) {
            QNUploadManager *manager = [[QNUploadManager alloc] init];
            NSData *data = UIImageJPEGRepresentation(image, 0.9);
            NSLog(@"%luKB",data.length / 1000);
            NSString *key = [[NSUUID UUID] UUIDString];
            NSString *fileName = [([@"iOS-[" stringByAppendingString:key]) stringByAppendingString:@"]"];
            [manager putData:data key:fileName token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                if (complete) {
                    complete(YES,fileName);
                }
            } option:nil];
        }
    }];
}
+(void)getImageWitKey:(NSString *)key complete:(void(^)(BOOL success,UIImage *image))complete {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    NSString *url = [QN_DOWNLOAD_URL stringByAppendingString:key];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        UIImage *img = responseObject;
        if (complete) { complete(YES,img); }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        if (complete) { complete(NO,nil); }
    }];
}
#pragma mark - private
+(NSString *)md5:(NSData *) input {
    const char* original_str = (const char *)[input bytes];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str,(uint32_t)strlen(original_str), digest ); // This is the md5 call
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
}
+(void)getToken:(void(^)(BOOL success,NSString *token))success {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:QN_UPTOKEN parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = responseObject;
        NSString *token = [dict objectForKey:@"uptoken"];
        if (success) { success(YES,token);}
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        if (success) {success(NO,nil);}
    }];
}
@end
