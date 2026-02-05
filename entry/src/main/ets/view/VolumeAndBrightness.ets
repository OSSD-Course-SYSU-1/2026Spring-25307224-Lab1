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

import { AVVolumePanel } from "@kit.AudioKit"

@Component
export struct VolumeAndBrightness {
  @Prop volume: number;
  @Prop visible: boolean;
  @Prop screenBrightness: number;

  build() {
    Row() {
      // Volume adjustment.
      Column() {
        AVVolumePanel({
          volumeLevel: this.volume,
          volumeParameter: {
            position: {
              x: 150,
              y: 300
            }
          }
        })
      }
      .width('50%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)

      // Brightness adjustment.
      Column() {
        Stack() {
          Slider({
            min: 0,
            max: 1,
            step:0.05,
            value: this.screenBrightness,
            style: SliderStyle.NONE,
            direction: Axis.Vertical,
            reverse: true
          })
            .height(160)
            .trackThickness(40)
            .trackColor(Color.Black)
            .selectedColor(Color.White)

          Image($r('app.media.brightness_fill'))
            .width(20)
            .height(20)
            .margin({ top: 120 })
        }
      }
      .width('50%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.End)
      .padding({ right: 30, bottom: 20 })
      .visibility(this.visible ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('100%')
  }
}