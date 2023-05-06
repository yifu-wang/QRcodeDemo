//
//  QRCodeViewController.m
//  QRCodeDemo
//
//  Created by didi on 2023/5/5.
//

#import "QRCodeViewController.h"

@interface QRCodeViewController ()
@property (nonatomic, strong) UIImageView *qrImage;
@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setDefaults];
    
    NSString *strr = @"https://www.baidu.com";
   // [qrFilter setValue:[str dataUsingEncoding:NSUTF8StringEncoding] forKey:@"inputMessage"];
    //UIImage *imageMe = [[UIImage alloc] init];
    NSData *data = [strr dataUsingEncoding:NSUTF8StringEncoding];

    [qrFilter setValue:data forKey:@"inputMessage"];

    CIImage *ciimage = qrFilter.outputImage;
    NSLog(@"%@!!!",qrFilter.outputImage);
    ciimage = [ciimage imageByApplyingTransform:CGAffineTransformMakeScale(9, 9)];
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"];
    [colorFilter setDefaults];
    [colorFilter setValue:ciimage forKey:@"inputImage"];
    [colorFilter setValue:[CIColor colorWithRed:0 green:0 blue:1 ] forKey:@"inputColor0"];
    // 设定背景色
    [colorFilter setValue:[CIColor colorWithRed:1 green:0 blue:0] forKey:@"inputColor1"];
    ciimage = colorFilter.outputImage;
    self.qrImage = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    self.qrImage.image = [UIImage imageWithCIImage:ciimage];
    //
    //self.qrImage.contentMode = UIViewContentModeCenter;
    [self.view addSubview:self.qrImage];
  
}

- (UIImage *)createQRCoreImageWithCodeStr:(NSString *)codeStr pointCIColor:(CIColor *)pointCIColor bgCIColor:(CIColor *)bgCIColor {
    
    //1.生成coreImage框架中的滤镜来生产二维码
    CIFilter *filter=[CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    [filter setValue:[codeStr dataUsingEncoding:NSUTF8StringEncoding] forKey:@"inputMessage"];
    //4.获取生成的图片
    CIImage *ciImg=filter.outputImage;
    //放大ciImg,默认生产的图片很小
    
    //5.设置二维码的前景色和背景颜色
    CIFilter *colorFilter=[CIFilter filterWithName:@"CIFalseColor"];
    //5.1设置默认值
    [colorFilter setDefaults];
    [colorFilter setValue:ciImg forKey:@"inputImage"];
    [colorFilter setValue:pointCIColor forKey:@"inputColor0"];
    [colorFilter setValue:bgCIColor forKey:@"inputColor1"];
    //5.3获取生存的图片
    ciImg=colorFilter.outputImage;
    
    CGAffineTransform scale=CGAffineTransformMakeScale(10, 10);
    ciImg=[ciImg imageByApplyingTransform:scale];
    
    UIImage *finalImg =[UIImage imageWithCIImage:ciImg];
    
    //7.5关闭图像上下文
    UIGraphicsEndImageContext();
    
    return finalImg;
}

+ (NSString *)parseQRCodeImage:(UIImage *)qrCodeImage {

    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];//CIDetectorAccuracy指定检测精度,CIDetectorAccuracyHigh | CIDetectorAccuracyLow

    NSArray *features = [detector featuresInImage:qrCodeImage.CIImage];

    if (features == nil || features.count <= 0) return @"";

    CIQRCodeFeature *feature = [features firstObject];

    return feature.messageString;

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
