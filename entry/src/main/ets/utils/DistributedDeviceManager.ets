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

import { distributedDeviceManager } from '@kit.DistributedServiceKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Want, AbilityConstant } from '@kit.AbilityKit';
import { common } from '@kit.AbilityKit';

const DOMAIN = 0x0000;
const TAG = 'DistributedDeviceManager';

/**
 * 设备发现成功回调数据类型
 */
class DiscoverSuccessData {
  device: distributedDeviceManager.DeviceBasicInfo = {
    deviceId: '',
    deviceName: '',
    deviceType: '',
    networkId: ''
  };
}

/**
 * 设备发现失败回调数据类型
 */
class DiscoverFailureData {
  reason: number = 0;
}

/**
 * 分布式设备信息
 */
export interface DeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceType: string;
  networkId: string;
}

/**
 * 分布式设备管理器
 * 用于发现、连接分布式设备并执行跨端迁移
 */
export class DistributedDeviceManager {
  private static instance: DistributedDeviceManager;
  private deviceManager: distributedDeviceManager.DeviceManager | null = null;
  private deviceDiscoveryCallback: ((devices: DeviceInfo[]) => void) | null = null;
  private discoveredDevices: DeviceInfo[] = [];

  private constructor() {}

  static getInstance(): DistributedDeviceManager {
    if (!DistributedDeviceManager.instance) {
      DistributedDeviceManager.instance = new DistributedDeviceManager();
    }
    return DistributedDeviceManager.instance;
  }

  /**
   * 初始化设备管理器
   */
  init(context: common.UIAbilityContext): boolean {
    try {
      this.deviceManager = distributedDeviceManager.createDeviceManager(context.abilityInfo.bundleName);
      hilog.info(DOMAIN, TAG, 'Device manager initialized successfully');
      return true;
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to initialize device manager: %{public}s', JSON.stringify(err));
      return false;
    }
  }

  /**
   * 发现附近的分布式设备
   */
  discoverDevices(callback: (devices: DeviceInfo[]) => void): void {
    if (!this.deviceManager) {
      hilog.error(DOMAIN, TAG, 'Device manager not initialized');
      callback([]);
      return;
    }

    this.deviceDiscoveryCallback = callback;
    this.discoveredDevices = [];

    try {
      // 注册发现成功回调
      this.deviceManager.on('discoverSuccess', (data: DiscoverSuccessData) => {
        hilog.info(DOMAIN, TAG, 'Device discovered: %{public}s', data.device.deviceName);

        const deviceInfo: DeviceInfo = {
          deviceId: data.device.deviceId,
          deviceName: data.device.deviceName,
          deviceType: data.device.deviceType,
          networkId: data.device.networkId ?? ''
        };

        // 更新设备列表
        const existingIndex = this.discoveredDevices.findIndex(d => d.deviceId === deviceInfo.deviceId);
        if (existingIndex >= 0) {
          this.discoveredDevices[existingIndex] = deviceInfo;
        } else {
          this.discoveredDevices.push(deviceInfo);
        }

        if (this.deviceDiscoveryCallback) {
          this.deviceDiscoveryCallback([...this.discoveredDevices]);
        }
      });

      // 注册发现失败回调
      this.deviceManager.on('discoverFailure', (data: DiscoverFailureData) => {
        hilog.warn(DOMAIN, TAG, 'Discovery failed, reason: %{public}d', data.reason);
      });

      // 开始发现设备（使用新版 API）
      const discoverParam: Record<string, number> = {
        'discoverTargetType': 1
      };
      const filterOptions: Record<string, number> = {
        'availableStatus': 0
      };

      this.deviceManager.startDiscovering(discoverParam, filterOptions);
      hilog.info(DOMAIN, TAG, 'Device discovery started');

      // 设置超时自动停止发现
      setTimeout(() => {
        this.stopDiscovery();
      }, 10000);

    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to start device discovery: %{public}s', JSON.stringify(err));
      callback([]);
    }
  }

  /**
   * 停止设备发现
   */
  stopDiscovery(): void {
    if (!this.deviceManager) {
      return;
    }

    try {
      this.deviceManager.stopDiscovering();
      this.deviceManager.off('discoverSuccess');
      this.deviceManager.off('discoverFailure');
      hilog.info(DOMAIN, TAG, 'Device discovery stopped');
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to stop device discovery: %{public}s', JSON.stringify(err));
    }
  }

  /**
   * 获取已发现的设备列表
   */
  getDiscoveredDevices(): DeviceInfo[] {
    return [...this.discoveredDevices];
  }

  /**
   * 释放资源
   */
  release(): void {
    if (this.deviceManager) {
      try {
        this.stopDiscovery();
        hilog.info(DOMAIN, TAG, 'Device manager released');
      } catch (err) {
        hilog.error(DOMAIN, TAG, 'Failed to release device manager: %{public}s', JSON.stringify(err));
      }
    }
  }
}