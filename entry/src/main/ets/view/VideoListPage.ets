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
import { VideoData } from '../module/VideoData';
import { VideoInfo } from '../module/VideoInfo';
import { BreakpointSystem, BreakpointType } from '../utils/BreakpointSystem';

@Component
export struct VideoListPage {
  @Link currentVideoIndex: number;
  @Link videoSrc: Resource;
  @Link isAutoPlay: boolean;
  @Link curSource: VideoInfo;
  
  private breakpointSystem: BreakpointSystem = BreakpointSystem.getInstance();
  @State currentBreakpoint: BreakpointType = BreakpointType.SM;

  aboutToAppear(): void {
    this.breakpointSystem.initialize();
    this.breakpointSystem.registerListener((breakpoint: BreakpointType) => {
      this.currentBreakpoint = breakpoint;
    });
  }

  aboutToDisappear(): void {
    this.breakpointSystem.destroy();
  }

  // 检查是否是大屏设备
  private isLargeScreen(): boolean {
    return this.currentBreakpoint === BreakpointType.LG || this.currentBreakpoint === BreakpointType.XL;
  }

  // 获取响应式图片宽度
  private getResponsiveImageWidth(): number {
    if (this.isLargeScreen()) {
      return 160; // 大屏设备上图片更大
    }
    return 120; // 小屏设备保持原大小
  }

  // 获取响应式图片高度
  private getResponsiveImageHeight(): number {
    if (this.isLargeScreen()) {
      return 120; // 大屏设备上图片更高
    }
    return 90; // 小屏设备保持原大小
  }

  // 获取响应式字体大小
  private getResponsiveFontSize(): number {
    if (this.isLargeScreen()) {
      return 18; // 大屏设备上字体更大
    }
    return 16; // 小屏设备保持原大小
  }

  build() {
    Column() {
      Column({ space: CommonConstants.COMPONENT_SPACE }) {
        Column() {
          Text($r('app.string.video_list'))
            .fontSize(this.getResponsiveFontSize())
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        ForEach(VideoData, (item: VideoInfo, index: number) => {
          Row({ space: CommonConstants.COMPONENT_SPACE }) {
            Image(item.previewUri)
              .width(this.getResponsiveImageWidth())
              .height(this.getResponsiveImageHeight())
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
              .fontSize(14)
              .fontColor(this.currentVideoIndex === index ? '#ff317af7' : Color.White)
            }
          }
          .onClick(() => {
            this.videoSrc = item.videoSrc;
            this.isAutoPlay = true;
            this.currentVideoIndex = index;
            this.curSource = item;
          })
          .width('100%')
        }, (item: VideoInfo) => JSON.stringify(item.index))
      }
      .padding({
        left: CommonConstants.PADDING_VALUE,
        right: CommonConstants.PADDING_VALUE
      })
    }
  }
}