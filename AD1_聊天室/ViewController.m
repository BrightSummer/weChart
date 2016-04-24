//
//  ViewController.m
//  AD1_聊天室
//
//  Created by ming on 16/4/24.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "ViewController.h"

NSInputStream *_inputStream;
NSOutputStream *_outputStream;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)connectToServer:(id)sender {
    
    // ios 实现 socket 连接，使用 C 语言
    
    // 1.与服务器三次握手实现连接
    NSString *host = @"127.0.0.1";
    int port = 12345;
    
    // 2.定义输入输出流
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    // 3.分配输入输出流的内存空间
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef) host, port, &readStream, &writeStream);
    
    // 4.把 C 语言的输入输出流转换成 OC
    _inputStream = (__bridge NSInputStream *)readStream;
    _outputStream = (__bridge NSOutputStream *)(writeStream);
    
    // 5.设置代理，监听数据接收状态
    _outputStream.delegate = self;
    _inputStream.delegate = self;
    
    // 把输入输出流添加到主运行循环（ RUNLOOP ）
    // 主运行循环是监听网络状态的
    [_outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop]forMode:NSDefaultRunLoopMode];
    [_inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop]forMode:NSDefaultRunLoopMode];
    
    // 6.打入打开输入输出流
    [_outputStream open];
    [_inputStream open];
    
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
//    NSStreamEventOpenCompleted = 1UL << 0,
//    NSStreamEventHasBytesAvailable = 1UL << 1,
//    NSStreamEventHasSpaceAvailable = 1UL << 2,
//    NSStreamEventErrorOccurred = 1UL << 3,
//    NSStreamEventEndEncountered = 1UL << 4
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"%@",aStream);
            NSLog(@"成功建立连接，形成输入输出流的传输通道");
            break;
        case NSStreamEventHasBytesAvailable:
            NSLog(@"有数据可读");
            [self readData];
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"可以发送数据");
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"有错误发生，连接失败");
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"正常断开连接");
            break;
            
        default:
            break;
    }
}


- (IBAction)loginBtnClick:(id)sender {
    // 发送登陆请求，使用输出流
    
    // 拼接登陆指令
    // uint8_t * 字符数组
    NSString *loginStr = @"iam:zhangsan";
    NSData *data = [loginStr dataUsingEncoding:NSUTF8StringEncoding];

    [_outputStream write:data.bytes maxLength:data.length];
}
#pragma mark 读取服务器返回的数据
- (void)readData{
    
    // 定义一个缓冲区，这个缓冲区只能存储1024个字节
    uint8_t buf[1024];
    
    // 读取数据
    // len 为服务器读取到的实际字节数
    NSInteger len = [_inputStream read:buf maxLength:sizeof(buf)];
    
    // 把缓冲区里的实际字节数转成字符串
    NSString *recevierStr = [[NSString alloc] initWithBytes:buf length:len encoding:NSUTF8StringEncoding];
    NSLog(@"%@",recevierStr);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
