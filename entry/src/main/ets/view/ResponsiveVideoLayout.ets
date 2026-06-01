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

import { BreakpointSystem, BreakpointType } from '../utils/BreakpointSystem';

/**
 * 响应式视频播放器布局组件
 * 根据不同屏幕尺寸自动调整布局
 */
@Component
export struct ResponsiveVideoLayout {
  @State currentBreakpoint: BreakpointType = BreakpointType.SM;
  private breakpointSystem: BreakpointSystem = BreakpointSystem.getInstance();
  
  // 布局参数
  @State videoWidth: string = '100%';
  @State videoHeight: string = '100%';
  @State controlBarHeight: number = 48;
  @State showSideBar: boolean = false;
  @State columns: number = 1;

  aboutToAppear(): void {
    // 初始化断点系统
    this.breakpointSystem.initialize();
    
    // 注册断点变化监听
    this.breakpointSystem.registerListener((breakpoint: BreakpointType) => {
      this.currentBreakpoint = breakpoint;
      this.updateLayout();
    });
  }

  aboutToDisappear(): void {
    this.breakpointSystem.destroy();
  }

  /**
   * 根据断点更新布局参数
   */
  private updateLayout(): void {
    switch (this.currentBreakpoint) {
      case BreakpointType.SM:
        // 小屏幕：单列布局，无侧边栏
        this.videoWidth = '100%';
        this.videoHeight = '100%';
        this.controlBarHeight = 48;
        this.showSideBar = false;
        this.columns = 1;
        break;
        
      case BreakpointType.MD:
        // 中等屏幕：单列布局，可显示侧边栏
        this.videoWidth = '100%';
        this.videoHeight = '100%';
        this.controlBarHeight = 56;
        this.showSideBar = false;
        this.columns = 1;
        break;
        
      case BreakpointType.LG:
        // 大屏幕：双列布局，显示侧边栏
        this.videoWidth = '70%';
        this.videoHeight = '100%';
        this.controlBarHeight = 64;
        this.showSideBar = true;
        this.columns = 2;
        break;
        
      case BreakpointType.XL:
        // 超大屏幕：三列布局，显示侧边栏
        this.videoWidth = '75%';
        this.videoHeight = '100%';
        this.controlBarHeight = 72;
        this.showSideBar = true;
        this.columns = 3;
        break;
    }
  }

  build() {
    // 这个组件主要用于提供布局参数
    // 实际布局由父组件实现
  }
}
