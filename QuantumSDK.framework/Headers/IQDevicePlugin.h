//
//  IQDTDevicePlugin.h
//  IPCIQ
//
//  Created by Kyle Mai on 11/19/15.
//  Copyright © 2015 Infinite Peripherals. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IQDevicePlugin <NSObject>

@optional
- (instancetype)initWithName:(NSString *)name
                       model:(NSString *)model
                      serial:(NSString *)serial
                        type:(NSString *)type
                manufacturer:(NSString *)manufacturer;

/**
 Set extension plugin version number
 @param major Version major
 @param minor Version minor
 @param build Version build
 */
- (void)setPluginVersionMajor:(NSInteger)major
                        minor:(NSInteger)minor
                        build:(NSInteger)build;

@required

@property (readonly, nonatomic) NSString *pluginName;
@property (readonly, nonatomic) NSString *pluginVersion;
@property (readonly, nonatomic) NSString *deviceName;
@property (readonly, nonatomic) NSString *deviceModel;
@property (readonly, nonatomic) NSString *deviceSerial;
@property (readonly, nonatomic) NSString *deviceType;
@property (readonly, nonatomic) NSString *deviceManufacturer;
@property (nonatomic) BOOL tampered;


/**
 Get a list of info for the connected IPC Device
 @return NSDictionary object contains the info
 */
- (NSDictionary *)getDeviceDetails;

/**
 Get a list of info data for the connected IPC Device to use with plugin
 @return NSDictionary object contains the plugin info data
 */
- (NSDictionary *)getDevicePluginData;

@end
