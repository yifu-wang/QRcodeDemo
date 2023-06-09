//
//  UIColor+ZWHexColor.h
//  QRCodeDemo
//
//  Created by didi on 2023/5/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (ZWHexColor)
+ (UIColor *)hexColor:(NSString *)color;
+ (UIColor *)hexColor:(NSString *)color alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
