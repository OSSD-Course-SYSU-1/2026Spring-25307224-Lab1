/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { DeviceInfo, DistributedDeviceManager } from '../utils/DistributedDeviceManager';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common, AbilityConstant, Want } from '@kit.AbilityKit';
import CommonConstants from '../constants/CommonConstants';

const DOMAIN = 0x0000;
const TAG = 'DeviceMigrationPanel';

@CustomDialog
export struct DeviceMigrationPanel {
  controller: CustomDialogController;
  @State devices: DeviceInfo[] = [];
  @State isDiscovering: boolean = false;
  @State selectedDeviceId: string = '';

  private deviceManager: DistributedDeviceManager = DistributedDeviceManager.getInstance();

  aboutToAppear(): void {
    this.startDiscovery();
  }

  aboutToDisappear(): void {
    this.deviceManager.stopDiscovery();
  }

  /**
   * 开始发现设备
   */
  private startDiscovery(): void {
    this.isDiscovering = true;
    this.devices = [];

    const context = AppStorage.get<common.UIAbilityContext>('context');
    if (context) {
      this.deviceManager.init(context);
    }

    this.deviceManager.discoverDevices((discoveredDevices: DeviceInfo[]) => {
      this.devices = discoveredDevices;
      if (this.devices.length > 0) {
        this.isDiscovering = false;
      }
    });
  }

  /**
   * 执行迁移
   */
  private migrateToDevice(deviceId: string): void {
    if (!deviceId) {
      hilog.error(DOMAIN, TAG, 'No device selected');
      return;
    }

    try {
      const context = AppStorage.get<common.UIAbilityContext>('context');
      if (!context) {
        hilog.error(DOMAIN, TAG, 'Context not found');
        return;
      }

      // 获取当前播放状态
      const currentVideoIndex = AppStorage.get<number>('currentVideoIndex') || 0;
      const playbackPosition = AppStorage.get<number>('playbackPosition') || 0;
      const isPlaying = AppStorage.get<boolean>('isPlaying') || false;
      const playbackSpeed = AppStorage.get<string>('playbackSpeed') || '1.0X';
      const volume = AppStorage.get<number>('volume') ?? 5;
      const currentBrightness = AppStorage.get<number>('currentBrightness') ?? CommonConstants.DEFAULT_BRIGHTNESS;
      const isMute = AppStorage.get<boolean>('isMute') || false;

      // 构建迁移参数
      const want: Want = {
        deviceId: deviceId,
        bundleName: 'com.example.PlayLongVideosBasedOnVideo',
        abilityName: 'EntryAbility',
        parameters: {
          currentVideoIndex: currentVideoIndex,
          playbackPosition: playbackPosition,
          isPlaying: isPlaying,
          playbackSpeed: playbackSpeed,
          volume: volume,
          currentBrightness: currentBrightness,
          isMute: isMute,
          'ohos.aafwk.param.callerToken': context.abilityInfo?.applicationInfo?.accessTokenId
        }
      };

      // 启动目标设备上的 Ability
      context.startAbility(want)
        .then(() => {
          hilog.info(DOMAIN, TAG, 'Migration started to device: %{public}s', deviceId);
          this.controller.close();
        })
        .catch((err: Error) => {
          hilog.error(DOMAIN, TAG, 'Failed to migrate: %{public}s', JSON.stringify(err));
        });

    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Migration error: %{public}s', JSON.stringify(err));
    }
  }

  build() {
    Column() {
      // 标题
      Row() {
        Text($r('app.string.select_device'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 16, bottom: 16 })

      Divider().color('#333333')

      // 设备列表
      if (this.isDiscovering) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color('#FFFFFF')
          Text('正在搜索设备...')
            .fontSize(14)
            .fontColor('#AAAAAA')
            .margin({ top: 16 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else if (this.devices.length === 0) {
        Column() {
          Text($r('app.string.no_device_found'))
            .fontSize(14)
            .fontColor('#AAAAAA')
          Button('重新搜索')
            .fontSize(14)
            .margin({ top: 16 })
            .onClick(() => {
              this.startDiscovery();
            })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 8 }) {
          ForEach(this.devices, (device: DeviceInfo) => {
            ListItem() {
              Row() {
                // 设备图标
                Image(this.getDeviceIcon(device.deviceType))
                  .width(40)
                  .height(40)
                  .fillColor('#FFFFFF')

                // 设备信息
                Column() {
                  Text(device.deviceName)
                    .fontSize(16)
                    .fontColor('#FFFFFF')
                    .fontWeight(FontWeight.Medium)
                  Text(device.deviceType)
                    .fontSize(12)
                    .fontColor('#AAAAAA')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({ left: 12 })

                // 选择按钮
                Button('迁移')
                  .fontSize(14)
                  .height(32)
                  .backgroundColor('#007DFF')
                  .onClick(() => {
                    this.migrateToDevice(device.deviceId);
                  })
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#2A2A2A')
              .borderRadius(8)
            }
          }, (device: DeviceInfo) => device.deviceId)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      }

      Divider().color('#333333')

      // 取消按钮
      Row() {
        Button('取消')
          .fontSize(16)
          .width('100%')
          .backgroundColor('#444444')
          .onClick(() => {
            this.deviceManager.stopDiscovery();
            this.controller.close();
          })
      }
      .width('100%')
      .padding(16)
    }
    .width(320)
    .backgroundColor('#1A1A1A')
    .borderRadius(16)
  }

  /**
   * 根据设备类型获取图标
   */
  private getDeviceIcon(deviceType: string): ResourceStr {
    // 使用项目已验证的系统符号，所有设备类型暂用 phone 图标
    return $r('sys.symbol.phone');
  }
}
