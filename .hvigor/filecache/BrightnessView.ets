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

import CommonConstants from '../constants/CommonConstants';
@Component
export struct BrightnessView {
  @Prop brightnessValue: number;
  @Prop visible: boolean;

  build() {
    Row() {
      // Brightness adjustment panel
      Column({ space: 8 }) {
        // Brightness icon
        Image($r('app.media.brightness_fill'))
          .width(24)
          .height(24)
          .fillColor('#FFFFFF')
        // Brightness slider
        Slider({
          value: this.brightness,
          min: CommonConstants.MIN_BRIGHTNESS,
          max: CommonConstants.MAX_BRIGHTNESS,
          step: 0.1
        })
          .width(120)
          .height(4)
          .trackColor('#666666')
          .selectedColor('#FFFFFF')
          .blockColor('#FFFFFF')
          .blockSize({ width: 20, height: 20 })
          .showSteps(true)
          .onChange((value: number) => {
            // Brightness value will be updated by parent component
          })
      }
      .width('50%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#202224')
      .borderRadius(8)
      .opacity(this.visible ? 1 : 0)
    }
    .width('100%')
    .height('100%')
  }
}