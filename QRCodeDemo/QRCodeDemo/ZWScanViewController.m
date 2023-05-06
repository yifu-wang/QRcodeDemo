//
//  ZWScanViewController.m
//  QRCodeDemo
//
//  Created by didi on 2023/5/5.
//

#import "ZWScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import "QRCodeResultViewController.h"
#import "UIColor+ZWHexColor.h"

#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS

@interface ZWScanViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *session;//捕捉会话
@property (nonatomic, strong) AVCaptureDeviceInput *input;//输入流
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;//输出流
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;//预览涂层
@property (nonatomic, strong) UIImageView *line;
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;
@end

@implementation ZWScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view.layer addSublayer:self.videoPreviewLayer];
    [self startCapture];
}

- (void)dealloc {
    self.input = nil;
    self.metadataOutput = nil;
    self.session = nil;
    self.videoPreviewLayer = nil;
}

#pragma makr - 请求权限
- (BOOL)requestDeviceAuthorization{
    AVAuthorizationStatus deviceStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (deviceStatus == AVAuthorizationStatusRestricted ||
        deviceStatus == AVAuthorizationStatusDenied){
        NSLog(@"相机未授权");
        return NO;
    }
    NSLog(@"相机已授权");
    return YES;
}

- (void)startCapture {
    if (![self requestDeviceAuthorization]) {
        NSLog(@"没有访问相机权限！");
        return;
    }
    
//    [self.session beginConfiguration];
    //添加设备输入流到会话对象
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    //设置数据输出类型，需要将数据输出添加到会话后，才能指定元数据类型，否则会报错
    if ([self.session canAddOutput:self.metadataOutput]) {
        [self.session addOutput:self.metadataOutput];
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        NSArray *types = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode93Code];
        self.metadataOutput.metadataObjectTypes = types;
    }
    [self.session commitConfiguration];
    /*开始捕获数据和停止捕获。最好不要把它们放在主线程中使用。因为 startRunning 和 stopRunning 其实是一个 block，主线程调用可能会引起，UI卡顿。*/
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.session startRunning];
        });

}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    //扫描到的数据
    AVMetadataMachineReadableCodeObject *dataObject = (AVMetadataMachineReadableCodeObject *)[metadataObjects lastObject];
    
    /*识别到信息即停止识别*/
    if (dataObject) {
        NSLog(@"metadataObjects[last]==%@", dataObject.stringValue);
        [self stopCapture];
        [self addDescribeText:dataObject.stringValue];
        QRCodeResultViewController *result = [[QRCodeResultViewController alloc] init];
        result.resultString = dataObject.stringValue;
        //result.resultLabel.text = dataObject.stringValue;
        [self.navigationController pushViewController:result animated:NO];
        
    }
}

//停止扫描
- (void)stopCapture {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.session stopRunning];
        });
}

- (void)addDescribeText:(NSString *)str {
    UITextField *descText = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    descText.center = self.view.center;
    descText.layer.cornerRadius = 20;
    descText.backgroundColor = [UIColor hexColor:@"#4c4c4c"];
    descText.textAlignment = NSTextAlignmentCenter;
    descText.textColor = [UIColor whiteColor];
    [descText setText:str];
    [self.view addSubview:descText];
}

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        //设置会话采集率
        _session.sessionPreset = AVCaptureSessionPresetHigh;
        
    }
    return _session;
}

- (AVCaptureDeviceInput *)input {
    if (!_input) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        _input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    }
    return _input;
}

- (AVCaptureMetadataOutput *)metadataOutput {
    if (!_metadataOutput) {
        _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
        CGFloat scanW = screenW * 0.6;
        CGRect scanRect = CGRectMake(screenW * 0.2, screenH * 0.35, screenW * 0.6 , screenH * 0.3);
        _metadataOutput.rectOfInterest = CGRectMake(scanRect.origin.y / screenH, scanRect.origin.x / screenW, scanRect.size.height / screenH, scanRect.size.width / screenW);
        
        UIView *scanV = [[UIView alloc] initWithFrame:scanRect];
        [self.view addSubview:scanV];
        scanV.layer.borderWidth = 2;
        //scanV.layer.borderColor = [UIColor redColor].CGColor;
        [self setOverlayPickerView];
    }
    return _metadataOutput;
}

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer {
    if (!_videoPreviewLayer) {
        _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        // 保持纵横比；填充层边界
        _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _videoPreviewLayer.frame = self.view.bounds;
        
    }
    return _videoPreviewLayer;
}

- (void)setOverlayPickerView

{
    
    //左侧的view

    UIView *leftView = [UIView new];

    leftView.alpha = 0.5;

    leftView.backgroundColor = [UIColor blackColor];

    [self.view addSubview:leftView];
    
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.equalTo(self.view.mas_top);

        make.bottom.equalTo(self.view.mas_bottom);

        make.left.equalTo(self.view.mas_left);

        make.width.equalTo(self.view).multipliedBy(0.2);

    }];

    

    //右侧的view

    UIView *rightView = [UIView new];

    rightView.alpha = 0.5;

    rightView.backgroundColor = [UIColor blackColor];

    [self.view addSubview:rightView];

    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.equalTo(self.view.mas_top);

        make.bottom.equalTo(self.view.mas_bottom);

        make.right.equalTo(self.view.mas_right);

        make.width.equalTo(self.view).multipliedBy(0.2);

    }];

    

    

    //最上部view

    UIView* upView = [UIView new];

    upView.alpha = 0.5;

    upView.backgroundColor = [UIColor blackColor];

    [self.view addSubview:upView];

    [upView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.equalTo(self.view.mas_top);

        make.left.equalTo(leftView.mas_right);

        make.right.equalTo(rightView.mas_left);

        make.height.equalTo(self.view).multipliedBy(0.35);
        

    }];

    //扫描框

    UIImageView *centerView = [UIImageView new];

    centerView.center = self.view.center;

    centerView.image = [UIImage imageNamed:@"scanFrame.png"];

    centerView.contentMode = UIViewContentModeScaleAspectFit;

    centerView.backgroundColor = [UIColor clearColor];

    [self.view addSubview:centerView];

    [centerView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.equalTo(upView.mas_bottom);

        make.left.equalTo(leftView.mas_right);

        make.right.equalTo(rightView.mas_left);

        make.height.equalTo(self.view).multipliedBy(0.3);

    }];

    

    

    

    //底部view

    UIView * downView = [UIView new];

    downView.alpha = 0.5;

    downView.backgroundColor = [UIColor blackColor];

    [self.view addSubview:downView];

    [downView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.equalTo(centerView.mas_bottom);

        make.left.equalTo(leftView.mas_right);

        make.right.equalTo(rightView.mas_left);

        make.bottom.equalTo(self.view.mas_bottom);

    }];

    

    

    

    _line = [UIImageView new];

    _line.image = [UIImage imageNamed:@"zhixian.png"];

    _line.contentMode = UIViewContentModeScaleAspectFill;

    _line.backgroundColor = [UIColor clearColor];

    [self addAnimation];

    [self.view addSubview:_line];

    [_line mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.equalTo(upView.mas_bottom);

        make.left.equalTo(centerView.mas_left);

        make.right.equalTo(centerView.mas_right);

        make.height.equalTo(centerView.mas_height);

    }];

    

    

    //提示信息

    UILabel *msg = [UILabel new];

    msg.backgroundColor = [UIColor clearColor];

    msg.textColor = [UIColor whiteColor];

    msg.textAlignment = NSTextAlignmentCenter;

    msg.font = [UIFont systemFontOfSize:16];

    msg.text = @"将二维码放入框内可识别信息";

    [self.view addSubview:msg];

    [msg mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.equalTo(centerView.mas_bottom).offset(20);

        make.left.equalTo(self.view.mas_left);

        make.right.equalTo(self.view.mas_right);

        make.height.equalTo(@30);

    }];
}

- (void)addAnimation{
    CABasicAnimation *animation = [self moveYTime:2 fromY:[NSNumber numberWithFloat:-([UIScreen mainScreen].bounds.size.height * 0.14)] toY:[NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.height * 0.15] rep:OPEN_MAX];
    [_line.layer addAnimation:animation forKey:@"animation"];

}

-(CABasicAnimation *)moveYTime:(float)time fromY:(NSNumber *)fromY toY:(NSNumber *)toY rep:(int)rep
{

    CABasicAnimation *animationMove = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];

    [animationMove setFromValue:fromY];

    [animationMove setToValue:toY];

    animationMove.duration = time;

    animationMove.delegate = self;

    animationMove.repeatCount  = rep;

    animationMove.fillMode = kCAFillModeForwards;

    animationMove.removedOnCompletion = NO;

    animationMove.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    return animationMove;

}

@end
