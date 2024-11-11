//
//  IQCustomDevice.h
//  QuantumSDK
//
//  Copyright © 2016 Infinite Peripherals. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuantumSDK/IQDevicePlugin.h>

@interface IQCustomDevice : NSObject <IQDevicePlugin>

/**
 Create a new custom device object.
 @param deviceName A name for you device
 @param deviceModel Device model
 @param deviceType Device type
 @param deviceSerial Device serial
 @param manufacturer Device manufacturer
 @param level A block that return battery level in int
 @return IQCustomDevice
 */
- (instancetype)initWithName:(NSString *)deviceName
                       model:(NSString *)deviceModel
                      serial:(NSString *)deviceSerial
                        type:(NSString *)deviceType
                manufacturer:(NSString *)manufacturer
                     battery:(int (^)(void))level
                    firmware:(NSString * (^)(void))firmware;

/**
 Set custom key-value for this device
 @param block A block that return a value
 @param field Key name
 @param prettyName The display name on IQ portal
 */
- (void)setDeviceValueWithBlock:(NSString *(^)(void))block forField:(NSString *)field title:(NSString *)prettyName;

/**
 The info of the custom device
 @return NSDictionary
 */
- (NSDictionary *)getDeviceDetails;

/**
 The plugin info for this module
 @return NSDictionary
 */
- (NSDictionary *)getDevicePluginData;

/**
 This image will be uploaded to portal and shown on the list of devices
 @param image The full-size image
 @param thumbnail The scaled down version
 */
- (void)setDeviceImage:(UIImage *)image andThumbnail:(UIImage *)thumbnail;

/**
 UNAVAILABLE
 */
- (instancetype)initWithName:(NSString *)name
                       model:(NSString *)model
                      serial:(NSString *)serial
                        type:(NSString *)type
                manufacturer:(NSString *)manufacturer NS_UNAVAILABLE;
- (id)init NS_UNAVAILABLE;
+ (id)new NS_UNAVAILABLE;

@end
