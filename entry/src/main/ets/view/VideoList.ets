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

import { VideoData } from "../module/VideoData"
import { VideoType } from "../module/VideoType"

@Component
export struct VideoList {
  @Link currentVideoIndex: number;
  @Link videoSrc: Resource;
  @Link previewUri: Resource;
  @Link isAutoPlay: boolean;
  @Link curSource: VideoType;

  build() {
    Column() {
      Column({ space: 12 }) {
        Column() {
          Text($r('app.string.video_list'))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        ForEach(VideoData, (item: VideoType, index: number) => {
          Row({ space: 12 }) {
            Image(item.previewUri)
              .width(120)
              .height(90)
              .borderRadius(8)
            Row() {
              Text() {
                if (this.currentVideoIndex === index) {
                  SymbolSpan($r('sys.symbol.play_round_rectangle_fill'))
                    .width('20vp')
                    .height('20vp')
                }
                Span(item.description)
              }
              .fontColor(this.currentVideoIndex === index ? Color.Blue : Color.Black)
            }
          }
          .onClick(() => {
            this.videoSrc = item.videoSrc;
            this.previewUri = item.previewUri;
            this.isAutoPlay = true;
            this.currentVideoIndex = index;
            this.curSource = item;
          })
          .width('100%')
        }, (item: VideoType) => JSON.stringify(item.index))
      }
      .padding({
        left: 16,
        right: 16
      })
    }
  }
}