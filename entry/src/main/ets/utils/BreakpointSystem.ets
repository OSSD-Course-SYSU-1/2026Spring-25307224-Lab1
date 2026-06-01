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

import { mediaquery } from '@kit.ArkUI';

/**
 * 断点类型枚举
 * sm: 小屏幕设备（手机竖屏）
 * md: 中等屏幕设备（手机横屏、折叠屏）
 * lg: 大屏幕设备（平板、大折叠屏）
 * xl: 超大屏幕设备（平板横屏、PC）
 */
export enum BreakpointType {
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
  XL = 'xl'
}

/**
 * 断点系统工具类
 * 用于实现响应式布局，根据窗口宽度自动切换断点
 */
export class BreakpointSystem {
  private static instance: BreakpointSystem;
  private currentBreakpoint: BreakpointType = BreakpointType.SM;
  private listeners: Array<(breakpoint: BreakpointType) => void> = [];
  
  // 断点范围定义（单位：vp）
  private readonly BREAKPOINT_SM = 320;
  private readonly BREAKPOINT_MD = 600;
  private readonly BREAKPOINT_LG = 840;
  private readonly BREAKPOINT_XL = 1440;
  
  private smListener?: mediaquery.MediaQueryListener;
  private mdListener?: mediaquery.MediaQueryListener;
  private lgListener?: mediaquery.MediaQueryListener;
  private xlListener?: mediaquery.MediaQueryListener;

  private constructor() {}

  public static getInstance(): BreakpointSystem {
    if (!BreakpointSystem.instance) {
      BreakpointSystem.instance = new BreakpointSystem();
    }
    return BreakpointSystem.instance;
  }

  /**
   * 初始化断点监听
   */
  public initialize(): void {
    // 监听小屏幕断点
    this.smListener = mediaquery.matchMediaSync(`(width < ${this.BREAKPOINT_MD})`);
    this.smListener.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.updateBreakpoint(BreakpointType.SM);
      }
    });

    // 监听中等屏幕断点
    this.mdListener = mediaquery.matchMediaSync(
      `(width >= ${this.BREAKPOINT_MD}) && (width < ${this.BREAKPOINT_LG})`
    );
    this.mdListener.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.updateBreakpoint(BreakpointType.MD);
      }
    });

    // 监听大屏幕断点
    this.lgListener = mediaquery.matchMediaSync(
      `(width >= ${this.BREAKPOINT_LG}) && (width < ${this.BREAKPOINT_XL})`
    );
    this.lgListener.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.updateBreakpoint(BreakpointType.LG);
      }
    });

    // 监听超大屏幕断点
    this.xlListener = mediaquery.matchMediaSync(`(width >= ${this.BREAKPOINT_XL})`);
    this.xlListener.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.updateBreakpoint(BreakpointType.XL);
      }
    });
  }

  /**
   * 更新当前断点并通知监听器
   */
  private updateBreakpoint(breakpoint: BreakpointType): void {
    if (this.currentBreakpoint !== breakpoint) {
      this.currentBreakpoint = breakpoint;
      this.notifyListeners();
    }
  }

  /**
   * 获取当前断点
   */
  public getCurrentBreakpoint(): BreakpointType {
    return this.currentBreakpoint;
  }

  /**
   * 注册断点变化监听器
   */
  public registerListener(listener: (breakpoint: BreakpointType) => void): void {
    this.listeners.push(listener);
    // 立即通知当前断点
    listener(this.currentBreakpoint);
  }

  /**
   * 取消注册断点变化监听器
   */
  public unregisterListener(listener: (breakpoint: BreakpointType) => void): void {
    const index = this.listeners.indexOf(listener);
    if (index !== -1) {
      this.listeners.splice(index, 1);
    }
  }

  /**
   * 通知所有监听器
   */
  private notifyListeners(): void {
    for (const listener of this.listeners) {
      listener(this.currentBreakpoint);
    }
  }

  /**
   * 销毁监听器
   */
  public destroy(): void {
    if (this.smListener) {
      this.smListener.off('change');
    }
    if (this.mdListener) {
      this.mdListener.off('change');
    }
    if (this.lgListener) {
      this.lgListener.off('change');
    }
    if (this.xlListener) {
      this.xlListener.off('change');
    }
    this.listeners = [];
  }

  /**
   * 根据断点获取对应的值
   * @param values 不同断点对应的值
   * @returns 当前断点对应的值
   */
  public getValue<T>(values: Record<string, T>): T {
    return values[this.currentBreakpoint] ?? values[BreakpointType.SM];
  }

  /**
   * 判断是否是大屏设备
   */
  public isLargeScreen(): boolean {
    return this.currentBreakpoint === BreakpointType.LG || 
           this.currentBreakpoint === BreakpointType.XL;
  }

  /**
   * 判断是否是平板或更大设备
   */
  public isTabletOrLarger(): boolean {
    return this.currentBreakpoint === BreakpointType.MD ||
           this.currentBreakpoint === BreakpointType.LG ||
           this.currentBreakpoint === BreakpointType.XL;
  }
}
