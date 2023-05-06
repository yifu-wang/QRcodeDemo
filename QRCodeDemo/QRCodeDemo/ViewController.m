//
//  ViewController.m
//  QRCodeDemo
//
//  Created by didi on 2023/4/24.
//

#import "ViewController.h"
#import "ZWScanViewController.h"
#import "QRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIColor+ZWHexColor.h"

#define ScreenW ([UIScreen mainScreen].bounds.size.width)
#define ScreenH ([UIScreen mainScreen].bounds.size.height)

@interface ViewController ()
@property (nonatomic, strong) AVSpeechSynthesizer *voice;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
}

- (void)initView {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenW * 0.35, ScreenH * 0.3, ScreenW * 0.3, 50)];
    //btn.center = self.view.center;
    btn.backgroundColor = [UIColor hexColor:@"4c4c4c"];
    [btn setTitle:@"扫一扫" forState:UIControlStateNormal];
    btn.layer.cornerRadius = 10;
    \
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *qrCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenW * 0.35, ScreenH * 0.4, ScreenW * 0.3, 50)];
    qrCodeButton.backgroundColor = [UIColor hexColor:@"4c4c4c"];
    [qrCodeButton setTitle:@"生成二维码" forState:UIControlStateNormal];
    qrCodeButton.layer.cornerRadius = 10;
    [qrCodeButton addTarget:self action:@selector(qrCodeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:qrCodeButton];
    
}
- (void)btnClick {
    [self setUpSpeechParms];
    ZWScanViewController *scanVC = [[ZWScanViewController alloc] init];
    //[self.navigationController pushViewController:scanVC animated:YES];
    //[self presentViewController:scanVC animated:YES completion:nil];
    [self.navigationController pushViewController:scanVC animated:YES];
}

- (void)qrCodeClick {
    QRCodeViewController *qr = [[QRCodeViewController alloc] init];
    [self.navigationController pushViewController:qr animated:YES];
}

- (void)setUpSpeechParms {
    _voice = [[AVSpeechSynthesizer alloc] init];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:@"刷码成功"];
    AVSpeechSynthesisVoice *voiceType = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    
    utterance.voice = voiceType;
    utterance.rate = 0.6;
    [_voice speakUtterance:utterance];
    
}
- (void)willSpeakRangeOfSpeechString {
    NSLog(@"将要说话");
}

- (void)didStartSpeechUtterance {
    NSLog(@"正在说话");
}

- (void)didFinishSpeechUtterance {
    NSLog(@"已经说完话了");
}


@end


