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

// 当前视频状态
export default class VideoStatus {
  static readonly PLAY_PREPARED: string = 'prepared'; // 视频准备
  static readonly PLAY_STARTED: string = 'started'; // 开始播放
  static readonly PLAY_PAUSED: string = 'paused'; // 暂停播放
  static readonly PLAY_FINISH: string = 'finished'; // 播放完成
  static readonly PLAY_STOPPED: string = 'stopped'; // 停止播放
}