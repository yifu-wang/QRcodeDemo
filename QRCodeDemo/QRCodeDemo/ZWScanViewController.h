//
//  ZWScanViewController.h
//  QRCodeDemo
//
//  Created by didi on 2023/5/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^returnLabelValue)(NSString *str);
@interface ZWScanViewController : UIViewController
@property (nonatomic, strong) returnLabelValue valueLabel;
@end

NS_ASSUME_NONNULL_END
