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

import { PiPWindow } from "@kit.ArkUI";
import { common } from '@kit.AbilityKit';
import Logger from "../utils/Logger";

const TAG = '[PipWindowController]';

export class PipWindowController {
  pipController?: PiPWindow.PiPController;
  private context: common.UIAbilityContext | undefined = AppStorage.get('context');
  private xComponentController?: XComponentController;
  private currentState: string = '';

  async createPipWindow(videoController: VideoController) {
    try {
      // 创建画中画控制器
      this.pipController = await PiPWindow.create({
        context: this.context, // 上下文环境
        componentController: this.xComponentController, // 原始XComponent控制器
        templateType: PiPWindow.PiPTemplateType.VIDEO_PLAY // 表示将要切换为画中画播放的媒体类型是视频
      })
    } catch (err) {
      Logger.warn(TAG, `Create PiPWindow failed. code: ${err.code}, message: ${err.message}`);
    }

    // 画中画生命周期状态的监听
    this.pipController?.on('stateChange', (state: PiPWindow.PiPState, reason: string) => {

    })

    // 开启画中画控制面板控件动作事件的监听
    this.pipController?.on('controlPanelActionEvent', (event: PiPWindow.PiPActionEventType, status?: number) => {
      switch (event) {
        case 'playbackStateChanged':
          if (status === 0) {

          } else {

          }
          break;
        default:
          break;
      }
    })

    // 设置是否在返回桌面时自动启动画中画
    this.pipController?.setAutoStartEnabled(true);
  }

  destroyPipController() {
    if (!this.pipController) {
      return;
    }
    this.pipController.setAutoStartEnabled(false);
    this.pipController.off('stateChange');
    this.pipController.off('controlPanelActionEvent');
    this.pipController = undefined;
  }

  // 画中画生命周期状态变化
  onStateChange(state: PiPWindow.PiPState, isPlaying: boolean) {
    if (!this.pipController) {
      return;
    }
    switch (state) {
      case PiPWindow.PiPState.ABOUT_TO_START: // 画中画将要启动
        this.currentState = 'ABOUT_TO_START';
        break;
      case PiPWindow.PiPState.STARTED: // 画中画已经启动
        this.currentState = 'STARTED';
        let status: PiPWindow.PiPControlStatus =
          isPlaying ? PiPWindow.PiPControlStatus.PLAY : PiPWindow.PiPControlStatus.PAUSE;
        // 更新画中画控制面板控件功能状态
        this.pipController.updatePiPControlStatus(PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE, status);
        break;
      case PiPWindow.PiPState.ABOUT_TO_STOP: // 画中画将要停止
        this.currentState = 'ABOUT_TO_STOP';
        break;
      case PiPWindow.PiPState.STOPPED: // 画中画已经停止
        this.currentState = 'STOPPED';
        break;
      case PiPWindow.PiPState.ABOUT_TO_RESTORE: // 画中画将从小窗播放恢复到原始播放界面
        this.currentState = 'ABOUT_TO_RESTORE';
        break;
      case PiPWindow.PiPState.ERROR: // 画中画生命周期执行过程出现了异常
        this.currentState = 'ERROR';
        break;
      default:
        break;
    }
  }
}